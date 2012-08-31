/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
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
 ******************************************************************************/

#import "AlfrescoOnPremiseSiteService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoObjectConverter.h"
#import "AlfrescoErrors.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoPagingUtils.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoDocumentFolderService.h"
#import "AlfrescoSortingUtils.h"

@interface AlfrescoOnPremiseSiteService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
@property (nonatomic, strong, readwrite) NSArray *supportedSortKeys;
@property (nonatomic, strong, readwrite) NSString *defaultSortKey;
- (NSArray *) parseSiteArrayWithData:(NSData *)data error:(NSError **)outError;
- (AlfrescoSite *) parseSiteWithData:(NSData *)data error:(NSError **)outError;
- (NSArray *) parseFavoriteSitesObjectWithData:(NSData *)data error:(NSError **)outError;
- (AlfrescoSite *)siteFromJSON:(NSDictionary *)siteDict;
@end

@implementation AlfrescoOnPremiseSiteService
@synthesize baseApiUrl = _baseApiUrl;
@synthesize session = _session;
@synthesize operationQueue = _operationQueue;
@synthesize objectConverter = _objectConverter;
@synthesize authenticationProvider = _authenticationProvider;
@synthesize defaultSortKey = _defaultSortKey;
@synthesize supportedSortKeys = _supportedSortKeys;

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremiseAPIPath];
        self.objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self.session];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 2;
        id authenticationObject = objc_getAssociatedObject(self.session, &kAlfrescoAuthenticationProviderObjectKey);
        self.authenticationProvider = nil;
        if ([authenticationObject isKindOfClass:[AlfrescoBasicAuthenticationProvider class]])
        {
            self.authenticationProvider = (AlfrescoBasicAuthenticationProvider *)authenticationObject;
        }
        self.defaultSortKey = kAlfrescoSortByTitle;
        self.supportedSortKeys = [NSArray arrayWithObjects:kAlfrescoSortByTitle, kAlfrescoSortByShortname, nil];
    }
    return self;
}

- (AlfrescoSite *)siteFromJSON:(NSDictionary *)siteDict
{
    AlfrescoSite *alfSite = [[AlfrescoSite alloc] init];
    
    // convert nodeRef to standard structure
    
    alfSite.summary = [siteDict valueForKey:kAlfrescoJSONDescription];
    alfSite.title = [siteDict valueForKey:kAlfrescoJSONTitle];
    alfSite.shortName = [siteDict valueForKey:kAlfrescoJSONShortname];
    NSString *visibility = [siteDict valueForKey:kAlfrescoJSONVisibility];
    if ([visibility isEqualToString:kAlfrescoJSONVisibilityPUBLIC])
    {
        alfSite.visibility = AlfrescoSiteVisibilityPublic;
    }
    else if ([visibility isEqualToString:kAlfrescoJSONVisibilityPRIVATE])
    {
        alfSite.visibility = AlfrescoSiteVisibilityPrivate;
    }
    else if ([visibility isEqualToString:kAlfrescoJSONVisibilityMODERATED])
    {
        alfSite.visibility = AlfrescoSiteVisibilityModerated;
    }
    
    return alfSite;
}



- (void)retrieveAllSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *error = nil;
        NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoOnPremiseSiteAPI
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&error];
        
        __block NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        NSArray *sortedSiteArray = nil;
        if(nil != data)
        {
            NSArray *siteArray = [weakSelf parseSiteArrayWithData:data error:&error];
            sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            log(@"JSON data %@", jsonString);
            
            completionBlock(sortedSiteArray, error);
        }];
    }];
}

