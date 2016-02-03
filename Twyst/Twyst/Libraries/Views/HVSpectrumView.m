/*The MIT License (MIT)
 
 Copyright (c) 2013 Hetal Vora
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

//
//  HVSpectrumView.m
//  HVColorSelector
//
//  Created by Vora, Hetal on 11/18/13.
//  Copyright (c) 2013 Vora, Hetal. All rights reserved.
//

#import "UIImage+Device.h"

#import "HVSpectrumView.h"

@interface HVSpectrumView(){
}

@end

@implementation HVSpectrumView
@synthesize selectedColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

-(void)awakeFromNib{
    UIImage *spectrum = [UIImage imageNamedContentFile:@"ic-edit-draw-color-picker"];
    CGRect frame = CGRectMake((self.bounds.size.width - spectrum.size.width) / 2, 0, spectrum.size.width, self.bounds.size.height);
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.image = spectrum;
    [self addSubview:imgView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPt = [touch locationInView:self];
    [self selectColor:touchPt];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPt = [touch locationInView:self];
    [self selectColor:touchPt];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPt = [touch locationInView:self];
    [self selectColor:touchPt];
}

- (void)selectColor:(CGPoint)touchPt {
    touchPt.x = self.bounds.size.width / 2;
    if (touchPt.y < 2) touchPt.y = 2;
    else if (touchPt.y > 86) touchPt.y = 86;
    
    self.selectedColor= [self colorOfPoint:touchPt];
    if ([self.delegate respondsToSelector:@selector(spectrumColorSelected:)]) {
        [self.delegate spectrumColorSelected:self.selectedColor];
    }
}

- (UIColor*)colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace,(CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    [self.layer renderInContext:context];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    return color;
}



@end
