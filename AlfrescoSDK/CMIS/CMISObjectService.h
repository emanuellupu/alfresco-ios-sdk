/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "CMISObjectData.h"
#import "CMISTypeDefs.h"

@class CMISDocument;
@class CMISStringInOutParameter;

@protocol CMISObjectService <NSObject>

/**
 *Retrieves the object with the given object identifier.
 *
 */
- (CMISObjectData *)retrieveObject:(NSString *)objectId
           withFilter:(NSString *)filter
           andIncludeRelationShips:(CMISIncludeRelationship)includeRelationship
           andIncludePolicyIds:(BOOL)includePolicyIds
           andRenditionFilder:(NSString *)renditionFilter
           andIncludeACL:(BOOL)includeACL
           andIncludeAllowableActions:(BOOL)includeAllowableActions
           error:(NSError * *)error;

/**
 *Retrieves an object using its path.
 *
 */
-(CMISObjectData *)retrieveObjectByPath:(NSString *)path
                             withFilter:(NSString *)filter
                andIncludeRelationShips:(CMISIncludeRelationship)includeRelationship
                    andIncludePolicyIds:(BOOL)includePolicyIds
                     andRenditionFilder:(NSString *)renditionFilter
                          andIncludeACL:(BOOL)includeACL
             andIncludeAllowableActions:(BOOL)includeAllowableActions
                                  error:(NSError **)error;

/**
* Gets the content stream for the specified Document object, or gets a rendition stream for a specified
* rendition of a document or folder object. Downloads the content to a local file and returns the filepath.
*
* Do note that this is an ASYNCHRONOUS call, as a synchronous call would have
* bad performance/memory implications.
*/
- (void)downloadContentOfObject:(NSString *)objectId
                   withStreamId:(NSString *)streamId
                         toFile:(NSString *)filePath
                completionBlock:(CMISVoidCompletionBlock)completionBlock
                   failureBlock:(CMISErrorFailureBlock)failureBlock
                  progressBlock:(CMISProgressBlock)progressBlock;

/**
 * Deletes the content stream for the specified document object.
  *
  * A Repository MAY automatically create new Document versions as part of this service method.
  * Therefore, the objectId output NEED NOT be identical to the objectId input
  *
  * NOTE for atom pub binding: deleteContentStream: This does not return the new object id and change token as specified by the domain model.
  * This is not possible without introducing a new HTTP header.
 */
- (void)deleteContentOfObject:(CMISStringInOutParameter *)objectId
              withChangeToken:(CMISStringInOutParameter *)changeToken
                        error:(NSError * *)error;

/**
 * Changes the content of the given document to the content of the given file.
 *
 * Optional overwrite flag: If TRUE (default), then the Repository MUST replace the existing content stream for the
 * object (if any) with the input contentStream. If FALSE, then the Repository MUST only set the input
 * contentStream for the object if the object currently does not have a content-stream.
 *
 * NOTE for atom pub binding: This does not return the new object id and change token as specified by the domain model.
 * (This is not possible without introducing a new HTTP header).
 */
- (void)changeContentOfObject:(CMISStringInOutParameter *)objectId
                  toContentOfFile:(NSString *)filePath
            withOverwriteExisting:(BOOL)overwrite
                  withChangeToken:(CMISStringInOutParameter *)changeToken
                  completionBlock:(CMISVoidCompletionBlock)completionBlock
                     failureBlock:(CMISErrorFailureBlock)failureBlock
                    progressBlock:(CMISProgressBlock)progressBlock;

/**
* uploads the file from the given path to the given folder.
*
* This is an asynchronous call, due to performance reasons.
*/
- (void)createDocumentFromFilePath:(NSString *)filePath
                      withMimeType:(NSString *)mimeType
                    withProperties:(CMISProperties *)properties
                          inFolder:(NSString *)folderObjectId
                   completionBlock:(CMISStringCompletionBlock)completionBlock // The returned string is the object id of the created document
                      failureBlock:(CMISErrorFailureBlock)failureBlock
                     progressBlock:(CMISProgressBlock)progressBlock;

/**
* Deletes the given object.
*
* The allVersions parameter is currently ignored.
*/
- (BOOL)deleteObject:(NSString *)objectId
         allVersions:(BOOL)allVersions
               error:(NSError * *)error;

/**
* Creates a new folder with given properties under the provided parent folder.
*/
- (NSString *)createFolderInParentFolder:(NSString *)folderObjectId
                          withProperties:(CMISProperties *)properties
                                   error:(NSError * *)error;

/**
 * Deletes the given folder and all of its subfolder and files
 *
 * Returns a list of objects which failed to be deleted.
 *
 */
- (NSArray *)deleteTree:(NSString *)folderObjectId
             allVersion:(BOOL)allVersions
          unfileObjects:(CMISUnfileObject)unfileObjects // default 'delete'
      continueOnFailure:(BOOL)continueOnFailure // default 'NO'
                  error:(NSError * *)error;

/**
 * Updates the properties of the given object.
 */
- (void)updatePropertiesForObject:(CMISStringInOutParameter *)objectId
                   withProperties:(CMISProperties *)properties
                  withChangeToken:(CMISStringInOutParameter *)changeToken
                            error:(NSError **)error;

/**
 * Gets the list of associated Renditions for the specified object.
 * Only rendition attributes are returned, not rendition stream
 *
 * Note: the paging parameters (maxItems and skipCount) are not used in the atom pub binding.
 *       Ie. the whole set is <b>always</b> returned.
 */
- (NSArray *)retrieveRenditions:(NSString *)objectId
            withRenditionFilter:(NSString *)renditionFilter
                   withMaxItems:(NSNumber *)maxItems
                  withSkipCount:(NSNumber *)skipCount
                          error:(NSError * *)error;

@end