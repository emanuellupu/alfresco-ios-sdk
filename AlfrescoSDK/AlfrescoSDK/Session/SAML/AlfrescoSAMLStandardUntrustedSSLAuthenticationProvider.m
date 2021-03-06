/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
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

#import "AlfrescoSAMLStandardUntrustedSSLAuthenticationProvider.h"

@implementation AlfrescoSAMLStandardUntrustedSSLAuthenticationProvider

- (BOOL)canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        return YES;
    }
    return [super canAuthenticateAgainstProtectionSpace:protectionSpace];
}

/**
 * NOTE: Once the TLS Session has been cached for an untrusted connection, that session will be reused
 * by iOS (since 6.0) and willSendRequestForAuthenticationChallenge: will not be called again until the session is cleared.
 * The session is cleared by an app restart or after around 10 minutes.
 * See Apple Technical Q&A QA1727 http://developer.apple.com/library/ios/#qa/qa1727 for full details.
 */
- (void)didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ((challenge.previousFailureCount == 0) &&
        ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]))
    {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    else
    {
        [super didReceiveAuthenticationChallenge:challenge];
    }
}

- (void)didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
          completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if ((challenge.previousFailureCount == 0) &&
        ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]))
    {
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    }
    else
    {
        [super didReceiveChallenge:challenge completionHandler:completionHandler];
    }
}

@end
