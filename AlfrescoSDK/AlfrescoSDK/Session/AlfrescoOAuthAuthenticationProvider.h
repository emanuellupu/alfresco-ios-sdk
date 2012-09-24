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

#import <Foundation/Foundation.h>
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoOAuthData.h"
@interface AlfrescoOAuthAuthenticationProvider : NSObject <AlfrescoAuthenticationProvider>

/**---------------------------------------------------------------------------------------
 * @name Creates an authentication provider based on cloud OAuth data.
 *  ---------------------------------------------------------------------------------------
 */

/** Creates an instance of an AlfrescoBasicAuthenticationProvider with a username and password.
 
 @param oAuthData
 @return Authentication provider instance.
 */
- (id)initWithOAuthData:(AlfrescoOAuthData *)oauthData;
@end