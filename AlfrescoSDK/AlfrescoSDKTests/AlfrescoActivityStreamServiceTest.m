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

#import "AlfrescoActivityStreamServiceTest.h"
#import "AlfrescoActivityEntry.h"
#import "AlfrescoSiteService.h"

@implementation AlfrescoActivityStreamServiceTest

@synthesize activityStreamService = _activityStreamService;

#pragma On Premise tests
/*
 */

- (void)testRetrieveActivityStreamForLoggedinUserWithPaging
{
    [super runAllSitesTest:^{
        
        self.activityStreamService = [[AlfrescoActivityStreamService alloc] initWithSession:super.currentSession];
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] init];
        paging.maxItems = 10;
        paging.skipCount = 0;
        
        // create a new folder in the repository's root folder
        [self.activityStreamService retrieveActivityStreamWithListingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
         {
             if (nil == pagingResult)
             {
                 super.lastTestSuccessful = NO;
                 super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
             }
             else
             {
                 STAssertNotNil(pagingResult, @"pagingResult should not be nil");
                 STAssertTrue(pagingResult.objects.count > 1, @"expected more than 1 activity entries, but got %d", pagingResult.objects.count);
                 STAssertTrue(pagingResult.totalItems > 0, @"expected activity entries");
                 
                 super.lastTestSuccessful = YES;
             }
             super.callbackCompleted = YES;
         }];
        
        [super waitForCompletion:20];
        
        // check the test outcome
        STAssertTrue(super.callbackCompleted, @"TIMED OUT: test returned before callback was complete");
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}
- (void)testRetrieveActivityStreamForLoggedinUser
{
    [super runAllSitesTest:^{
        
        self.activityStreamService = [[AlfrescoActivityStreamService alloc] initWithSession:super.currentSession];
        
        // create a new folder in the repository's root folder
        [self.activityStreamService retrieveActivityStreamWithCompletionBlock:^(NSArray *array, NSError *error) 
        {
            if (nil == array) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(array, @"array should not be nil");
                STAssertTrue(array.count > 0, @"expected activity entries");
                
                for (AlfrescoActivityEntry *entry in array) {
                    STAssertNotNil(entry.createdBy, @"createdBy user ID should not be nil");
                    STAssertTrue([entry.createdAt isKindOfClass:[NSDate class]], @"post date should be a NSDate");
                    STAssertNotNil(entry.identifier, @"identifier should not be nil");
                    STAssertNotNil(entry.siteShortName, @"site should not be nil");
                    STAssertNotNil(entry.type, @"type should not be nil");
                    STAssertTrue([entry.data isKindOfClass:[NSDictionary class]], @"data should be a NSDictionary");
                }
                
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
            
        }];
        
        [super waitForCompletion:20];
        
        // check the test outcome
        STAssertTrue(super.callbackCompleted, @"TIMED OUT: test returned before callback was complete");
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}


- (void)testRetrieveActivityStreamForUser
{
    [super runAllSitesTest:^{
        
        self.activityStreamService = [[AlfrescoActivityStreamService alloc] initWithSession:super.currentSession];
        
        // create a new folder in the repository's root folder
        [self.activityStreamService retrieveActivityStreamForPerson:super.userName completionBlock:^(NSArray *array, NSError *error)
        {
            if (nil == array) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(array, @"array should not be nil");
                STAssertTrue(array.count > 0, @"expected activity entries");
                
                for (AlfrescoActivityEntry *entry in array) {
                    STAssertNotNil(entry.createdBy, @"createdBy user ID should not be nil");
                    STAssertTrue([entry.createdAt isKindOfClass:[NSDate class]], @"post date should be a NSDate");
                    STAssertNotNil(entry.identifier, @"identifier should not be nil");
                    STAssertNotNil(entry.siteShortName, @"site should not be nil");
                    STAssertNotNil(entry.type, @"type should not be nil");
                    STAssertTrue([entry.data isKindOfClass:[NSDictionary class]], @"data should be a NSDictionary");
                }
                
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
            
        }];
        
        [super waitForCompletion:20];
        
        // check the test outcome
        STAssertTrue(super.callbackCompleted, @"TIMED OUT: test returned before callback was complete");
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveActivityStreamForUserWithPaging
{
    [super runAllSitesTest:^{
        
        self.activityStreamService = [[AlfrescoActivityStreamService alloc] initWithSession:super.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] init];
        paging.maxItems = 5;
        paging.skipCount = 0;
        
        [self.activityStreamService retrieveActivityStreamForPerson:super.userName listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
        {
            if (nil == pagingResult) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
            }
            else 
            {
                STAssertNotNil(pagingResult, @"pagingResult should not be nil");
                STAssertTrue(pagingResult.objects.count == 5, @"expected 1 activity entries");
                STAssertTrue(pagingResult.totalItems > 0, @"expected activity entries");
                
                super.lastTestSuccessful = YES;
            }
            super.callbackCompleted = YES;
            
        }];
        
        [super waitForCompletion:20];
        
        // check the test outcome
        STAssertTrue(super.callbackCompleted, @"TIMED OUT: test returned before callback was complete");
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveActivityStreamForSite
{
    [super runAllSitesTest:^{

        self.activityStreamService = [[AlfrescoActivityStreamService alloc] initWithSession:super.currentSession];
        __block AlfrescoSiteService *siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        
        [siteService retrieveSiteWithShortName:super.testSiteName completionBlock:^(AlfrescoSite *site, NSError *error)
        {
            if (nil == site || nil != error) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                super.callbackCompleted = YES;
            }
            else 
            {
                // create a new folder in the repository's root folder
                [self.activityStreamService retrieveActivityStreamForSite:site completionBlock:^(NSArray *array, NSError *error) 
                 {
                     if (nil == array) 
                     {
                         super.lastTestSuccessful = NO;
                         super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     }
                     else 
                     {
                         STAssertNotNil(array, @"array should not be nil");
                         log(@"activity stream for site returns array count = %d",array.count);
                         STAssertTrue(array.count >= 0, @"site may have more than 0 entries");
                         
                         for (AlfrescoActivityEntry *entry in array) {
                             STAssertNotNil(entry.createdBy, @"createdBy user ID should not be nil");
                             STAssertTrue([entry.createdAt isKindOfClass:[NSDate class]], @"post date should be a NSDate");
                             STAssertNotNil(entry.identifier, @"identifier should not be nil");
                             STAssertNotNil(entry.siteShortName, @"site should not be nil");
                             STAssertNotNil(entry.type, @"type should not be nil");
                             STAssertTrue([entry.data isKindOfClass:[NSDictionary class]], @"data should be a NSDictionary");
                         }
                         
                         super.lastTestSuccessful = YES;
                     }
                     super.callbackCompleted = YES;
                     
                 }];
            }
            
        }];

        [super waitForCompletion:20];
        
        // check the test outcome
        STAssertTrue(super.callbackCompleted, @"TIMED OUT: test returned before callback was complete");
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}

- (void)testRetrieveActivityStreamForSiteWithPaging
{
    [super runAllSitesTest:^{
        
        self.activityStreamService = [[AlfrescoActivityStreamService alloc] initWithSession:super.currentSession];
        __block AlfrescoSiteService *siteService = [[AlfrescoSiteService alloc] initWithSession:super.currentSession];
        
        AlfrescoListingContext *paging = [[AlfrescoListingContext alloc] init];
        paging.maxItems = 5;
        paging.skipCount = 0;
        
        [siteService retrieveSiteWithShortName:super.testSiteName completionBlock:^(AlfrescoSite *site, NSError *error) 
        {
            if (nil == site || nil != error) 
            {
                super.lastTestSuccessful = NO;
                super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                super.callbackCompleted = YES;
            }
            else 
            {
                // create a new folder in the repository's root folder
                [self.activityStreamService retrieveActivityStreamForSite:site listingContext:paging completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error) 
                 {
                     if (nil == pagingResult) 
                     {
                         super.lastTestSuccessful = NO;
                         super.lastTestFailureMessage = [NSString stringWithFormat:@"%@ - %@", [error localizedDescription], [error localizedFailureReason]];
                     }
                     else 
                     {
                         log(@"activity stream for site returns paging results count = %d",pagingResult.objects.count);
                         STAssertNotNil(pagingResult, @"pagingResult should not be nil");
                         STAssertTrue(pagingResult.objects.count <= 5, @"the returned objects count should be up to 5");
                         
                         super.lastTestSuccessful = YES;
                     }
                     super.callbackCompleted = YES;
                     
                 }];
            }
                    
        }];
        
        [super waitForCompletion:20];
        
        // check the test outcome
        STAssertTrue(super.callbackCompleted, @"TIMED OUT: test returned before callback was complete");
        STAssertTrue(super.lastTestSuccessful, super.lastTestFailureMessage);
    }];
}



@end