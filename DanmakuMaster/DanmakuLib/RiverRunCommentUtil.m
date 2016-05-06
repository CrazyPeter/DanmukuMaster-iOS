//
//  RiverRunCommentUtil.m
//
//
//  Created by CrazyPeter on 2014/04/05.
//
//

#import "RiverRunCommentUtil.h"

@implementation RiverRunCommentUtil
+ (NSInteger)commentPosition:(NSString*)position{
    if ([position isEqualToString:@"top"]) {
        return COMMENT_POSITION_TOP;
    }
    else if ([position isEqualToString:@"bottom"]) {
        return COMMENT_POSITION_BOTTOM;
    }
    return COMMENT_POSITION_NORMAL;
}

+ (NSInteger)commentSize:(NSString*)fontSize{
    if ([fontSize isEqualToString:@"big"]) {
        return COMMENT_SIZE_BIG;
    }
    else if ([fontSize isEqualToString:@"small"]) {
        return COMMENT_SIZE_SMALL;
    }
    return COMMENT_SIZE_NORMAL;
}

/*
 颜色数值转换:#ababab
 */
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

+ (NSString*)getRandomPosition
{
    int i = arc4random_uniform(3);
    if (i == 1) {
        return @"top";
    }
    else if(i == 2){
        return @"bottom";
    }
    else
        return @"";
}

+ (NSString*)getRandomFontSize
{
    int i = arc4random_uniform(3);
    if (i == 1) {
        return @"big";
    }
    else if(i == 2){
        return @"small";
    }
    else
        return @"";
}
@end
