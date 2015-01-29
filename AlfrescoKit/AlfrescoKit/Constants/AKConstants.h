/*
 ******************************************************************************
 * Copyright (C) 2005-2015 Alfresco Software Limited.
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

/** AlfrescoKit constants
 
 Author: Tauseef Mughal (Alfresco)
 */

#import <Foundation/Foundation.h>
#import "NSBundle+AlfrescoKit.h"

#define AKLocalizedString(key, comment) \
        NSLocalizedStringFromTableInBundle((key), @"", [NSBundle alfrescoKitBundle], (comment))

// Completion Blocks
typedef void (^AKLoginCompletionBlock)(BOOL successful, id<AlfrescoSession> session, NSError *error);

// Max items
extern NSUInteger const kMaximumItemsToRetrieveAtOneTime;

// AlfrescoKit bundle name
extern NSString * const kAlfrescoKitBundleName;

// OnPremise server url format
extern NSString * const kAlfrescoOnPremiseServerURLFormatString;
