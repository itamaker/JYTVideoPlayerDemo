//
//  SunnyPlayerView.m
//  daydays
//
//  Created by amaker on 15/11/3.
//  Copyright © 2015年 daydays. All rights reserved.
//

#import "SunnyPlayerView.h"

@implementation SunnyPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

-(void)dealloc{
    
}

@end
