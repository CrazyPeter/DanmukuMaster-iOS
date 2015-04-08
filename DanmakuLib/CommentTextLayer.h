//
//  CommentTextLayer.h
//  SmilePlayer2
//
//  Created by pontago on 2014/04/05.
//
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
extern NSString* const COMMENT_FONT_NAME;

typedef enum _COMMENT_POSITION {
  COMMENT_POSITION_NORMAL,
  COMMENT_POSITION_TOP,
  COMMENT_POSITION_BOTTOM
} COMMENT_POSITION;

typedef enum _COMMENT_SIZE {
  COMMENT_SIZE_NORMAL,
  COMMENT_SIZE_SMALL,
  COMMENT_SIZE_BIG
} COMMENT_SIZE;

@interface CommentTextLayer : CALayer
+ (id)layerWithCommentInfo:(NSDictionary*)commentInfo screenSize:(CGSize)screenSize isLandscape:(BOOL)isLandscape;
+(UIColor *)changeColor:(NSString *)str;
- (void)updateFrame:(CGSize)screenSize;
- (CGFloat)commentFontSize;
- (CGFloat)adjustsFontSizeToFitWidth:(CGSize)screenSize;
- (void)pauseAnimation:(BOOL)aPause;

@property (nonatomic) NSInteger vpos;
@property (nonatomic) NSInteger commentPosition;
@property (nonatomic) NSInteger commentSize;
@property (nonatomic) BOOL isLandscape;
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic) CGFloat fontSize;
@end
