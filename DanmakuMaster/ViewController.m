//
//  ViewController.m
//  DanmakuMaster
//
//  Created by Peter Kong on 15-4-8.
//  Copyright (c) 2015年 CrazyPeter. All rights reserved.
//

#import "ViewController.h"
#import "RiverRunCommentUtil.h"
#import "RiverRunCommentManager.h"

@interface ViewController ()<RiverRunCommentManagerDelegate>
@property (strong, nonatomic) NSMutableArray *commentArray;
@property (strong, nonatomic) NSTimer *commentTimer;
@property (strong, nonatomic) RiverRunCommentManager *manager;
@property CGFloat commentNUM;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _commentTimer = [NSTimer timerWithTimeInterval:0.1f
                                            target:self selector:@selector(commentTimerFired)
                                          userInfo:nil repeats:YES];
    _commentNUM = 0;
    [[NSRunLoop currentRunLoop] addTimer:_commentTimer forMode:NSRunLoopCommonModes];
    self.view.backgroundColor = [UIColor colorWithRed:0.23f green:0.35f blue:0.62f alpha:1.00f];
    _commentArray = [NSMutableArray arrayWithArray:[self createVideoComment]];
    _manager = [[RiverRunCommentManager alloc]initWithComments:_commentArray delegate:self andPresentView:self.view videoSize:self.view.bounds.size screenSize:self.view.bounds.size isLandscape:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)];
}

- (CGFloat)willShowComments:(BOOL)seek {
    return _commentNUM;
}

-(void)commentTimerFired
{
    _commentNUM+=0.1;
}

- (IBAction)clickBegin:(id)sender {
    [_manager start];
}

- (IBAction)clickStop:(id)sender {
    [_manager stop];
    [_manager deleteAllCommentLayer];
    [self.commentTimer invalidate];
}

- (NSArray*)createVideoComment {
    NSInteger videoDuration = 1000;
    NSInteger commentNum = 500;
    NSMutableArray *videoComments = [NSMutableArray array];
    
    for (NSInteger i = 0; i < commentNum; i++) {
        NSInteger vpos = arc4random_uniform((unsigned int)videoDuration);
        
        NSDictionary *commentInfo = @{
                                      @"vpos": @(vpos),
                                      @"body": @"奔跑吧，弹幕！！！",
                                      @"position": @([RiverRunCommentUtil commentPosition:[RiverRunCommentUtil getRandomPosition]]),
                                      @"fontSize": @([RiverRunCommentUtil commentSize:[RiverRunCommentUtil getRandomFontSize]]),
                                      @"color": @"#ffffff",
                                      @"duration":@(3.f),
                                      };
        [videoComments addObject:commentInfo];
    }
    
    return [videoComments sortedArrayUsingComparator:^NSComparisonResult(
                                                                         NSDictionary *item1, NSDictionary *item2) {
        NSLog(@"item - %@",item1);
        
        NSInteger vpos1 = [item1[@"vpos"] intValue];
        NSInteger vpos2 = [item2[@"vpos"] intValue];
        return vpos1 > vpos2;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
