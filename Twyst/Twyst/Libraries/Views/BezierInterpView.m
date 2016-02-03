#import "BezierInterpView.h"


@implementation BezierInterpView
{
    
    CGPoint pts[4]; // to keep track of the four points of our Bezier segment
    uint ctr; // a counter variable to keep track of the point index
    
    NSMutableArray *history; //keep all points
    NSInteger stackPtr;
    
    BOOL isDrawing;
    BOOL isFirstTouch;
    BOOL isMultipleTouch;
}

@synthesize incrementalImage;
@synthesize rectpath;
@synthesize path;
@synthesize lineWidth;
@synthesize lineColor;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:YES];
        
        lineWidth = 4.0;
        isFirstTouch = NO;
        
        lineColor = [UIColor blackColor];
        
        history = [[NSMutableArray alloc] init];
        
        path = [UIBezierPath bezierPath];
        [path setLineWidth:lineWidth];
        [path setLineCapStyle:kCGLineCapRound];
        
        self.isChanged = NO;
    }
    
    return self;
    
}

- (void)drawRect:(CGRect)rect   
{
    [lineColor setStroke];
    [incrementalImage drawInRect:rect];
    [path stroke];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  
{
    if ([[event touchesForView:self] count] > 1) {
        NSLog(@"%d active touches",[[event touchesForView:self] count]) ;
        isFirstTouch = NO;
        return;
    }
    
    [path setLineWidth:lineWidth];
    
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
    
    isDrawing = YES;
    isFirstTouch = YES;
    
    if (self.delegate) {
        [self.delegate bezierInterpViewDrawDidBegin:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[event touchesForView:self] count] > 1) {
        NSLog(@"%d active touches",[[event touchesForView:self] count]) ;
        isDrawing = NO;
        isFirstTouch = NO;
        return;
    }
    
    if (isDrawing == NO)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    
    ctr++;
    pts[ctr] = p;
    if (ctr == 3) // 4th point
    {
        if (isFirstTouch == YES) {
            isFirstTouch = NO;
            [self amendHistory];
            [history addObject:[NSMutableArray array]];
            [[history objectAtIndex:[history count]-1] addObject:[NSNumber numberWithInt:lineWidth]];
            [[history objectAtIndex:[history count]-1] addObject:lineColor];
            stackPtr++;
            self.isChanged = YES;
        }
        
        [[history objectAtIndex:[history count]-1] addObject:[NSValue valueWithCGPoint:pts[0]]];
        [[history objectAtIndex:[history count]-1] addObject:[NSValue valueWithCGPoint:pts[1]]];
        [[history objectAtIndex:[history count]-1] addObject:[NSValue valueWithCGPoint:pts[2]]];
        [[history objectAtIndex:[history count]-1] addObject:[NSValue valueWithCGPoint:pts[3]]];
        
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // this is how a Bezier curve is appended to a path
        [self setNeedsDisplay];
        pts[0] = [path currentPoint];
        ctr = 0;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[event touchesForView:self] count] > 1) {
        NSLog(@"%d active touches",[[event touchesForView:self] count]) ;
        return;
    }
    
    if (isDrawing == NO)
        return;
    else
        isDrawing = NO;
    
    if (isFirstTouch == YES) {
        isFirstTouch = NO;
        [self amendHistory];
        [history addObject:[NSMutableArray array]];
        [[history objectAtIndex:[history count]-1] addObject:[NSNumber numberWithInt:lineWidth]];
        [[history objectAtIndex:[history count]-1] addObject:lineColor];
        stackPtr++;
        self.isChanged = YES;
        
        [[history objectAtIndex:[history count]-1] addObject:[NSValue valueWithCGPoint:pts[0]]];
        [[history objectAtIndex:[history count]-1] addObject:[NSValue valueWithCGPoint:pts[0]]];
        [[history objectAtIndex:[history count]-1] addObject:[NSValue valueWithCGPoint:pts[0]]];
        [[history objectAtIndex:[history count]-1] addObject:[NSValue valueWithCGPoint:pts[0]]];
        
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[0] controlPoint1:pts[0] controlPoint2:pts[0]]; // this is how a Bezier curve is appended to a path
        [self setNeedsDisplay];
        pts[0] = [path currentPoint];
        ctr = 0;
    }
    
    [self drawBitmap];
    [self setNeedsDisplay];
    pts[0] = [path currentPoint]; // let the second endpoint of the current Bezier segment be the first one for the next Bezier segment
    [path removeAllPoints];
    ctr = 0;
    
    if (self.delegate) {
        [self.delegate bezierInterpViewDrawDidEnd:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [[UIScreen mainScreen] scale]);
    
    [lineColor setStroke];
    
    [incrementalImage drawAtPoint:CGPointZero];
    
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"+ image size = (%.0f, %.0f)", incrementalImage.size.width, incrementalImage.size.height);
}

