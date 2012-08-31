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

#import "AlfrescoInternalConstants.h"

@implementation AlfrescoInternalConstants

/**
 CMIS constants
 */
NSString * const kCMISNameParameterForSearch = @"cmis:name";
NSString * const kCMISTitle = @"cm:title";
NSString * const kCMISDescription = @"cm:description";
NSString * const kCMISPropertyIntValue = @"int";
NSString * const kCMISPropertyBooleanValue = @"boolean";
NSString * const kCMISPropertyDatetimeValue = @"datetime";
NSString * const kCMISPropertyDecimalValue = @"decimal";
NSString * const kCMISPropertyIdValue = @"id";
NSString * const kCMISAlfrescoMode = @"alfresco";

/**
 Property name constants
 */
NSString * const kAlfrescoRepositoryName = @"name";
NSString * const kAlfrescoRepositoryCommunity = @"Community";
NSString * const kAlfrescoRepositoryEnterprise = @"Enterprise";
NSString * const kAlfrescoRepositoryEdition = @"edition";
NSString * const kAlfrescoRepositoryIdentifier = @"identifier";
NSString * const kAlfrescoRepositorySummary = @"summary";
NSString * const kAlfrescoRepositoryVersion = @"version";
NSString * const kAlfrescoRepositoryMajorVersion = @"majorVersion";
NSString * const kAlfrescoRepositoryMinorVersion = @"minorVersion";
NSString * const kAlfrescoRepositoryMaintenanceVersion = @"maintenanceVersion";
NSString * const kAlfrescoRepositoryBuildNumber = @"buildNumber";
NSString * const kAlfrescoRepositoryCapabilities = @"capabilities";

/**
 Parametrised strings to be used in API
 */
NSString * const kAlfrescoSiteId = @"{siteID}";
NSString * const kAlfrescoNodeRef = @"{nodeRef}";
NSString * const kAlfrescoPersonId = @"{personID}";
NSString * const kAlfrescoCommentId = @"{commentID}";
NSString * const kAlfrescoRenditionId = @"{renditionID}";
NSString * const kAlfrescoSkipCountRequest = @"{skipCount}";
NSString * const kAlfrescoMaxItemsRequest = @"{maxItems}";
NSString * const kAlfrescoOnNodeRefURL = @"workspace://SpacesStore/{nodeRef}";
NSString * const kAlfrescoNode = @"node";
NSString * const kAlfrescoDefaultMimeType = @"application/octet-stream";
NSString * const kAlfrescoAspects = @"aspects";
NSString * const kAlfrescoAppliedAspects = @"appliedAspects";
NSString * const kAlfrescoAspectProperties = @"properties";
NSString * const kAlfrescoAspectPropertyDefinitionId = @"propertyDefinitionId";
NSString * const kAlfrescoPagingRequest = @"?skipCount={skipCount}&maxItems={maxItems}";

/**
 Session data key constants
 */
NSString * const kAlfrescoSessionKeyCmisSession = @"alfresco_session_key_cmis_session";

/**
 Associated object key constants
 */
NSString * const kAlfrescoAuthenticationProviderObjectKey = @"AuthenticationProviderObjectKey";

/**
 On Premise constants
 */
NSString * const kAlfrescoOnPremiseAPIPath = @"/service/api/";
NSString * const kAlfrescoOnPremiseCMISPath = @"/service/cmis";
NSString * const kAlfrescoOnPremiseActivityAPI = @"activities/feed/user?format=json";
NSString * const kAlfrescoOnPremiseActivityForSiteAPI = @"activities/feed/site/{siteID}?format=json";
NSString * const kAlfrescoOnPremiseRatingsAPI = @"node/{nodeRef}/ratings";
NSString * const kAlfrescoOnPremiseRatingsLikingSchemeAPI = @"node/{nodeRef}/ratings/likesRatingScheme";
NSString * const kAlfrescoOnPremiseRatingsCount = @"data.nodeStatistics.likesRatingScheme.ratingsCount";
NSString * const kAlfrescoOnPremiseLikesSchemeRatings = @"data.ratings.likesRatingScheme.rating";
NSString * const kAlfrescoOnPremiseSiteAPI = @"sites?format=json";
NSString * const kAlfrescoOnPremiseSiteForPersonAPI = @"people/{personID}/sites";
NSString * const kAlfrescoOnPremiseFavoriteSiteForPersonAPI = @"people/{personID}/preferences?pf=org.alfresco.share.sites";
NSString * const kAlfrescoOnPremiseSitesShortnameAPI = @"sites/{siteID}";
NSString * const kAlfrescoOnPremiseSiteDoclibAPI = @"service/slingshot/doclib/containers/{siteID}";
NSString * const kAlfrescoOnPremiseFavoriteSites = @"org.alfresco.share.sites.favourites";
NSString * const kAlfrescoOnPremiseCommentsAPI = @"node/{nodeRef}/comments";
NSString * const kAlfrescoOnPremiseCommentForNodeAPI = @"comment/node/{commentID}";
NSString * const kAlfrescoOnPremiseTagsAPI = @"tags/workspace/SpacesStore";
NSString * const kAlfrescoOnPremiseTagsForNodeAPI = @"node/{nodeRef}/tags";
NSString * const kAlfrescoOnPremisePersonAPI = @"people/{personID}";
NSString * const kAlfrescoOnPremiseAvatarForPersonAPI = @"/service/slingshot/profile/avatar/{personID}";
NSString * const kAlfrescoOnPremiseMetadataExtractionAPI = @"/service/api/actionQueue";
NSString * const kAlfrescoOnPremiseThumbnailCreationAPI = @"/node/{nodeRef}/content/thumbnails?as=true";
NSString * const kAlfrescoOnPremiseThumbnailRenditionAPI = @"node/{nodeRef}/content/thumbnails/{renditionID}";

