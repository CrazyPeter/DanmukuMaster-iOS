//
//  RiverRunCommentManager.h
//
//
//  Created by CrazyPeter on 2014/04/21.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
extern CGFloat const COMMENT_DURATION;
extern CGFloat const COMMENT_TOP_OR_BOTTOM_DURATION;

@protocol  RiverRunCommentManagerDelegate <NSObject>
- (CGFloat)willShowComments:(BOOL)seek;
@end

@interface  RiverRunCommentManager : NSObject
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, weak) id<RiverRunCommentManagerDelegate> delegate;

- (id)initWithComments:(NSArray*)comments delegate:(id<RiverRunCommentManagerDelegate>)delegate andPresentView:(UIView*)view videoSize:(CGSize)videoSize screenSize:(CGSize)screenSize isLandscape:(BOOL)isLandscape;
- (id)initWithComments:(NSArray*)comments delegate:(id<RiverRunCommentManagerDelegate>)delegate;
+ (id)nicoCommentManagerWithComments:(NSArray*)comments delegate:(id<RiverRunCommentManagerDelegate>)delegate;

- (void)setupPresentView:(UIView*)view videoSize:(CGSize)videoSize screenSize:(CGSize)screenSize isLandscape:(BOOL)isLandscape;
- (void)start;
- (void)stop;

- (void)deleteAllCommentLayer;
- (void)startCommentLayer;
- (void)stopCommentLayer;
- (void)seekCommentLayer:(BOOL)pause;
@end