- (void)retrieveAllSitesWithListingContext:(AlfrescoListingContext *)listingContext
                           completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != listingContext, @"RetrieveAllSitesWithCompletionBlock: the listingContext must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *error = nil;
        
        NSData *data = [AlfrescoHTTPUtils executeRequest:kAlfrescoOnPremiseSiteAPI
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&error];
        NSArray *siteArray = nil;
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            siteArray = [weakSelf parseSiteArrayWithData:data error:&error];
            if (nil != siteArray)
            {
                NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray
                                                                             sortKey:listingContext.sortProperty
                                                                       supportedKeys:self.supportedSortKeys
                                                                          defaultKey:self.defaultSortKey
                                                                           ascending:listingContext.sortAscending];
                pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSiteArray listingContext:listingContext];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, error);
        }];
    }];
}

- (void)retrieveSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        NSArray *sortedSiteArray = nil;
        if(nil != data)
        {
            NSArray *siteArray = [weakSelf parseSiteArrayWithData:data error:&operationQueueError];
            sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray sortKey:self.defaultSortKey ascending:YES];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(sortedSiteArray, operationQueueError);
        }];
    }];
}

- (void)retrieveSitesWithListingContext:(AlfrescoListingContext *)listingContext
                        completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != listingContext, @"RetrieveAllSitesWithCompletionBlock: the listingContext must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        // pos parameter is not working, so paging is done in-memory
        NSString *requestString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        
        NSArray *siteArray = nil;
        AlfrescoPagingResult *pagingResult = nil;
        if(nil != data)
        {
            siteArray = [weakSelf parseSiteArrayWithData:data error:&operationQueueError];
            if (nil != siteArray)
            {
                NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteArray
                                                                             sortKey:listingContext.sortProperty
                                                                       supportedKeys:self.supportedSortKeys
                                                                          defaultKey:self.defaultSortKey
                                                                           ascending:listingContext.sortAscending];
                pagingResult = [AlfrescoPagingUtils pagedResultFromArray:sortedSiteArray listingContext:listingContext];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, operationQueueError);
        }];
    }];
}


- (void)retrieveFavoriteSitesWithCompletionBlock:(AlfrescoArrayCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *favRequestString = [kAlfrescoOnPremiseFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        NSString *allRequestString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        NSData *favoriteSitesdata = [AlfrescoHTTPUtils executeRequest:favRequestString
                                                      baseUrlAsString:weakSelf.baseApiUrl
                                               authenticationProvider:weakSelf.authenticationProvider
                                                                error:&operationQueueError];
        NSData *allSitesData = [AlfrescoHTTPUtils executeRequest:allRequestString
                                                 baseUrlAsString:weakSelf.baseApiUrl
                                          authenticationProvider:weakSelf.authenticationProvider
                                                           error:&operationQueueError];
        
        
        NSArray *sortedSiteArray = nil;
        NSArray *allSitesArray = nil;
        NSArray *favoriteSitesArray = nil;
        if(nil != allSitesData)
        {
            allSitesArray = [weakSelf parseSiteArrayWithData:allSitesData error:&operationQueueError];
        }
        if (nil != favoriteSitesdata)
        {
            favoriteSitesArray = [weakSelf parseFavoriteSitesObjectWithData:favoriteSitesdata error:&operationQueueError];
        }
        if (nil != favoriteSitesArray && nil != allSitesArray)
        {
            NSMutableArray *siteResultArray = [NSMutableArray arrayWithCapacity:[favoriteSitesArray count]];
            for (AlfrescoSite *site in allSitesArray) {
                if([favoriteSitesArray containsObject:site.shortName] == YES)
                {
                    [siteResultArray addObject:site];
                }
            }
            sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteResultArray sortKey:self.defaultSortKey ascending:YES];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(sortedSiteArray, operationQueueError);
        }];
        
    }];
}

