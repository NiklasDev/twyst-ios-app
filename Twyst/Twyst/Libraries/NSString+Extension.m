//
//  NSString+stringSizeWithFont.m
//  Twyst
//
//  Created by Niklas Ahola on 9/4/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (CGSize)stringSizeWithFont:(UIFont*)font constrainedToWidth:(CGFloat)width {
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    size.height = ceilf(size.height);
    size.width = ceilf(size.width);
    return size;
}

- (CGSize)stringSizeWithFont:(UIFont*)font lineSpace:(CGFloat)lineSpace constrainedToWidth:(CGFloat)width {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:lineSpace];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:style}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    size.height = ceilf(size.height);
    size.width = ceilf(size.width);
    return size;
}

- (NSString*)stringByTruncatingToWidth:(CGFloat)width withFont:(UIFont*)font {
    NSInteger min = 0, max = self.length, mid;
    while (min < max) {
        mid = (min+max)/2;
        
        NSString *currentString = [self substringWithRange:NSMakeRange(0, mid)];
        CGSize currentSize = [currentString sizeWithAttributes:@{NSFontAttributeName:font}];
        
        if (currentSize.width < width){
            min = mid + 1;
        } else if (currentSize.width > width) {
            max = mid - 1;
        } else {
            min = mid;
            break;
        }
    }
    return [self substringWithRange:NSMakeRange(0, min)];
}

+ (NSAttributedString*)formattedString:(NSArray*)subStrings fonts:(NSArray*)fonts colors:(NSArray*)colors {
    return [NSString formattedString:subStrings fonts:fonts colors:colors lineSpace:-1];
}

+ (NSAttributedString*)formattedString:(NSArray*)subStrings fonts:(NSArray*)fonts colors:(NSArray*)colors lineSpace:(CGFloat)lineSpace {
    return [NSString formattedString:subStrings fonts:fonts colors:colors lineSpace:lineSpace alignment:NSTextAlignmentLeft];
}

+ (NSAttributedString*)formattedString:(NSArray*)subStrings fonts:(NSArray*)fonts colors:(NSArray*)colors lineSpace:(CGFloat)lineSpace alignment:(NSTextAlignment)alignment {
    NSMutableString *totalString = [NSMutableString new];
    for (NSInteger i = 0; i < subStrings.count; i ++) {
        NSString *subString = [subStrings objectAtIndex:i];
        [totalString appendString:subString];
    }
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:totalString];
    NSInteger location = 0;
    for (NSInteger i = 0; i < subStrings.count; i ++) {
        NSString *subString = [subStrings objectAtIndex:i];
        NSRange range = NSMakeRange(location, subString.length);
        UIFont *font = [fonts objectAtIndex:i];
        UIColor *color = [colors objectAtIndex:i];
        if (font) {
            [attrString addAttribute:NSFontAttributeName value:font range:range];
        }
        if (color) {
            [attrString addAttribute:NSForegroundColorAttributeName value:color range:range];
        }
        location += subString.length;
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = alignment;
    if (lineSpace > 0) {
        [style setLineSpacing:lineSpace];
    }
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, totalString.length)];
    
    return attrString;
}

@end
