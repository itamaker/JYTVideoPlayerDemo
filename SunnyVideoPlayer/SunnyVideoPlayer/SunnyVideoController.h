//
//  ViewController.h
//  SunnyVideoPlayer
//
//  Created by amaker on 15/10/14.
//  Copyright © 2015年 amaker. All rights reserved.
//

//自动隐藏工具栏时间
#define kAutoHideBarTime 3

#import <UIKit/UIKit.h>
#import "SunnyVideoBottomBar.h"
#import "SunnyVideoTopBar.h"
#import "SunnyVideoLoadingView.h"

typedef enum : NSUInteger {
    DVideoTypeLesson,//课程视频
    DVideoTypeTeahcherExp,//个人经历视频
} DVideoType;

@interface SunnyVideoController : UIViewController<SunnyVideoBottomBarDelegate,SunnyVideoLoadingViewDelegate>

@property (nonatomic, copy) NSString * videoUrl;

/**底部工具条*/
@property (nonatomic,strong ,readonly) SunnyVideoBottomBar * bottomBar;

/**顶部工具条*/
@property (nonatomic,strong ,readonly) SunnyVideoTopBar * topBar;

/**中央提示框*/
@property (nonatomic,strong ,readonly) SunnyVideoLoadingView * centerView;

/**视频背景*/
@property (nonatomic,strong) UIImageView * cbPlayerView;

/**视频类型*/
@property (nonatomic, assign) DVideoType videoType;

/**播放器大小*/
@property (nonatomic, assign) CGRect frame;

/**是否横屏幕*/
@property (nonatomic, assign) BOOL isLandscape;

/**是否自动开始播放 默认YES*/
@property (nonatomic, assign) BOOL shouldAutoplay;

+ (instancetype)videoControllerWithFrame:(CGRect)frame andVideoUrl:(NSString *)url andVideoType:(DVideoType)type isShouldAutoPlay:(BOOL)isShouldAutoPlay isLandscape:(BOOL)isLanscape;

/**设置背景图*/
- (void)setBackgroundImage:(UIImage *)image;


#pragma mark - 重写以下方法请调用super
/**点击标题按钮*/
- (void)clickTitleBtn;

/**点赞*/
- (void)clickStar;

/*点击重新播放*/
-(void)clickRetry;

/**
 *  点击播放按钮
 *
 *  @param bar     播放工具条，isPlaying属性判断是暂停还是播放。
 *  @param playBtn 播放按钮
 */
- (void)videoBottomBar:(SunnyVideoBottomBar *)bar clickPlayBtn:(UIButton *)playBtn;

#pragma mark - 进度条控制
/**拖动过程中*/
- (void)onDragSlideValueChanged:(id)sender;
/**拖动完毕*/
- (void)onDragSlideDone:(id)sender;
/**拖动开始*/
- (void)onDragSlideStart:(id)sender;

/**
 *  刷新进度方法
 *
 *  @param currentTime 播放到的时间（秒）
 *  @param allSecond   总时间
 */
- (void)playTick:(int)currentTime totalDuration:(int)allSecond;

/**开始缓冲*/
- (void)startCache;
/**结束缓冲*/
//- (void)endCache;

#pragma mark -视频控制
#pragma mark 初始化视频
- (void)initVideo;

#pragma mark 暂停视频
- (void)pauseVideo;

#pragma mark 恢复播放
- (void)playVideo;

#pragma mark 停止播放
- (void)stopVideo;


@end