/**
 Cloud constants
 */
NSString * const kAlfrescoCloudURL = @"http://my.alfresco.com";
NSString * const kAlfrescoTestCloudURL = @"http://devapis.alfresco.com";
NSString * const kAlfrescoCloudBindingService = @"/alfresco/service";
NSString * const kAlfrescoCloudSignupURL = @"/internal/cloud/accounts/signupqueue";
NSString * const kAlfrescoCloudPrecursor = @"/alfresco/a";
NSString * const kAlfrescoCloudDefaultTenantID = @"/alfresco.com";
NSString * const kAlfrescoCloudCMISPath = @"/public/cmis/versions/1/atom";
NSString * const kAlfrescoCloudAPIPath  = @"/public/alfresco/versions/1/";
NSString * const kAlfrescoDocumentLibrary =@"documentLibrary";
NSString * const kAlfrescoHomeNetworkType = @"homeNetwork";
NSString * const kAlfrescoCloudSiteAPI = @"sites";
NSString * const kAlfrescoCloudSiteForPersonAPI = @"people/{personID}/sites";
NSString * const kAlfrescoCloudFavoriteSiteForPersonAPI = @"people/{personID}/favorite-sites";
NSString * const kAlfrescoCloudSiteForShortnameAPI = @"sites/{siteID}";
NSString * const kAlfrescoCloudSiteContainersAPI = @"sites/{siteID}/containers";
NSString * const kAlfrescoCloudActivitiesAPI = @"people/{personID}/activities";
NSString * const kAlfrescoCloudActivitiesForSiteAPI = @"people/{personID}/activities?siteId={siteID}";
NSString * const kAlfrescoCloudRatingsAPI = @"nodes/{nodeRef}/ratings";
NSString * const kAlfrescoCloudLikesRatingSchemeAPI = @"node/{nodeRef}/ratings/likesRatingScheme";
NSString * const kAlfrescoCloudCommentsAPI = @"nodes/{nodeRef}/comments";
NSString * const kAlfrescoCloudCommentForNodeAPI = @"nodes/{nodeRef}/comments/{commentID}";
NSString * const kAlfrescoCloudTagsAPI = @"tags";
NSString * const kAlfrescoCloudTagsForNodeAPI = @"nodes/{nodeRef}/tags";
NSString * const kAlfrescoCloudPersonAPI = @"people/{personID}";

/**
 JSON Constants
 */
