/*
 ******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *****************************************************************************
 */

/** AlfrescoLegacyAPIWorkflowProcessService
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoLegacyAPIWorkflowProcessService.h"
#import "AlfrescoErrors.h"
#import "AlfrescoSession.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoURLUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoLog.h"
#import "AlfrescoWorkflowObjectConverter.h"

@interface AlfrescoLegacyAPIWorkflowProcessService ()

@property (nonatomic, weak, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) NSDictionary *publicToPrivateStateMappings;
@property (nonatomic, strong, readwrite) NSDictionary *publicToPrivateVariableMappings;
@property (nonatomic, strong, readwrite) AlfrescoWorkflowObjectConverter *workflowObjectConverter;

@end

@implementation AlfrescoLegacyAPIWorkflowProcessService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    self = [super init];
    if (self)
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoLegacyAPIWorkflowBaseURL];
        self.publicToPrivateStateMappings = @{kAlfrescoWorkflowProcessStateActive : kAlfrescoLegacyAPIWorkflowStatusInProgress,
                                              kAlfrescoWorkflowProcessStateCompleted : kAlfrescoLegacyAPIWorkflowStatusCompleted};
        self.publicToPrivateVariableMappings = @{kAlfrescoWorkflowProcessDescription : kAlfrescoWorkflowLegacyJSONBPMProcessDescription,
                                                 kAlfrescoWorkflowProcessPriority : kAlfrescoWorkflowLegacyJSONLegacyProcessPriority,
                                                 kAlfrescoWorkflowProcessSendEmailNotification : kAlfrescoWorkflowLegacyJSONBPMProcessSendEmailNotification,
                                                 kAlfrescoWorkflowProcessDueDate : kAlfrescoWorkflowLegacyJSONBPMProcessDueDate,
                                                 kAlfrescoWorkflowProcessApprovalRate : kAlfrescoWorkflowLegacyJSONBPMProcessApprovalRate};
        self.workflowObjectConverter = [[AlfrescoWorkflowObjectConverter alloc] init];
    }
    return self;
}

- (AlfrescoRequest *)retrieveAllProcessesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    return [self retrieveProcessesInState:kAlfrescoWorkflowProcessStateAny completionBlock:completionBlock];
}

- (AlfrescoRequest *)retrieveProcessesWithListingContext:(AlfrescoListingContext *)listingContext completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    return [self retrieveProcessesInState:kAlfrescoWorkflowProcessStateAny listingContext:listingContext completionBlock:completionBlock];
}

- (AlfrescoRequest *)retrieveProcessesInState:(NSString *)state completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *queryString = nil;
    
    if (state && ![state isEqualToString:kAlfrescoWorkflowProcessStateAny])
    {
        queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoWorkflowProcessStatus : (self.publicToPrivateStateMappings)[state]}];
    }
    
    NSString *requestString = (queryString) ? [kAlfrescoLegacyAPIWorkflowInstances stringByAppendingString:queryString] : kAlfrescoLegacyAPIWorkflowInstances;
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *processes = [self.workflowObjectConverter workflowProcessesFromLegacyJSONData:data conversionError:&conversionError];
            completionBlock(processes, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveProcessesInState:(NSString *)state listingContext:(AlfrescoListingContext *)listingContext completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *queryString = nil;
    
    if (state && ![state isEqualToString:kAlfrescoWorkflowProcessStateAny])
    {
        queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoWorkflowProcessStatus : (self.publicToPrivateStateMappings)[state]}];
    }
    
    if (!listingContext)
    {
        listingContext = self.session.defaultListingContext;
    }
    
    NSString *requestString = (queryString) ? [kAlfrescoLegacyAPIWorkflowInstances stringByAppendingString:queryString] : kAlfrescoLegacyAPIWorkflowInstances;
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString listingContext:listingContext];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *processes = [self.workflowObjectConverter workflowProcessesFromLegacyJSONData:data conversionError:&conversionError];
            NSDictionary *pagingInfo = [AlfrescoObjectConverter paginationJSONFromOldAPIData:data error:&conversionError];
            int total = [[pagingInfo valueForKey:kAlfrescoWorkflowLegacyJSONTotalItems] intValue];
            int maxItems = [[pagingInfo valueForKey:kAlfrescoWorkflowLegacyJSONMaxItems] intValue];
            BOOL hasMore = ((listingContext.skipCount + maxItems) < total);
            AlfrescoPagingResult *pagingResult = [[AlfrescoPagingResult alloc] initWithArray:processes hasMoreItems:hasMore totalItems:total];
            completionBlock(pagingResult, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveProcessWithIdentifier:(NSString *)processID completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:processID argumentName:@"processID"];
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowSingleInstance stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:processID];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (!data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *tasks = [self.workflowObjectConverter workflowProcessesFromLegacyJSONData:data conversionError:&conversionError];
            AlfrescoWorkflowProcess *task = tasks[0];
            completionBlock(task, conversionError);
        }
    }];
    return request;
}

- (AlfrescoRequest *)retrieveVariablesForProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    // STUB - Not part of 1.3
    return nil;
}

- (AlfrescoRequest *)retrieveAllTasksForProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    return [self retrieveTasksForProcess:process inState:kAlfrescoWorkflowProcessStateAny completionBlock:completionBlock];
}

- (AlfrescoRequest *)retrieveTasksForProcess:(AlfrescoWorkflowProcess *)process inState:(NSString *)state completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    
    NSString *queryString = nil;
    if (state && ![state isEqualToString:kAlfrescoWorkflowProcessStateAny])
    {
        queryString = [AlfrescoURLUtils buildQueryStringWithDictionary:@{kAlfrescoWorkflowTaskState : (self.publicToPrivateStateMappings)[state]}];
    }
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowTasksForInstance stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
    if (queryString)
    {
        requestString = [requestString stringByAppendingString:queryString];
    }
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (!data)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *conversionError = nil;
            NSArray *tasks = [self.workflowObjectConverter workflowTasksFromLegacyJSONData:data conversionError:&conversionError];
            completionBlock(tasks, conversionError);
        }
    }];
    return request;
}

//- (AlfrescoRequest *)retrieveActivitiesForProcess:(AlfrescoWorkflowProcess *)process completionBlock:(???)completionBlock;

- (AlfrescoRequest *)retrieveAttachmentsForTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    // STUB - Not part of 1.3
    return nil;
}

- (AlfrescoRequest *)retrieveProcessImage:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    
    if (self.session.repositoryInfo.capabilities.doesSupportActivitiWorkflowEngine)
    {
        NSString *requestString = [kAlfrescoLegacyAPIWorkflowProcessDiagram stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
        NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
        
        AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
        [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
            if (error)
            {
                completionBlock(nil, error);
            }
            else
            {
                AlfrescoContentFile *contentFile = [[AlfrescoContentFile alloc] initWithData:data mimeType:@"application/octet-stream"];
                completionBlock(contentFile, error);
            }
        }];
        return request;
    }
    else
    {
        NSError *notSupportedError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeWorkflowFunctionNotSupported];
        if (completionBlock != NULL)
        {
            completionBlock(nil, notSupportedError);
        }
        return nil;
    }
}

- (AlfrescoRequest *)retrieveProcessImage:(AlfrescoWorkflowProcess *)process outputStream:(NSOutputStream *)outputStream completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [AlfrescoErrors assertArgumentNotNil:outputStream argumentName:@"outputStream"];
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    
    if (self.session.repositoryInfo.capabilities.doesSupportActivitiWorkflowEngine)
    {
        NSString *requestString = [kAlfrescoLegacyAPIWorkflowProcessDiagram stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
        NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
        
        AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
        [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request outputStream:outputStream completionBlock:^(NSData *data, NSError *error) {
            if (error)
            {
                completionBlock(NO, error);
            }
            else
            {
                completionBlock(YES, error);
            }
        }];
        return nil;
    }
    else
    {
        NSError *notSupportedError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeWorkflowFunctionNotSupported];
        if (completionBlock != NULL)
        {
            completionBlock(NO, notSupportedError);
        }
        return nil;
    }
}

- (AlfrescoRequest *)startProcessForProcessDefinition:(AlfrescoWorkflowProcessDefinition *)processDefinition assignees:(NSArray *)assignees variables:(NSDictionary *)variables attachments:(NSArray *)attachmentNodes completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:processDefinition argumentName:@"processDefinition"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSMutableDictionary *requestBody = [NSMutableDictionary dictionary];
    
    NSArray *allVariableKeys = [variables allKeys];
    for (id keyObject in allVariableKeys)
    {
        NSString *key = (NSString *)keyObject;
        NSString *mappedPrivateKey = (self.publicToPrivateVariableMappings)[key];
        
        if (mappedPrivateKey)
        {
            [requestBody setValue:variables[key] forKey:mappedPrivateKey];
        }
        else
        {
            [requestBody setValue:variables[key] forKey:key];
        }
    }
    
    // attachments
    NSString *documentsAdded = nil;
    for (int i = 0; i < attachmentNodes.count; i++)
    {
        id nodeObject = attachmentNodes[i];
        
        if (![nodeObject isKindOfClass:[AlfrescoNode class]])
        {
            NSString *reason = [NSString stringWithFormat:@"The attachment array should contain instances of %@, but instead contains %@", NSStringFromClass([AlfrescoNode class]), NSStringFromClass([nodeObject class])];
            @throw [NSException exceptionWithName:@"Invalid attachments" reason:reason userInfo:nil];
        }
        
        AlfrescoNode *currentNode = (AlfrescoNode *)nodeObject;
        if (i == 0)
        {
            documentsAdded = currentNode.identifier;
        }
        else
        {
            documentsAdded = [NSString stringWithFormat:@"%@,%@", documentsAdded, currentNode.identifier];
        }
    }
    
    if (documentsAdded)
    {
        [requestBody setValue:documentsAdded forKey:kAlfrescoWorkflowLegacyJSONBPMProcessAttachmentsAdd];
    }
    
    void (^parseAndSendCreationRequest)(AlfrescoRequest *request) = ^(AlfrescoRequest *request){
        // parse
        NSError *requestConversionError = nil;
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&requestConversionError];
        
        if (requestConversionError)
        {
            AlfrescoLogDebug(@"Unable to successfully create request data");
            completionBlock(nil, requestConversionError);
        }
        
        NSString *requestString = [kAlfrescoLegacyAPIWorkflowFormProcessor stringByReplacingOccurrencesOfString:kAlfrescoProcessDefinitionID withString:processDefinition.key];
        NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
        
        [self.session.networkProvider executeRequestWithURL:url session:self.session requestBody:requestData method:kAlfrescoHTTPPOST alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
            if (error)
            {
                completionBlock(nil, error);
            }
            else
            {
                NSError *conversionError = nil;
                id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
                if (conversionError)
                {
                    completionBlock(nil, conversionError);
                }
                else
                {
                    NSString *completedString = ((NSDictionary *)responseObject)[@"persistedObject"];
                    NSArray *separatedStrings = [completedString componentsSeparatedByString:@","];
                    NSString *createdProcessID = [[separatedStrings[0] componentsSeparatedByString:@"id="] lastObject];
                    
                    NSString *requestString = [kAlfrescoLegacyAPIWorkflowSingleInstance stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:createdProcessID];
                    
                    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
                    
                    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
                    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
                        if (!data)
                        {
                            completionBlock(nil, error);
                        }
                        else
                        {
                            NSError *conversionError = nil;
                            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&conversionError];
                            
                            NSDictionary *entry = ((NSDictionary *) responseObject)[kAlfrescoWorkflowLegacyJSONData];
                            AlfrescoWorkflowProcess *process = [[AlfrescoWorkflowProcess alloc] initWithProperties:entry];
                            completionBlock(process, conversionError);
                        }
                    }];
                }
            }
        }];
    };
    
    // assignees
    __block AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    if (assignees)
    {
        [self retrieveNodeRefIdentifiersForPersons:assignees completionBlock:^(NSArray *personNodeRefs, NSError *error) {
            NSString *assigneesAdded = nil;
            for (NSString *assigneeNodeRef in personNodeRefs)
            {
                assigneesAdded = [NSString stringWithFormat:@"%@,%@", assigneesAdded, assigneeNodeRef];
            }
            
            if (assignees.count == 1)
            {
                [requestBody setValue:assigneesAdded forKey:kAlfrescoWorkflowLegacyJSONBPMProcessAssignee];
            }
            else
            {
                [requestBody setValue:assigneesAdded forKey:kAlfrescoWorkflowLegacyJSONBPMProcessAssignees];
            }
            
            parseAndSendCreationRequest(request);
        }];
    }
    else
    {
        [self retrieveNodeRefForUsername:self.session.personIdentifier completionBlock:^(NSString *nodeRef, NSError *error) {
            [requestBody setValue:nodeRef forKey:kAlfrescoWorkflowLegacyJSONBPMProcessAssignee];
            parseAndSendCreationRequest(request);
        }];
    }
    return request;
}

- (AlfrescoRequest *)addAttachment:(AlfrescoNode *)node toProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    // STUB - Not part of 1.3
    return nil;
}

- (AlfrescoRequest *)updateVariables:(NSDictionary *)variables forProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    // STUB - Not part of 1.3
    return nil;
}

- (AlfrescoRequest *)deleteProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoBOOLCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:process argumentName:@"process"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    
    NSString *requestString = [kAlfrescoLegacyAPIWorkflowSingleInstance stringByReplacingOccurrencesOfString:kAlfrescoProcessID withString:process.identifier];
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session method:kAlfrescoHTTPDelete alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(NO, error);
        }
        else
        {
            completionBlock(YES, error);
        }
    }];
    return request;
}

- (AlfrescoRequest *)removeVariables:(NSArray *)variablesKeys forProcess:(AlfrescoWorkflowProcess *)process completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    // STUB - Not part of 1.3
    return nil;
}

- (AlfrescoRequest *)removeAttachment:(AlfrescoNode *)node fromTask:(AlfrescoWorkflowTask *)task completionBlock:(AlfrescoProcessCompletionBlock)completionBlock
{
    // STUB - Not part of 1.3
    return nil;
}

#pragma mark - Private Functions

- (void)retrieveNodeRefIdentifiersForPersons:(NSArray *)assignees completionBlock:(void (^)(NSArray *personNodeRefs, NSError *error))completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:assignees argumentName:@"assignees"];
    
    __block NSMutableArray *nodeRefIdentifiers = [NSMutableArray array];
    __block NSInteger callbacks = 0;
    
    for (AlfrescoPerson *person in assignees)
    {
        [self retrieveNodeRefForUsername:person.identifier completionBlock:^(NSString *nodeRef, NSError *error) {
            callbacks++;
            if (nodeRef)
            {
                [nodeRefIdentifiers addObject:nodeRef];
            }
            
            if (callbacks == assignees.count)
            {
                completionBlock(nodeRefIdentifiers, nil);
            }
        }];
    }
}

- (AlfrescoRequest *)retrieveNodeRefForUsername:(NSString *)username completionBlock:(void (^)(NSString *nodeRef, NSError *error))completionBlock
{
    NSString *requestString = [kAlfrescoLegacyAPIPersonNodeRef stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:username];
    
    NSURL *url = [AlfrescoURLUtils buildURLFromBaseURLString:self.baseApiUrl extensionURL:requestString];
    
    AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
    [self.session.networkProvider executeRequestWithURL:url session:self.session alfrescoRequest:request completionBlock:^(NSData *data, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSError *parseError = nil;
            id jsonResponseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (parseError || ![jsonResponseObject isKindOfClass:[NSDictionary class]])
            {
                completionBlock(nil, parseError);
            }
            else
            {
                NSDictionary *jsonResponseDictionary = (NSDictionary *)jsonResponseObject;
                NSArray *itemsArray = jsonResponseDictionary[kAlfrescoWorkflowLegacyJSONData][kAlfrescoJSONItems];
                NSDictionary *personDictionary = itemsArray[0];
                NSString *nodeRefIdentifier = personDictionary[kAlfrescoJSONNodeRef];
                completionBlock(nodeRefIdentifier, parseError);
            }
        }
    }];
    return request;
}

@end