- (void)clear {
    [path removeAllPoints];
    [history removeAllObjects];
    stackPtr = 0;
    
    self.isChanged = NO;
    
    incrementalImage = nil;
    [self setNeedsDisplay];
}

- (void) onErase:(BOOL)flag {
    if (flag == NO) {
        lineColor = [UIColor whiteColor];
    }
    else if (flag == YES) {
        lineColor = [UIColor blackColor];
    }
}

- (void) onMultipleTouch:(BOOL)isMultiple {
    isMultipleTouch = isMultiple;
}

- (void) undo {
    if (stackPtr == 0) {
        return;
    }
    stackPtr--;
    self.isChanged = stackPtr;
    
    [self drawHistory];
}

- (void) redo {
    if (stackPtr == [history count]) {
        return;
    }
    stackPtr++;
    [self drawHistory];
}

- (BOOL)isUndoable {
    return (stackPtr > 0);
}

- (void) drawHistory
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [[UIScreen mainScreen]scale]);
    
    for (int l = 0; l < stackPtr; l++) {
        if ([[history objectAtIndex:l] isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray * instance = [history objectAtIndex:l];
            
            NSInteger width = [[instance objectAtIndex:0] integerValue];
            UIColor * color = [instance objectAtIndex:1];
            [path setLineWidth:width];
            [color setStroke];
            
            for (int p = 2; p < [instance count]-3; p += 4) {
                pts[0] = [[instance objectAtIndex:p] CGPointValue];
                pts[1] = [[instance objectAtIndex:p+1] CGPointValue];
                pts[2] = [[instance objectAtIndex:p+2] CGPointValue];
                pts[3] = [[instance objectAtIndex:p+3] CGPointValue];
                
                [path moveToPoint:pts[0]];
                [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // this is how a Bezier curve is appended to a path
                [self setNeedsDisplay];
                pts[0] = [path currentPoint];
            }
            
            [path stroke];
            pts[0] = [path currentPoint]; // let the second endpoint of the current Bezier segment be the first one for the next Bezier segment
            [path removeAllPoints];
        }
    }
    
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setNeedsDisplay];
}

- (UIImage *)getFinalImage {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [[UIScreen mainScreen] scale]);
    
    for (int l = 0; l < stackPtr; l++) {
        if ([[history objectAtIndex:l] isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray * instance = [history objectAtIndex:l];
            
            NSInteger width = [[instance objectAtIndex:0] integerValue];
            UIColor * color = [instance objectAtIndex:1];
            [path setLineWidth:width];
            [color setStroke];
            
            for (int p = 2; p < [instance count]-3; p += 4) {
                pts[0] = [[instance objectAtIndex:p] CGPointValue];
                pts[1] = [[instance objectAtIndex:p+1] CGPointValue];
                pts[2] = [[instance objectAtIndex:p+2] CGPointValue];
                pts[3] = [[instance objectAtIndex:p+3] CGPointValue];
                
                [path moveToPoint:pts[0]];
                [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // this is how a Bezier curve is appended to a path
                [self setNeedsDisplay];
                pts[0] = [path currentPoint];
            }
            
            [path stroke];
            pts[0] = [path currentPoint]; // let the second endpoint of the current Bezier segment be the first one for the next Bezier segment
            [path removeAllPoints];
        }
    }
    
    UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (void) amendHistory
{
    for (long stack = [history count] - 1; stack >= stackPtr; stack--) {
        [history removeObjectAtIndex:stack];
    }
    stackPtr = [history count];
}

@end