- (void)retrieveFavoriteSitesWithListingContext:(AlfrescoListingContext *)listingContext
                                completionBlock:(AlfrescoPagingResultCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != listingContext, @"RetrieveAllSitesWithCompletionBlock: the listingContext must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        
        NSString *favRequestString = [kAlfrescoOnPremiseFavoriteSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        NSString *allRequestString = [kAlfrescoOnPremiseSiteForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:self.session.personIdentifier];
        NSData *favoriteSitesdata = [AlfrescoHTTPUtils executeRequest:favRequestString
                                                      baseUrlAsString:weakSelf.baseApiUrl
                                               authenticationProvider:weakSelf.authenticationProvider
                                                                error:&operationQueueError];
        NSData *allSitesData = [AlfrescoHTTPUtils executeRequest:allRequestString
                                                 baseUrlAsString:weakSelf.baseApiUrl
                                          authenticationProvider:weakSelf.authenticationProvider
                                                           error:&operationQueueError];
        
        AlfrescoPagingResult *pagingResult = nil;
        NSArray *allSitesArray = nil;
        NSArray *favoriteSitesArray = nil;
        if(nil != allSitesData)
        {
            allSitesArray = [weakSelf parseSiteArrayWithData:allSitesData error:&operationQueueError];
        }
        if (nil != favoriteSitesdata)
        {
            favoriteSitesArray = [weakSelf parseFavoriteSitesObjectWithData:favoriteSitesdata error:&operationQueueError];
        }
        if (nil != favoriteSitesArray && nil != allSitesArray)
        {
            NSMutableArray *siteResultArray = [NSMutableArray array];
            int totalItems = 0;
            int totalItemsAdded = 0;
            for (AlfrescoSite *site in allSitesArray) {
                if([favoriteSitesArray containsObject:site.shortName] == YES)
                {
                    totalItems = totalItems + 1;
                    if (listingContext.skipCount == 0 || listingContext.skipCount < totalItems)
                    {
                        totalItemsAdded = totalItemsAdded + 1;
                        if (listingContext.maxItems >= totalItemsAdded)
                        {
                            [siteResultArray addObject:site];
                        }
                    }
                }
            }
            NSArray *sortedSiteArray = [AlfrescoSortingUtils sortedArrayForArray:siteResultArray
                                                                         sortKey:listingContext.sortProperty
                                                                   supportedKeys:self.supportedSortKeys
                                                                      defaultKey:self.defaultSortKey
                                                                       ascending:listingContext.sortAscending];
            
            BOOL hasMore = NO;
            if(siteResultArray.count + listingContext.skipCount < totalItems)
            {
                hasMore = YES;
            }
            pagingResult = [[AlfrescoPagingResult alloc] initWithArray:sortedSiteArray hasMoreItems:hasMore totalItems:totalItems];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(pagingResult, operationQueueError);
        }];
    }];
}

- (void)retrieveSiteWithShortName:(NSString *)siteShortName
                  completionBlock:(AlfrescoSiteCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != siteShortName, @"RetrieveAllSitesWithCompletionBlock: the site short name must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoOnPremiseSitesShortnameAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
        NSData *data = [AlfrescoHTTPUtils executeRequest:requestString
                                         baseUrlAsString:weakSelf.baseApiUrl
                                  authenticationProvider:weakSelf.authenticationProvider
                                                   error:&operationQueueError];
        AlfrescoSite *site = nil;
        if(nil != data)
        {
            site = [weakSelf parseSiteWithData:data error:&operationQueueError];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(site, operationQueueError);
        }];
    }];
}


