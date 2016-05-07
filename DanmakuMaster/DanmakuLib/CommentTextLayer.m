//
//  CommentTextLayer.m
//  SmilePlayer2
//
//  Created by pontago on 2014/04/05.
//
//

#import "CommentTextLayer.h"
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

NSString* const COMMENT_FONT_NAME = @"Heiti SC";

#define HEXCOLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 \
green:((c>>8)&0xFF)/255.0 \
blue:(c&0xFF)/255.0 \
alpha:1.0];

@interface CommentTextLayer () {
}
- (UIFont*)_createFont:(CGFloat)fontSize;
- (CTFontRef)_createFontRef;
- (CTFrameRef)_createFrameRef;
- (CGImageRef)_createStrokeImageRef:(CTFrameRef)frameRef;
@end

@implementation CommentTextLayer

-(void)dealloc
{
//    NSLog(@"layer - dealloc");
}

+ (id)layerWithCommentInfo:(NSDictionary*)commentInfo screenSize:(CGSize)screenSize isLandscape:(BOOL)isLandscape {
    CommentTextLayer *commentTextLayer = [CommentTextLayer layer];
    if (commentTextLayer) {
      commentTextLayer.anchorPoint = CGPointMake(0.f, 0.f);
      commentTextLayer.drawsAsynchronously = YES;
      commentTextLayer.contentsScale = [[UIScreen mainScreen] scale];
      commentTextLayer.string = commentInfo[@"body"];
        
        UIColor *color;
        if(![commentInfo[@"color"] isEqualToString:@"-1"]){
            color = [CommentTextLayer changeColor:commentInfo[@"color"]];
        }
        else{
            color = [CommentTextLayer changeColor:@"#ffffff"];
        }
      commentTextLayer.textColor = color;

      if ([commentInfo[@"color"] intValue] == 0x000000) {
        commentTextLayer.strokeColor = [UIColor colorWithWhite:1.f alpha:0.6f];
      }
      else {
        commentTextLayer.strokeColor = [UIColor colorWithWhite:0.f alpha:0.3f];
      }

      commentTextLayer.vpos = [commentInfo[@"vpos"] intValue];
      commentTextLayer.commentPosition = [commentInfo[@"position"] intValue];
      commentTextLayer.isLandscape = isLandscape;

      NSNumber *fontSizeNum = commentInfo[@"fontSize"];
      commentTextLayer.commentSize = [fontSizeNum intValue];

      [commentTextLayer updateFrame:screenSize];
    }
    return commentTextLayer;
}

- (UIFont*)_createFont:(CGFloat)fontSize {
#if 0
    NSDictionary *fontAttributes = @{
      UIFontDescriptorNameAttribute: COMMENT_FONT_NAME,
      UIFontDescriptorCascadeListAttribute: @[ 
        [UIFontDescriptor fontDescriptorWithName:@"AppleColorEmoji" size:fontSize]
      ]
    };
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:fontAttributes];
    return [UIFont fontWithDescriptor:fontDescriptor size:fontSize];
#endif
    return [UIFont fontWithName:COMMENT_FONT_NAME size:fontSize];
}

- (CTFontRef)_createFontRef {
    CTFontDescriptorRef emojiFontDescriptorRef = CTFontDescriptorCreateWithNameAndSize(CFSTR("AppleColorEmoji"), self.fontSize);

    NSDictionary *fontAttributes = @{ 
      (id)kCTFontNameAttribute: COMMENT_FONT_NAME,
      (id)kCTFontCascadeListAttribute: @[ 
        (__bridge id)emojiFontDescriptorRef,
      ]
    };

    CTFontDescriptorRef fontDescriptorRef = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)fontAttributes);
    CTFontRef fontRef = CTFontCreateWithFontDescriptor(fontDescriptorRef, self.fontSize, NULL);

    CFRelease(fontDescriptorRef);
    CFRelease(emojiFontDescriptorRef);

    return fontRef;
}

- (CTFrameRef)_createFrameRef {
    NSString *str = self.string;
    CTFontRef fontRef = [self _createFontRef];

    CTTextAlignment alignment = kCTTextAlignmentCenter;
    CTParagraphStyleSetting paragraphStyleSettings[] = {
      { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment },
    };
    CTParagraphStyleRef paragraphStyleRef = CTParagraphStyleCreate(paragraphStyleSettings, 1);

    NSAttributedString *attrStr = [[NSAttributedString alloc] 
      initWithString:str 
          attributes:@{
            (NSString*)kCTFontAttributeName: (__bridge id)fontRef,
            (NSString*)kCTForegroundColorAttributeName: self.textColor,
            (NSString*)kCTParagraphStyleAttributeName: (__bridge id)paragraphStyleRef
          }];


    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, self.bounds);
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFMutableAttributedStringRef)attrStr);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, str.length), pathRef, NULL);

    CFRelease(fontRef);
    CGPathRelease(pathRef);
    CFRelease(framesetterRef);
    CFRelease(paragraphStyleRef);

    return frameRef;
}

