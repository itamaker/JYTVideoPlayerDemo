//
//  ViewController.m
//  JYTVideoPlayerDemo
//
//  Created by amaker on 15/10/14.
//  Copyright © 2015年 amaker. All rights reserved.
//

#import "JYTVideoController.h"
#import <AVFoundation/AVFoundation.h>
#import "JYTPlayerView.h"


@interface JYTVideoController ()

/**视频*/
@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;
@property (nonatomic ,strong) JYTPlayerView *playerView;
@property (nonatomic ,strong) id playbackTimeObserver;

/**底部工具条*/
@property (nonatomic,strong) JYTVideoBottomBar * bottomBar;

/**顶部工具条*/
@property (nonatomic,strong) JYTVideoTopBar * topBar;

/**中央提示框*/
@property (nonatomic,strong) JYTVideoLoadingView * centerView;

/**中央播放按钮*/
@property (nonatomic,strong) UIButton * centerBtn;

/**刷新UI计时器*/
@property (nonatomic,strong) NSTimer * videoTimer;

/**是否手动设置进度*/
@property (nonatomic,assign) BOOL isManualSeek;

@property (nonatomic,assign) NSInteger lastPlayDuration;

@property (nonatomic,assign)BOOL isSetUp;

@property (nonatomic,assign)BOOL isStoped;

@end

@implementation JYTVideoController

+ (instancetype)videoControllerWithFrame:(CGRect)frame andVideoUrl:(NSString *)url andVideoType:(DVideoType)type isShouldAutoPlay:(BOOL)isShouldAutoPlay isLandscape:(BOOL)isLanscape{
    Class class = [self class];
    id vc = [[class alloc]init];
    [vc setFrame:frame];
    [vc setShouldAutoplay:isShouldAutoPlay];
    [vc setIsLandscape:isLanscape];
    [vc setVideoType:type];
    [vc setVideoUrl:url];
    return vc;
}

- (void)setBackgroundImage:(UIImage *)image{
    self.cbPlayerView.image = image;
}

-(void)setVideoUrl:(NSString *)videoUrl{
    
    _videoUrl = videoUrl;
}

#pragma mark - lazy property
-(UIImageView *)cbPlayerView{
    if (!_cbPlayerView) {
        _cbPlayerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:_cbPlayerView];
        _cbPlayerView.userInteractionEnabled = YES;
    }
    return _cbPlayerView;
}

-(JYTVideoBottomBar *)bottomBar{
    if (!_bottomBar) {
        _bottomBar = [[JYTVideoBottomBar alloc] initWithFrame:CGRectMake(0, self.cbPlayerView.frame.size.height - 50, self.cbPlayerView.frame.size.width, 50)];
        _bottomBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        [_bottomBar.videoSlider addTarget:self action:@selector(onDragSlideStart:) forControlEvents:UIControlEventTouchDown];
        [_bottomBar.videoSlider addTarget:self action:@selector(onDragSlideDone:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBar.videoSlider addTarget:self action:@selector(onDragSlideValueChanged:) forControlEvents:UIControlEventValueChanged];
        _bottomBar.delegate = self;
        [self.cbPlayerView insertSubview:_bottomBar atIndex:2];
    }
    return _bottomBar;
}

-(JYTVideoTopBar *)topBar{
    if(self.videoType == DVideoTypeTeahcherExp)return nil;
    if (!_topBar) {
        _topBar = [[JYTVideoTopBar alloc] initWithFrame:CGRectMake(0, 0, self.cbPlayerView.frame.size.width, 50)];
        _topBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7];
        [_topBar.backBtn addTarget:self action:@selector(clickTitleBtn) forControlEvents:UIControlEventTouchUpInside];
        [_topBar.starBtn addTarget:self action:@selector(clickStar) forControlEvents:UIControlEventTouchUpInside];
        [self.cbPlayerView insertSubview:_topBar atIndex:2];
    }
    return _topBar;
}

