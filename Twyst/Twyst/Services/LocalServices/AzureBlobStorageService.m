//
//  AzureBlobStorageService.m
//  Twyst
//
//  Created by Niklas Ahola on 4/24/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "AzureBlobStorageService.h"

@interface AzureBlobStorageService()    {
    AuthenticationCredential *_credential;
    CloudStorageClient *_client;
}

@end

@implementation AzureBlobStorageService

static AzureBlobStorageService *_instance;
+ (AzureBlobStorageService*) sharedInstance    {
    @synchronized(self) {
        if (!_instance)   {
            _instance = [[AzureBlobStorageService alloc] init];
        }
        return _instance;
    }
}

- (id) init {
    self = [super init];
    if (self)   {
        NSString *valAccount = VAL_AZURE_ACCOUNT;
        NSString *valSecretKey = VAL_AZURE_SECRET_KEY;
        _credential = [AuthenticationCredential credentialWithAzureServiceAccount:valAccount accessKey:valSecretKey];
        _client = [CloudStorageClient storageClientWithCredential:_credential];
        _client.delegate = self;
    }
    return self;
}

#pragma mark - public methods
#pragma mark - twyst thumbnail related methods
- (void) uploadTwystThumbnail:(UIImage*)thumbnail withTwystId:(long)twystId withCompletion:(void(^)(BOOL))completion {

    NSString *fileName = [NSString stringWithFormat:@"thumb_%ld.jpg", twystId];
    NSString *valFolderUpload = VAL_AZURE_TWYST_THUMB_UPLOAD_FOLDER;
    
    @autoreleasepool    {
        NSData *data = UIImageJPEGRepresentation(thumbnail, 1.0f);
        NSString *contentType = @"application/jpg";
        
        NSLog(@"azure_storage_uploadTwystThumbnail: file size = %ld, file name = %@", (long)data.length, fileName);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_client addBlobToContainerName:valFolderUpload blobName:fileName contentData:data contentType:contentType withBlock:^(NSError *error) {
                if (completion) {
                    NSLog(@"azure_storage_uploadTwystThumbnail - COMPLETE error : %@", error);
                    if (!error) {
                        completion(YES);
                    }   else    {
                        completion(NO);
                    }
                }
            }];
        });
    }
}

#pragma mark - upload twyst related methods
- (void) uploadTwyst:(NSString*)zipPath withTwystId:(long)twystId withCompletion:(void(^)(BOOL, NSString*))completion {
    
    NSString *valFolderUpload = VAL_AZURE_TWYST_UPLOAD_FOLDER;
    @autoreleasepool    {
        NSError *error;
        __block NSData *data = [[NSData alloc] initWithContentsOfFile:zipPath options:NSDataReadingMappedIfSafe error:&error];
        if (error)  {
            if (completion) {
                completion(NO, nil);
            }
            return;
        }
        NSLog(@"azure_storage_uploadTwyst: frame size = %lu", (unsigned long)data.length);
        
        NSString *fileName = [NSString stringWithFormat:@"%@.zip", [FlipframeUtils generateFileNameWithTwystId:twystId]];
        NSString *contentType = @"application/zip";
        [_client addBlobToContainerName:valFolderUpload blobName:fileName contentData:data contentType:contentType withBlock:^(NSError *error) {
            if (completion) {
                if (!error) {
                    NSLog(@"azure_storage_uploadTwyst - COMPLETE");
                    completion(YES, fileName);
                }   else    {
                    NSLog(@"azure_storage_uploadTwyst - FAILED");
                    completion(NO, nil);
                }
            }
        }];
    }
}

- (void) uploadTwystVideo:(NSString*)videoPath withTwystId:(long)twystId withCompletion:(void(^)(BOOL, NSString*))completion {
    
    NSString *valFolderUpload = VAL_AZURE_TWYST_UPLOAD_FOLDER;
    @autoreleasepool    {
        NSError *error;
        __block NSData *data = [[NSData alloc] initWithContentsOfFile:videoPath options:NSDataReadingMappedIfSafe error:&error];
        if (error)  {
            if (completion) {
                completion(NO, nil);
            }
            return;
        }
        NSLog(@"azure_storage_uploadTwyst: frame size = %lu", (unsigned long)data.length);
        
        NSString *fileName = [NSString stringWithFormat:@"%@.mp4", [FlipframeUtils generateFileNameWithTwystId:twystId]];
        NSString *contentType = @"video/mp4";
        [_client addBlobToContainerName:valFolderUpload blobName:fileName contentData:data contentType:contentType withBlock:^(NSError *error) {
            if (completion) {
                if (!error) {
                    NSLog(@"azure_storage_uploadTwyst - COMPLETE");
                    completion(YES, fileName);
                }   else    {
                    NSLog(@"azure_storage_uploadTwyst - FAILED");
                    completion(NO, nil);
                }
            }
        }];
    }
}

#pragma mark - profile related methods
- (void) uploadProfilePhoto:(UIImage*)photo withFileName:(NSString*)fileName withCompletion:(void(^)(BOOL))completion {
    NSLog(@"azure_storage_uploadProfilePhoto: %@", fileName);
    
    NSString *valFolderUpload = VAL_AZURE_PROFILE_UPLOAD_FOLDER;
    
    @autoreleasepool    {
        NSData *data = UIImageJPEGRepresentation(photo, 1.0f);
        NSString *contentType = @"application/jpg";
        [_client addBlobToContainerName:valFolderUpload blobName:fileName contentData:data contentType:contentType withBlock:^(NSError *error) {
            if (completion) {
                NSLog(@"azure_storage_uploadProfilePhoto - COMPLETE error : %@", error);
                if (!error) {
                    completion(YES);
                }   else    {
                    completion(NO);
                }
            }
        }];
    }
}

#pragma mark - Cloud Storage Client Delegate
- (void)storageClient:(CloudStorageClient *)client totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if ([self.delegate respondsToSelector:@selector(storageUploading:totalBytesExpectedToWrite:)]) {
        [self.delegate storageUploading:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

@end
