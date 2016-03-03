//
//  SunnyVideoBottomBar.h
//  SunnyVideoPlayer
//
//  Created by amaker on 15/10/14.
//  Copyright © 2015年 amaker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SunnyVideoSlider.h"
@class SunnyVideoBottomBar;

@protocol SunnyVideoBottomBarDelegate <NSObject>

/**
 *  点击播放按钮
 *
 *  @param bar     工具条
 *  @param playBtn 播放按钮
 */
- (void)videoBottomBar:(SunnyVideoBottomBar *)bar clickPlayBtn:(UIButton *)playBtn;

@end

@interface SunnyVideoBottomBar : UIView

@property (nonatomic, strong) UIButton * playBtn;
@property (nonatomic, strong) UILabel * leftTimeLbl;
@property (nonatomic, strong) UILabel * rightTimeLbl;
@property (nonatomic, strong) SunnyVideoSlider * videoSlider;
@property (nonatomic, assign) BOOL isPlay;

@property (nonatomic, weak) id<SunnyVideoBottomBarDelegate> delegate;

@end