- (JYTVideoLoadingView *)centerView{
    if (!_centerView) {
        CGRect frame = CGRectMake(0, 0, 200, 100);
        if (self.videoType == DVideoTypeTeahcherExp) {
            frame = CGRectMake(0, 0, 150, 75);
        }
        kLoadType type = self.videoType == DVideoTypeLesson ? kLoadLarge:kLoadNomal;
        _centerView = [[JYTVideoLoadingView alloc] initWithFrame:frame andLoadType:type];
        _centerView.center = self.cbPlayerView.center;
        _centerView.hidden = YES;
        _centerView.delegate = self;
        [self.cbPlayerView addSubview:_centerView];
    }
    return _centerView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.bottomBar.alpha) {
        [self showBar:YES];
    }else{
        [self hideBar];
    }
}

#pragma mark - topBar 点击事件
/**点击标题按钮*/
- (void)clickTitleBtn{
    [self stopVideo];
    if(self.videoType == DVideoTypeLesson)
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(self.presentationController){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/**点赞*/
- (void)clickStar{
    self.topBar.starBtn.selected = !self.topBar.starBtn.selected;
}

#pragma mark -工具条显示隐藏
- (void)showBar:(BOOL)isLoop{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.cbPlayerView bringSubviewToFront:self.bottomBar];
    [self.cbPlayerView bringSubviewToFront:self.topBar];
    self.cbPlayerView.userInteractionEnabled = YES;
    self.bottomBar.userInteractionEnabled = YES;
    self.topBar.userInteractionEnabled = YES;
    [UIView animateWithDuration:.2 animations:^{
        self.bottomBar.alpha = 1;
        self.topBar.alpha = 1;
    } completion:^(BOOL finished){
        if(isLoop){
            [self performSelector:@selector(hideBarLoop) withObject:nil afterDelay:kAutoHideBarTime inModes:@[NSRunLoopCommonModes]];
        }
    }];
}

- (void)hideBar{
    [UIView animateWithDuration:.2 animations:^{
        self.bottomBar.alpha = 0;
        self.topBar.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)hideBarLoop{
    [self hideBar];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideBarLoop) withObject:nil afterDelay:kAutoHideBarTime inModes:@[NSRunLoopCommonModes]];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(self.videoType == DVideoTypeLesson)
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

#pragma mark - VIEWDIDLOAD
- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.videoType == DVideoTypeLesson)
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    if(!CGRectIsEmpty(self.frame)){
        self.view.frame = self.frame;
    }
    else{
        self.frame = self.view.frame;
    }
    self.cbPlayerView.image = [UIImage imageNamed:@"movie_background"];
    
    if(self.videoUrl && self.shouldAutoplay){
        [self setUpVideo];
    }
    if(self.videoType == DVideoTypeTeahcherExp){
        self.centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cbPlayerView addSubview:self.centerBtn];
        self.centerBtn.frame = CGRectMake(0, 0, 40, 40);
        self.centerBtn.center = self.cbPlayerView.center;
        [self.centerBtn setImage:[UIImage imageNamed:@"movie_bigPlay"] forState:UIControlStateNormal];
        [self.centerBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    }

}

#pragma mark - 百度视频初始化
- (void)setUpVideo
{
    if(self.isSetUp){
        return;
    }
    [self stopVideo];
    [self.centerView showLoading];
    if (!self.playerView) {
        self.playerView = [[JYTPlayerView alloc]initWithFrame:self.frame];
        [self.cbPlayerView insertSubview:self.playerView atIndex:1];
    }
    NSURL *url = [NSURL URLWithString:self.videoUrl];
    if (!url)
    {
        url = [NSURL URLWithString:[self.videoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    AVPlayerLayer * pl = (AVPlayerLayer *)self.playerView.layer;
    pl.videoGravity = AVLayerVideoGravityResize;
    self.playerView.player = _player;
    
    if(self.shouldAutoplay){
        [self.player play];
        self.bottomBar.isPlay = YES;
        [self showBar:YES];
    }
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playbackFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startCaching:) name:AVPlayerItemPlaybackStalledNotification object:_playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    self.isSetUp = YES;
}

#pragma mark -播放kvo
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver = [self.playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        if (weakSelf.isManualSeek) {
            return ;
        }
        [weakSelf.centerView hide];
        weakSelf.isStoped = NO;
        CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
        CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;
        [weakSelf refreshProgress:currentSecond totalDuration:totalSecond isDrag:NO];
    }];
}