NSString * const kAlfrescoCloudJSONList = @"list";
NSString * const kAlfrescoCloudJSONEntries = @"entries";
NSString * const kAlfrescoCloudJSONEntry = @"entry";
NSString * const kAlfrescoJSONIdentifier = @"id";
NSString * const kAlfrescoJSONStatusCode = @"status.code";
NSString * const kAlfrescoJSONActivityPostDate = @"postDate";
NSString * const kAlfrescoJSONActivityPostUserID = @"postUserId";
NSString * const kAlfrescoJSONActivityPostPersonID = @"postPersonId";
NSString * const kAlfrescoJSONActivitySiteNetwork = @"siteNetwork";
NSString * const kAlfrescoJSONActivityType = @"activityType";
NSString * const kAlfrescoJSONActivitySummary = @"activitySummary";
NSString * const kAlfrescoJSONRating = @"rating";
NSString * const kAlfrescoJSONRatingScheme = @"ratingScheme";
NSString * const kAlfrescoJSONLikesRatingScheme = @"likesRatingScheme";
NSString * const kAlfrescoJSONDescription = @"description";
NSString * const kAlfrescoJSONTitle = @"title";
NSString * const kAlfrescoJSONShortname = @"shortName";
NSString * const kAlfrescoJSONVisibility = @"visibility";
NSString * const kAlfrescoJSONVisibilityPUBLIC = @"PUBLIC";
NSString * const kAlfrescoJSONVisibilityPRIVATE = @"PRIVATE";
NSString * const kAlfrescoJSONVisibilityMODERATED = @"MODERATED";
NSString * const kAlfrescoJSONContainers = @"containers";
NSString * const kAlfrescoJSONNodeRef = @"nodeRef";
NSString * const kAlfrescoJSONSiteID = @"siteId";
NSString * const kAlfrescoJSONLikes = @"likes";
NSString * const kAlfrescoJSONMyRating = @"myRating";
NSString * const kAlfrescoJSONAggregate = @"aggregate";
NSString * const kAlfrescoJSONNumberOfRatings = @"numberOfRatings";
NSString * const kAlfrescoJSONHomeNetwork = @"homeNetwork";
NSString * const kAlfrescoJSONNetwork = @"network";
NSString * const kAlfrescoJSONPaidNetwork = @"paidNetwork";
NSString * const kAlfrescoJSONCreationTime = @"creationDate";
NSString * const kAlfrescoJSONSubscriptionLevel = @"subscriptionLevel";
NSString * const kAlfrescoJSONName = @"name";
NSString * const kAlfrescoJSONItems = @"items";
NSString * const kAlfrescoJSONItem = @"item";
NSString * const kAlfrescoJSONAuthorUserName = @"author.username";
NSString * const kAlfrescoJSONCreatedOn = @"createdOn";
NSString * const kAlfrescoJSONCreatedOnISO = @"createdOnISO";
NSString * const kAlfrescoJSONModifiedOn = @"modifiedOn";
NSString * const kAlfrescoJSONModifiedOnISO = @"modifiedOnISO";
NSString * const kAlfrescoJSONContent = @"content";
NSString * const kAlfrescoJSONIsUpdated = @"isUpdated";
NSString * const kAlfrescoJSONPermissionsEdit = @"permissions.edit";
NSString * const kAlfrescoJSONPermissionsDelete = @"permissions.delete";
NSString * const kAlfrescoJSONCreatedAt = @"createdAt";
NSString * const kAlfrescoJSONCreatedBy = @"createdBy";
NSString * const kAlfrescoJSONCreator = @"creator";
NSString * const kAlfrescoJSONAvatar = @"avatar";
NSString * const kAlfrescoJSONModifedAt = @"modifiedAt";
NSString * const kAlfrescoJSONEdited = @"edited";
NSString * const kAlfrescoJSONCanEdit = @"canEdit";
NSString * const kAlfrescoJSONCanDelete = @"canDelete";
NSString * const kAlfrescoJSONEnabled = @"enabled";
NSString * const kAlfrescoJSONTag = @"tag";
NSString * const kAlfrescoJSONUserName = @"userName";
NSString * const kAlfrescoJSONFirstName = @"firstName";
NSString * const kAlfrescoJSONLastName = @"lastName";
NSString * const kAlfrescoJSONActionedUponNode = @"actionedUponNode";
NSString * const kAlfrescoJSONExtractMetadata = @"extract-metadata";
NSString * const kAlfrescoJSONActionDefinitionName = @"actionDefinitionName";
NSString * const kAlfrescoJSONThumbnailName = @"thumbnailName";
NSString * const kAlfrescoJSONSite = @"site";
NSString * const kAlfrescoJSONEmail = @"email";
NSString * const kAlfrescoJSONSignupFirstName = @"firstName";
NSString * const kAlfrescoJSONSignupLastName = @"lastName";
NSString * const kAlfrescoJSONPassword = @"password";
NSString * const kAlfrescoJSONSource = @"source";
NSString * const kAlfrescoJSONRegistration = @"registration";
NSString * const kAlfrescoJSONRegistrationTime = @"registrationDate";
NSString * const kAlfrescoJSONAPIKey = @"key";
NSString * const kAlfrescoJSONIOSSource = @"mobile-iOS";
NSString * const kAlfrescoJSONIsRegistered = @"";
NSString * const kAlfrescoJSONPostedAt = @"postedAt";
NSString * const kAlfrescoJSONAvatarId = @"avatarId";

@end