//
//  AzureBlobStorageService.h
//  Twyst
//
//  Created by Niklas Ahola on 4/24/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Blob.h"
#import "BlobContainer.h"
#import "CloudStorageClient.h"
#import "AuthenticationCredential.h"

@protocol AzureStorageServiceDelegate <NSObject>

@optional
- (void)storageUploading:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;

@end

@interface AzureBlobStorageService : NSObject <CloudStorageClientDelegate>

@property (nonatomic, assign) id <AzureStorageServiceDelegate> delegate;

+ (AzureBlobStorageService*) sharedInstance;

- (void) uploadTwystThumbnail:(UIImage*)thumbnail withTwystId:(long)twystId withCompletion:(void(^)(BOOL))completion;

- (void) uploadTwyst:(NSString*)zipPath withTwystId:(long)twystId withCompletion:(void(^)(BOOL, NSString*))completion;

- (void) uploadTwystVideo:(NSString*)videoPath withTwystId:(long)twystId withCompletion:(void(^)(BOOL, NSString*))completion;

- (void) uploadProfilePhoto:(UIImage*)photo withFileName:(NSString*)fileName withCompletion:(void(^)(BOOL))completion;

@end