- (CGImageRef)_createStrokeImageRef:(CTFrameRef)frameRef {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetTextDrawingMode(context, kCGTextStroke);
    CGContextSetLineWidth(context, 2.f);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CTFrameDraw(frameRef, context);

    CGImageRef clippingMask = CGBitmapContextCreateImage(context);

    CGContextClearRect(context, CGRectMake(0, 0, self.bounds.size.width + 2.f, self.bounds.size.height + 2.f));
    CGContextClipToMask(context, self.bounds, clippingMask);

    CGContextTranslateCTM(context, 0.0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetFillColorWithColor(context, self.strokeColor.CGColor);
    CGContextFillRect(context, self.bounds);

    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();

    CGImageRelease(clippingMask);
    return imageRef;
}

- (void)drawInContext:(CGContextRef)ctx {
    CGContextTranslateCTM(ctx, 0.0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(ctx, 1.0, -1.0);

    CTFrameRef frameRef = [self _createFrameRef];
    CGImageRef strokeImageRef = [self _createStrokeImageRef:frameRef];

    UIGraphicsPushContext(ctx);

    CGContextDrawImage(ctx, self.bounds, strokeImageRef);
    CTFrameDraw(frameRef, ctx);

    UIGraphicsPopContext();

    CGImageRelease(strokeImageRef);
    CFRelease(frameRef);
}

////////////////////////////////////////////////////////////////////////////////////////////主要是这个方法没有回收
- (void)updateFrame:(CGSize)screenSize {
    if (self.commentPosition == COMMENT_POSITION_NORMAL) {
      self.fontSize = [self commentFontSize];
      UIFont *font = [self _createFont:self.fontSize];
      CGSize textSize = [self.string 
        boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, screenSize.height)
                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                  attributes:@{ NSFontAttributeName:font }
                     context:nil].size;
      CTFontRef fontRef = [self _createFontRef];
      self.frame = CGRectMake(0, 0, textSize.width, textSize.height + CTFontGetDescent(fontRef));
      CFRelease(fontRef);
    }
    else {
      self.fontSize = [self adjustsFontSizeToFitWidth:screenSize];
      UIFont *font = [self _createFont:self.fontSize];
      CGSize textSize = [self.string 
        boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, screenSize.height)
                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                  attributes:@{ NSFontAttributeName:font }
                     context:nil].size;
      self.frame = CGRectMake(0, 0, screenSize.width, textSize.height);
    }
    [self setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)commentFontSize {
    if (self.commentSize == COMMENT_SIZE_BIG) {
      return _isLandscape ? 21.f : 17.f;
    }
    else if (self.commentSize == COMMENT_SIZE_SMALL) {
      return _isLandscape ? 16.f : 12.f;
    }
    return _isLandscape ? 19.f : 14.f;
}

- (CGFloat)adjustsFontSizeToFitWidth:(CGSize)screenSize {
    UIFont *font;
    CGFloat minFontSize = 8.f, currentFontSize = [self commentFontSize];
    CGSize textSize;

    for (; currentFontSize >= minFontSize; --currentFontSize) {
      font = [self _createFont:currentFontSize];

      textSize = [self.string 
        boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, screenSize.height)
                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                  attributes:@{ NSFontAttributeName:font }
                     context:nil].size;

      if (textSize.width < screenSize.width) {
        break;
      }
    }

    return currentFontSize;
}

- (void)pauseAnimation:(BOOL)aPause {
    if (aPause) {
      CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
      self.speed = 0.f;
      self.timeOffset = pausedTime;
    }
    else {
      CFTimeInterval pausedTime = self.timeOffset;
      self.speed = 1.f;
      self.timeOffset = 0.f;
      self.beginTime = 0.f;
      CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
      self.beginTime = timeSincePause;
    }
}

+(UIColor *)changeColor:(NSString *)str{
    unsigned int red,green,blue;
    NSString * str1 = [str substringWithRange:NSMakeRange(1, 2)];
    NSString * str2 = [str substringWithRange:NSMakeRange(3, 2)];
    NSString * str3 = [str substringWithRange:NSMakeRange(5, 2)];
    
    NSScanner * canner = [NSScanner scannerWithString:str1];
    [canner scanHexInt:&red];
    
    canner = [NSScanner scannerWithString:str2];
    [canner scanHexInt:&green];
    
    canner = [NSScanner scannerWithString:str3];
    [canner scanHexInt:&blue];
    UIColor * color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
    return color;
}

@end
