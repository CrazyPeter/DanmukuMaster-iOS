//
//  RiverRunCommentUtil.h
//  SmilePlayer2
//
//  Created by CrazyPeter on 2014/04/05.
//
//

#import <Foundation/Foundation.h>
#import "CommentTextLayer.h"

@interface RiverRunCommentUtil : NSObject
+ (NSInteger)commentPosition:(NSString*)position;
+ (NSInteger)commentSize:(NSString*)fontSize;
+ (NSString*)getFontSize;
+ (NSString*)getPosition;
@end