// KVO方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            //            self.stateButton.enabled = YES;
            [self initVideo];
            CMTime duration = self.playerItem.duration;// 获取视频总长度
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒
            [self refreshProgress:0 totalDuration:totalSecond isDrag:NO];
            NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));
            [self monitoringPlayback:self.playerItem];// 监听播放状态
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
            [self playbackError];
            self.isSetUp = NO;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        NSLog(@"Time Interval:%f",timeInterval);
        CMTime duration = _playerItem.duration;
        self.bottomBar.videoSlider.subValue = timeInterval;
        
    }
}

#pragma mark - 计算缓冲进度
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.playerView.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - 进度条控制
- (void)onDragSlideValueChanged:(id)sender {
    UISlider * s = sender;
    NSLog(@"slide changing, %f", s.value);
    if (!self.isSetUp) {
        return;
    }
    CGFloat totalSecond = self.playerItem.duration.value / self.playerItem.duration.timescale;
    [self refreshProgress:s.value totalDuration:totalSecond isDrag:YES];
}

- (void)onDragSlideDone:(id)sender{
    self.isManualSeek = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideBarLoop) withObject:nil afterDelay:kAutoHideBarTime inModes:@[NSRunLoopCommonModes]];
    UISlider * s = sender;
    CMTime changedTime = CMTimeMakeWithSeconds(s.value, 1);
    
    __weak typeof(self) weakSelf = self;
    [self.playerView.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        [weakSelf playVideo];
    }];
    
}
- (void)onDragSlideStart:(id)sender {
    self.isManualSeek = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)playTick:(int)currentTime totalDuration:(int)allSecond{}

- (void)refreshProgress:(int) currentTime totalDuration:(int)allSecond isDrag:(BOOL)drag{
    NSDictionary* dict = [[self class] convertSecond2HourMinuteSecond:currentTime];
    self.bottomBar.leftTimeLbl.text = [NSString stringWithFormat:@"%@:%@",dict[@"minute"],dict[@"second"]];
    //    currentProgress.text = strPlayedTime;
    if(!drag){
        self.bottomBar.videoSlider.value = currentTime;
        self.bottomBar.videoSlider.maximumValue = allSecond;
        [self playTick:currentTime totalDuration:allSecond];
    }
    NSDictionary* dictLeft = [[self class] convertSecond2HourMinuteSecond:allSecond];
    self.bottomBar.rightTimeLbl.text = [NSString stringWithFormat:@"%@:%@",dictLeft[@"minute"],dictLeft[@"second"]];
    
}

- (NSString*)getTimeString:(NSDictionary*)dict prefix:(NSString*)prefix
{
    int hour = [[dict objectForKey:@"hour"] intValue];
    int minute = [[dict objectForKey:@"minute"] intValue];
    int second = [[dict objectForKey:@"second"] intValue];
    
    NSString* formatter = hour < 10 ? @"0%d" : @"%d";
    NSString* strHour = [NSString stringWithFormat:formatter, hour];
    
    formatter = minute < 10 ? @"0%d" : @"%d";
    NSString* strMinute = [NSString stringWithFormat:formatter, minute];
    
    formatter = second < 10 ? @"0%d" : @"%d";
    NSString* strSecond = [NSString stringWithFormat:formatter, second];
    
    return [NSString stringWithFormat:@"%@%@:%@:%@", prefix, strHour, strMinute, strSecond];
}

