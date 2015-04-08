//
//  RiverRunCommentManager.m
//
//
//  Created by CrazyPeter on 2014/04/21.
//
//

#import "RiverRunCommentManager.h"
#import "CommentTextLayer.h"
#include <objc/runtime.h>

CGFloat const COMMENT_DURATION                = 5.f;
CGFloat const COMMENT_TOP_OR_BOTTOM_DURATION  = 3.f;

@interface RiverRunCommentManager () {
  UIView *_view;
  CGSize _screenSize, _videoSize;
  NSTimer *_commentTimer;
  NSInteger _currentIndex;
  CGFloat _moviePosition;
  BOOL _isLandscape;
  NSMutableArray *_showCommentItems;
    CGFloat _totalsize;
}
- (CGSize)_sizeInOrientation;

- (void)_commentTimerFired:(NSTimer*)timer;
- (BOOL)_createCommentLayer:(NSDictionary*)comment setPosition:(BOOL)setPosition pause:(BOOL)pause andDuration:(NSTimeInterval)duration_form_data;
- (void)_addShowCommentItem:(NSDictionary*)commentItem;
- (BOOL)_checkCollisionHeight:(CGRect)rect targetRect:(CGRect)targetRect;
- (BOOL)_checkCollisionWidth:(CGRect)rect targetRect:(CGRect)targetRect;
- (void)_deleteCommentLayer;
@end

@implementation RiverRunCommentManager
- (id)init {
    self = [super init];
    if (self) {
      _showCommentItems = [NSMutableArray array];
      _currentIndex = 0;
      _isLandscape = NO;
    }
    return self;
}

- (id)initWithComments:(NSArray*)comments delegate:(id<RiverRunCommentManagerDelegate>)delegate andPresentView:(UIView*)view videoSize:(CGSize)videoSize screenSize:(CGSize)screenSize isLandscape:(BOOL)isLandscape{
    {
        self = [self init];
        if (self) {
            _comments = comments;
            _delegate = delegate;
        }
        [self setupPresentView:view videoSize:videoSize screenSize:screenSize isLandscape:isLandscape];
        return self;
    }
}

- (id)initWithComments:(NSArray*)comments delegate:(id<RiverRunCommentManagerDelegate>)delegate {
    self = [self init];
    if (self) {
      _comments = comments;
      _delegate = delegate;
    }

    return self;
}

+ (id)nicoCommentManagerWithComments:(NSArray*)comments delegate:(id<RiverRunCommentManagerDelegate>)delegate {
    return [[RiverRunCommentManager alloc] initWithComments:comments delegate:delegate];
}

- (void)dealloc {
    NSLog(@"NicoCommentManager dealloc");
}

- (CGSize)_sizeInOrientation {
    UIApplication *application = [UIApplication sharedApplication];
    UIInterfaceOrientation orientation = application.statusBarOrientation;
    CGSize size = [UIScreen mainScreen].bounds.size;

    if (UIInterfaceOrientationIsLandscape(orientation)) {
      size = CGSizeMake(size.height, size.width);
    }

    return size;
}

- (void)setupPresentView:(UIView*)view videoSize:(CGSize)videoSize screenSize:(CGSize)screenSize isLandscape:(BOOL)isLandscape {
    _view = view;
    _videoSize = videoSize;
    _screenSize = screenSize;
    _isLandscape = isLandscape;

    if (isnan(_screenSize.width) || isnan(_screenSize.height)) {
      _screenSize = [self _sizeInOrientation];
    }
}

