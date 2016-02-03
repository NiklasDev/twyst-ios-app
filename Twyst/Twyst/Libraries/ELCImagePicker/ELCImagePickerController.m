//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by ELC on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"

#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"

#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/UTCoreTypes.h>
//#import "PhotoHelper.h"

@implementation ELCImagePickerController

//Using auto synthesizers

- (id)initImagePicker
{
    ELCAlbumPickerController *albumPicker = [[ELCAlbumPickerController alloc] initWithStyle:UITableViewStylePlain];
    
    self = [super initWithRootViewController:albumPicker];
    if (self) {
        self.maximumImagesCount = 4;
        self.minimumImagesCount = 1;
        self.returnsImage = YES;
        [albumPicker setParent:self];
        self.mediaTypes = @[(NSString *)kUTTypeImage];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{

    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.maximumImagesCount = 4;
        self.minimumImagesCount = 1;
        self.returnsImage = YES;
    }
    return self;
}

- (void) startNewSession {
    [self popToRootViewControllerAnimated:NO];
}

- (ELCAlbumPickerController *)albumPicker
{
    return self.viewControllers[0];
}

- (void)setMediaTypes:(NSArray *)mediaTypes
{
    self.albumPicker.mediaTypes = mediaTypes;
}

- (NSArray *)mediaTypes
{
    return self.albumPicker.mediaTypes;
}

- (void)cancelImagePicker
{
	if ([_imagePickerDelegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
		[_imagePickerDelegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

- (void)dealloc {
    NSLog(@"--- %@ Dealloc ---", NSStringFromClass([self class]));
}

#pragma mark - 
#pragma mark ELC Assets Selection Delegate
- (BOOL)shouldSelectAsset:(ELCAsset *)asset previousCount:(NSUInteger)previousCount
{
    BOOL shouldSelect = previousCount < self.maximumImagesCount;
    if (!shouldSelect) {
        NSString *message = nil;
        if ([self.mediaTypes containsObject:(NSString *)kUTTypeImage]) {
            message = [NSString stringWithFormat:@"You can only select %ld photos at a time for your twyst.", (long)self.maximumImagesCount];
        }
        else if ([self.mediaTypes containsObject:(NSString *)kUTTypeMovie]) {
            message = @"You can only select one video at a time for your twyst.";
        }
        
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    }
    return shouldSelect;
}

- (BOOL)shouldDoneWithSelectionCount:(NSUInteger)selectionCount {
    return selectionCount >= self.minimumImagesCount;
}

- (void)selectedAssets:(NSArray *)assets
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    [returnArray addObjectsFromArray:assets];
    if (_imagePickerDelegate != nil && [_imagePickerDelegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
        [_imagePickerDelegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:returnArray];
        [self popToRootViewControllerAnimated:NO];
    } else {
        [self popToRootViewControllerAnimated:NO];
    }
}

@end
