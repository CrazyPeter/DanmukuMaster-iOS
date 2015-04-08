# CrazyPeter

弹幕引擎，使用coretext编写。
其实是截取的niconico的部分代码，并且加上了时间控制。

参数定义：

每个弹幕的参数为  NSDictionary *commentInfo = @{
                                      @"vpos": @(vpos),
                                      @"body": @“Hello World！！！",
                                      @"position": @([RiverRunCommentUtil commentPosition:[self getPosition]]),
                                      @"fontSize": @([RiverRunCommentUtil commentSize:[self getFontSize]]),
                                      @"color": @"#ffffff",
                                      @"duration":@(3.f),
                                      };


vpos：是开始出现的时间，以毫秒为单位，和服务器返回数据格式相反   数据类型int
body：弹幕内容 数据类型string
position：固定string字符，top或者bottom是停留在屏幕上下两端的，其他是正常飘过的弹幕  
“top” 	
“bottom” 
“”（其他）  

fontSize：字体大小，数据类型int
color：颜色，格式：#ffffff, 数据类型string
duration：动画时间 数据类型float

ps：定义的随机数相关
获得位置的随机数可用[RiverRunCommentUtil getPosition]，
如  @"position": @([RiverRunCommentUtil commentPosition:[RiverRunCommentUtil getPosition]])
获得fontsize随机数可用[RiverRunCommentUtil getFontSize]
如：@"fontSize": @([RiverRunCommentUtil commentSize:[RiverRunCommentUtil getFontSize]])



方法定义：

1.首先定义一个全局变量：
RiverRunCommentManager *_manger;
2.初始化弹幕
 _manger = [[RiverRunCommentManager alloc]initWithComments:_commentArray delegate:self andPresentView:self.view videoSize:self.view.bounds.size screenSize:self.view.bounds.size isLandscape:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)];
3.写好回调方法，返回值为当前播放时间，以s为单位
- (CGFloat)willShowComments:(BOOL)seek {
    return _commentNUM;
}
4.开启屏幕翻转时适应
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [_manger setupPresentView:self.view
                    videoSize:self.view.bounds.size
                   screenSize: self.view.bounds.size
                  isLandscape:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)];
}
5.开启弹幕
    [_manger start];
6.暂时关闭弹幕 
   [_manger stop];
   [_manger deleteAllCommentLayer];
7.重新开启
    _manger.comments = _commentArray;（更新弹幕）
    [_manger start];
8.退出时调用的方法
 [_manger stop];
 _manger = nil;
