//
//  TwystUtils.h
//  Twyst
//
//  Created by Niklas Ahola on 5/10/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#ifdef DEBUG
#define NSLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args)
#else
#define NSLog(x...)
#endif

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);

@interface FlipframeUtils : NSObject

+ (NSString*) nibNameForDevice:(NSString*)nibName;

+ (NSString*) generateFileNameWithTwystId:(long)twystId;
+ (NSString*) generateFileNameWithUserId:(long)userId;
+ (NSString*) generateTimeStamp;

+ (void) checkAndCreateDirectory:(NSString*)folderPath;
+ (void) moveFile:(NSString*) pathSrc toDesc:(NSString*) pathDesc;
+ (void) deleteFolder:(NSString*)path;
+ (void) deleteFileOrFolder:(NSString*) path;

+ (UIImage*) getImageFromView:(UIView*)view;
+ (UIImage*) applyDrawingOverlay:(UIImage*)fullImage overlay:(UIImage*)overlay;
+ (UIImage*) generateSelectionOverlayWithIndex:(UIImage*) image withIndex:(NSInteger)index;
+ (UIImage*) addReplyComment:(UIImage*)image comment:(NSString*)comment frame:(CGRect)frame;
+ (UIImage*) generateVideoOverlay:(CGSize)size drawing:(UIImage*)drawing  comment:(NSString*)comment frame:(CGRect)frame;
+ (void) logError:(NSError *)error;

+ (NSString*) getNumbersFromString:(NSString*)string;
+ (NSString*) getStyledPhoneNumber:(NSString*)phoneNumber;
+ (NSString*) countString:(NSInteger)count;
+ (NSString*) strunggString:(NSNumber*)strungg;

+ (BOOL) isSubstring:(NSString*)substring of:(NSString*)string;

+ (UIImage*)generateThumbImageFromVideo: (NSURL*)videoUrl coverFrame:(CGFloat)coverFrame;

+ (CGFloat)editCommentHeight;
+ (CGFloat)editCommentFontSize;

@end