+ (NSDictionary*)convertSecond2HourMinuteSecond:(int)second
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    int minute = 0;
    
    minute = second / 60;
    second = second -  minute *  60;
    
    if(minute < 10)
    {
        [dict setObject:[NSString stringWithFormat:@"0%d",minute] forKey:@"minute"];
    }else{
        [dict setObject:[NSString stringWithFormat:@"%d",minute] forKey:@"minute"];
    }
    if(second < 10){
        [dict setObject:[NSString stringWithFormat:@"0%d",second] forKey:@"second"];
    }else{
        [dict setObject:[NSString stringWithFormat:@"%d",second] forKey:@"second"];
    }
    
    return dict;
}

#pragma mark - 视频通知方法
#pragma mark 播放出错
- (void) playbackError{
    [self.centerView showRetry:YES];
}
#pragma mark 播放完毕
- (void)playbackFinish:(NSNotification *)noti{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bottomBar.isPlay = NO;
        self.isStoped = YES;
        [self.centerView showRetry:NO];
        [self showBar:NO];
    });
}
#pragma mark 开始缓冲
- (void)startCaching:(NSNotification *)noti{
    [self startCache];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.centerView showLoading];
    });
}

- (void)startCache{}
- (void)endCache{}

#pragma mark 缓冲中
- (void)goCaching:(NSNotification *)noti{
    if ([noti.object integerValue] >= 100) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.centerView hide];
        });
    }
}



//#pragma mark 网速回调
//- (void) showNetworkStatus: (NSNotification*) aNotifycation
//{
//
//    int networkBitrateValue = [[aNotifycation object] intValue];
//    NSLog(@"show network bitrate is %d\n", networkBitrateValue);
//    int Kbit = 1024;
//    int Mbit = 1024*1024;
//    int networkBitrate = 0;
//    if (networkBitrateValue > Mbit){
//        networkBitrate = networkBitrateValue/Mbit;
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//        });
//    } else if (networkBitrateValue > Kbit){
//        networkBitrate = networkBitrateValue/Kbit;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.centerView.netWorkLabel.text = [NSString stringWithFormat:@"%dKB/s",networkBitrate];
//        });
//    } else {
//        networkBitrate = networkBitrateValue;
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//        });
//    }
//
//}

#pragma mark - centerview delegate
-(void)clickRetry{
    [self showBar:YES];
    [self playVideo];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 初始化视频
- (void)initVideo{
    //初始化视频文件
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self.centerView showLoading];
    self.bottomBar.isPlay = YES;
}

#pragma mark 暂停视频
- (void)pauseVideo{
    //如果当前正在播放视频时，暂停播放。
    self.bottomBar.isPlay = NO;
    [self.playerView.player pause];
}

#pragma mark 恢复播放
- (void)playVideo{
    [self setUpVideo];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.centerBtn.hidden = YES;
    if (self.isStoped) {//播放到最后
        [self.playerView.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        }];
    }
    if(self.videoUrl){
        self.bottomBar.isPlay = YES;
        //如果当前播放视频已经暂停，重新开始播放。
        [self.playerView.player play];
    }
    else{
        [self.centerView showRetry:YES];
    }
}

#pragma mark 停止播放
- (void)stopVideo{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.isSetUp = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[_player currentItem] removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [[_player currentItem] removeObserver:self forKeyPath:@"status" context:nil];
    [_player removeTimeObserver:_playbackTimeObserver];
    [_player replaceCurrentItemWithPlayerItem:nil];
    [_playerView removeFromSuperview];
    _playerItem = nil;
    _player = nil;
    _playerView = nil;
}



#pragma mark -bottomBar delegate
- (void)videoBottomBar:(JYTVideoBottomBar *)bar clickPlayBtn:(UIButton *)playBtn
{
    if (bar.isPlay) {
        [self playVideo];
    }else{
        [self pauseVideo];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)willResignActive
{
    [self pauseVideo];
}
- (void)didBecomeActive
{
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if(self.isLandscape)
        return UIInterfaceOrientationMaskLandscapeRight;
    else
        return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //设置横屏播放
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        if(self.isLandscape)
            return YES;
    }
    return NO;
}


@end