- (void)retrieveDocumentLibraryFolderForSite:(NSString *)siteShortName
                             completionBlock:(AlfrescoFolderCompletionBlock)completionBlock
{
    NSAssert(nil != completionBlock, @"RetrieveAllSitesWithCompletionBlock: the completion block must not be nil");
    NSAssert(nil != siteShortName, @"RetrieveAllSitesWithCompletionBlock: the site short name must not be nil");
    NSAssert(nil != self.authenticationProvider, @"RetrieveAllSitesWithCompletionBlock: the service must have a valid authentication provider");
    
    __weak AlfrescoOnPremiseSiteService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoOnPremiseSiteDoclibAPI stringByReplacingOccurrencesOfString:kAlfrescoSiteId withString:siteShortName];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",
                                           self.session.baseUrl, requestString]];
        NSData *data = [AlfrescoHTTPUtils executeRequestWithURL:url
                                         authenticationProvider:weakSelf.authenticationProvider
                                                           data:nil
                                                     httpMethod:@"GET"
                                                          error:&operationQueueError];
        NSString *folderId = nil;
        if (nil != data)
        {
            id jsonContainer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&operationQueueError];
            if (nil != jsonContainer)
            {
                NSArray *containerArray = [jsonContainer valueForKey:kAlfrescoJSONContainers];
                if ( nil != containerArray && containerArray.count > 0)
                {
                    folderId = [[containerArray objectAtIndex:0] valueForKey:kAlfrescoJSONNodeRef];
                }
            }
        }
        
        if (nil != folderId)
        {
            __block AlfrescoDocumentFolderService *docService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
            [docService retrieveNodeWithIdentifier:folderId
                                   completionBlock:^(AlfrescoNode *node, NSError *error)
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     completionBlock((AlfrescoFolder *)node, error);}];
                 docService = nil;
             }];
        }
        else
        {
            if(nil == operationQueueError)
            {
                operationQueueError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeDocumentFolder
                                                          withDetailedDescription:@"The document library was not found"];
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(nil, operationQueueError);
            }];
        }
    }];
}


#pragma mark Site service internal methods
- (NSArray *) parseSiteArrayWithData:(NSData *)data error:(NSError **)outError
{
    if (nil == data)
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeSites withDetailedDescription:@"Parse JSON shouldn't be nil"];
        return nil;
    }
    NSError *error = nil;
    id jsonSiteArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(error)
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeSites];
        return nil;
    }
    if ([jsonSiteArray isKindOfClass:[NSArray class]] == NO)
    {
        if([jsonSiteArray isKindOfClass:[NSDictionary class]] == YES && [[jsonSiteArray valueForKeyPath:@"status.code"] isEqualToNumber:[NSNumber numberWithInt:404]])
        {
            // no results found
            return [NSArray array];
        }
        else
        {
            *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeSites withDetailedDescription:@"Parse result returns no site"];
            return nil;
        }
    }
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[jsonSiteArray count]];
    for (NSDictionary *siteDict in jsonSiteArray) {
        [resultArray addObject:[self siteFromJSON:siteDict]];
    }
    return resultArray;
}

- (AlfrescoSite *) parseSiteWithData:(NSData *)data error:(NSError **)outError
{
    if (nil == data)
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeSites withDetailedDescription:@"Parse JSON shouldn't be nil"];
        return nil;
    }
    NSError *error = nil;
    id jsonSite = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(error)
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeSites];
        return nil;
    }
    if ([jsonSite isKindOfClass:[NSDictionary class]] == NO)
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeSites withDetailedDescription:@"Parse result is no sites"];
        return nil;
    }
    if([[jsonSite valueForKeyPath:kAlfrescoJSONStatusCode] isEqualToNumber:[NSNumber numberWithInt:404]])
    {
        //empty/non existent site - should this happen? error message?
        return nil;
    }
    
    return (AlfrescoSite *)[self siteFromJSON:jsonSite];
}

- (NSArray *) parseFavoriteSitesObjectWithData:(NSData *)data error:(NSError **)outError
{
    if (nil == data)
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeSites withDetailedDescription:@"Parse JSON shouldn't be nil"];
        return nil;
    }
    NSError *error = nil;
    id favoriteSitesObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(error)
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeSites];
        return nil;
    }
    if ([favoriteSitesObject isKindOfClass:[NSDictionary class]] == NO)
    {
        *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeSites withDetailedDescription:@"Parse result is no favourite sites"];
        return nil;
    }
    
    NSArray *favoriteArray = [favoriteSitesObject valueForKeyPath:kAlfrescoOnPremiseFavoriteSites];
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:favoriteArray.count];
    for (NSString *favoriteDict in favoriteArray) {
        [resultArray addObject:favoriteDict];
    }
    return resultArray;
}


@end