- (void)start {
    if (!_commentTimer) {
      _commentTimer = [NSTimer timerWithTimeInterval:0.5f
        target:self selector:@selector(_commentTimerFired:) 
        userInfo:nil repeats:YES];
      [[NSRunLoop currentRunLoop] addTimer:_commentTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)stop {
    [_commentTimer invalidate];
    _commentTimer = nil;

    [self _deleteCommentLayer];
}

- (void)_commentTimerFired:(NSTimer*)timer {
    if (_delegate) {
      _moviePosition = [_delegate willShowComments:NO];
    }
    if (_moviePosition == -1) return;

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    [self _deleteCommentLayer];

    CGFloat currentTime = floor(_moviePosition * 1000.f);
    NSInteger max = [_comments count];

    for (NSInteger i = _currentIndex; i < max; i++) {
      NSDictionary *comment = _comments[i];

      if (currentTime >= [comment[@"vpos"] floatValue]) {
        [self _createCommentLayer:comment setPosition:NO pause:NO andDuration: [comment[@"duration"] floatValue]];

        if ((i + 1) == max) {
          _currentIndex = i + 1;
        }
      }
      else {
        _currentIndex = i;
        break;
      }
    }

    [CATransaction commit];
}

- (BOOL)_createCommentLayer:(NSDictionary*)comment setPosition:(BOOL)setPosition pause:(BOOL)pause andDuration:(NSTimeInterval)duration_form_data{
    CGPoint commentOffset;

    CGFloat px = _screenSize.width;
    CGFloat py = 0, ty = 0;
    CGFloat videoTop = floor((_view.bounds.size.height / 2) - (_screenSize.height / 2));
    CGFloat videoBottom = floor(videoTop + _screenSize.height);
    BOOL isDanmaku = NO;
    NSTimeInterval duration;

    py = videoTop;

    CommentTextLayer *commentTextLayer = [CommentTextLayer 
      layerWithCommentInfo:comment 
                screenSize:_screenSize
               isLandscape:_isLandscape];


    NSInteger commentPosition = [comment[@"position"] intValue];
    if (commentPosition == COMMENT_POSITION_NORMAL) {
        if (duration_form_data==0) {
            duration = COMMENT_DURATION;
        }
        else{
            duration = duration_form_data;
        }
    }
    else {
        if (duration_form_data==0) {
            duration = COMMENT_DURATION;
        }
        else{
            duration = duration_form_data;
        }
        px = 0.f;
      if (commentPosition == COMMENT_POSITION_BOTTOM) {
        py = videoBottom - commentTextLayer.frame.size.height;
      }
    }
    commentOffset = CGPointMake(px, py);


    @synchronized(_showCommentItems) {
      CGRect rect, targetRect;
      rect.size = commentTextLayer.frame.size;

      for (NSDictionary *item in _showCommentItems) {
        rect.origin = commentOffset;

        CommentTextLayer *showCommentTextLayer = item[@"commentTextLayer"];
        CALayer *layer = showCommentTextLayer.presentationLayer;
        if (layer) {
          targetRect.origin = layer.position;
        }
        else {
          targetRect.origin = showCommentTextLayer.position;
        }
        targetRect.size = showCommentTextLayer.frame.size;

        if (commentPosition == COMMENT_POSITION_TOP) {
          if (showCommentTextLayer.commentPosition != COMMENT_POSITION_TOP) continue;

          if ([self _checkCollisionHeight:rect targetRect:targetRect]) {
            ty = CGRectGetHeight(targetRect);
            commentOffset = CGPointMake(px, targetRect.origin.y + ty);
          }

          if ((commentOffset.y + ty) > videoBottom) {
            isDanmaku = YES; 
            break;
          }
        }
        else if (commentPosition == COMMENT_POSITION_BOTTOM) {
          if (showCommentTextLayer.commentPosition != COMMENT_POSITION_BOTTOM) continue;

          if ([self _checkCollisionHeight:rect targetRect:targetRect]) {
            ty = CGRectGetHeight(targetRect);
            commentOffset = CGPointMake(px, targetRect.origin.y - ty);
          }

          if ((commentOffset.y - ty) < videoTop) {
            isDanmaku = YES; 
            break;
          }
        }
        else if (commentPosition == COMMENT_POSITION_NORMAL) {
          if (showCommentTextLayer.commentPosition != COMMENT_POSITION_NORMAL) continue;

          if ([self _checkCollisionHeight:rect targetRect:targetRect]) {
            if ([self _checkCollisionWidth:rect targetRect:targetRect]) {
              ty = CGRectGetHeight(targetRect);
              commentOffset = CGPointMake(px, targetRect.origin.y + ty);
            }
            if ((commentOffset.y + ty) > videoBottom) {
              isDanmaku = YES; 
              break;
            }
          }
        }
      }
    }

    if (isDanmaku) {
      NSInteger y = arc4random_uniform(_screenSize.height - CGRectGetHeight(commentTextLayer.frame));
      commentOffset = CGPointMake(px, py + y);
    }

    commentTextLayer.position = commentOffset;
    [self _addShowCommentItem:@{
      @"commentTextLayer": commentTextLayer,
      @"duration": @(duration),
    }];

    [_view.layer addSublayer:commentTextLayer];

    if (commentPosition == COMMENT_POSITION_NORMAL) {
        
      CGFloat animateDuration;
        
        if (duration_form_data == 0) {
            animateDuration = COMMENT_DURATION;
        }
        else{
            animateDuration = duration_form_data;
        }
        
        //正常弹幕
      if (setPosition) {
        CGFloat currentTime = _moviePosition * 1000.f;
        CGFloat diff = (currentTime - commentTextLayer.vpos) / 1000.f;
        CGFloat perWidth = (_screenSize.width + commentTextLayer.frame.size.width) / animateDuration;
        commentOffset.x = (_screenSize.width) - (perWidth * diff);
        animateDuration = animateDuration - diff;
      }

      CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
      animation.repeatCount = 0;
      animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
      animation.duration = animateDuration;
      animation.removedOnCompletion = NO;
      animation.fillMode = kCAFillModeForwards;

      animation.fromValue = [NSValue valueWithCGPoint:commentOffset];
      commentOffset.x = -commentTextLayer.frame.size.width;
      animation.toValue = [NSValue valueWithCGPoint:commentOffset];

      [commentTextLayer addAnimation:animation forKey:@"Comment"];

      if (pause) {
        [self stopCommentLayer];
      }
    }

    return YES;
}

- (void)_addShowCommentItem:(NSDictionary*)commentItem {
    CommentTextLayer *commentTextLayer = commentItem[@"commentTextLayer"];

    @synchronized(_showCommentItems) {
      if (commentTextLayer.commentPosition == COMMENT_POSITION_NORMAL) {
        NSInteger max = [_showCommentItems count];

        for (NSInteger i = (max - 1); i >= 0; i--) {
          CommentTextLayer *showCommentTextLayer = _showCommentItems[i][@"commentTextLayer"];

          if (showCommentTextLayer.commentPosition != COMMENT_POSITION_NORMAL) continue;

          if (commentTextLayer.position.y >= showCommentTextLayer.position.y) {
            [_showCommentItems insertObject:commentItem atIndex:(i + 1)];
            return;
          }
        }
      }

      [_showCommentItems addObject:commentItem];
    }
}

- (BOOL)_checkCollisionHeight:(CGRect)rect targetRect:(CGRect)targetRect {
    CGFloat commentTop1 = rect.origin.y;
    CGFloat commentBottom1 = rect.origin.y + rect.size.height;
    CGFloat commentTop2 = targetRect.origin.y;
    CGFloat commentBottom2 = targetRect.origin.y + targetRect.size.height;

    BOOL b1 = (commentTop1 >= commentTop2 && commentTop1 <= commentBottom2) ||
        (commentBottom1 >= commentTop2 && commentBottom1 <= commentBottom2);
    BOOL b2 = (commentTop2 >= commentTop1 && commentTop2 <= commentBottom1) ||
        (commentBottom2 >= commentTop1 && commentBottom2 <= commentBottom1);

    return (b1 || b2);
}

- (BOOL)_checkCollisionWidth:(CGRect)rect targetRect:(CGRect)targetRect {
    CGSize screenSize = _screenSize;
    CGFloat perWidth = (screenSize.width + rect.size.width) / COMMENT_DURATION;
    CGFloat perWidth2 = (screenSize.width + targetRect.size.width) / COMMENT_DURATION;

    CGFloat targetFinishPosition, finishPosition;
    CGFloat add = COMMENT_DURATION / 3;
    CGFloat max = add * 3;

    for (CGFloat i = 0; i <= max; i += add) {
      targetFinishPosition =  targetRect.origin.x - (perWidth2 * i) + targetRect.size.width;

      if (targetFinishPosition <= -targetRect.size.width) break;

      finishPosition = screenSize.width - (perWidth * i);

      if (targetFinishPosition > finishPosition) {
        return YES;
      }
    }

    return NO;
}

- (void)_deleteCommentLayer {
    CGFloat currentTime = floor(_moviePosition * 1000.f);
    NSMutableArray *deleteItems = [NSMutableArray array];

    @synchronized(_showCommentItems) {
      for (NSDictionary *item in _showCommentItems) {
        CommentTextLayer *commentTextLayer = item[@"commentTextLayer"];
        CALayer *layer = commentTextLayer.presentationLayer;
        if (commentTextLayer.commentPosition == COMMENT_POSITION_NORMAL) {
          if (layer.frame.origin.x <= -commentTextLayer.frame.size.width) {
            [commentTextLayer removeFromSuperlayer];
            [deleteItems addObject:item];
          }
        }
        else {
          if (currentTime > (CGFloat)(commentTextLayer.vpos + [item[@"duration"] doubleValue] * 1000.0)) {
              NSLog(@"commentTextLayer.vpos - %ld,duration - %lf",(long)commentTextLayer.vpos,[item[@"duration"] doubleValue] * 1000.0);
            [commentTextLayer removeFromSuperlayer];
            [deleteItems addObject:item];
          }
        }
      }
      [_showCommentItems removeObjectsInArray:deleteItems];
    }
    deleteItems = nil;
}

- (void)deleteAllCommentLayer {
    @synchronized(_showCommentItems) {
      for (NSDictionary *item in _showCommentItems) {
        CommentTextLayer *commentTextLayer = item[@"commentTextLayer"];
        [commentTextLayer removeFromSuperlayer];
      }
      [_showCommentItems removeAllObjects];
    }
}

- (void)startCommentLayer {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    @synchronized(_showCommentItems) {
      for (NSDictionary *item in _showCommentItems) {
        CommentTextLayer *commentTextLayer = item[@"commentTextLayer"];
        [commentTextLayer pauseAnimation:NO];
      }
    }

    [CATransaction commit];
}

- (void)stopCommentLayer {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    @synchronized(_showCommentItems) {
      for (NSDictionary *item in _showCommentItems) {
        CommentTextLayer *commentTextLayer = item[@"commentTextLayer"];
        [commentTextLayer pauseAnimation:YES];
      }
    }

    [CATransaction commit];
}

- (void)seekCommentLayer:(BOOL)pause {
    if (_delegate) {
      _moviePosition = [_delegate willShowComments:YES];
    }
    if (_moviePosition == -1) return;
    [self deleteAllCommentLayer];
    CGFloat currentTime = floor(_moviePosition * 1000.f);
    CGFloat normalCommentTime = currentTime - (COMMENT_DURATION * 1000.f);
    CGFloat topBottomCommentTime = currentTime - (COMMENT_TOP_OR_BOTTOM_DURATION * 1000.f);
    NSInteger max = [_comments count];
    NSInteger i;

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    _currentIndex = 0;

    for (i = 0; i < max; i++) {
      NSDictionary *comment = _comments[i];

      if (currentTime < [comment[@"vpos"] floatValue]) {
        _currentIndex = i;
        break;
      }

      if (normalCommentTime < [comment[@"vpos"] floatValue] && [comment[@"position"] intValue] == COMMENT_POSITION_NORMAL) {
        [self _createCommentLayer:comment setPosition:YES pause:pause andDuration:[comment[@"duration"] floatValue] ];
      }
      else if (topBottomCommentTime < [comment[@"vpos"] floatValue] && [comment[@"position"] intValue] != COMMENT_POSITION_NORMAL) {
        [self _createCommentLayer:comment setPosition:NO pause:pause andDuration:[comment[@"duration"] floatValue]];
      }
    }

    _currentIndex = i;

    [CATransaction commit];
}
@end
