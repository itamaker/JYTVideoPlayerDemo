//
//  JYTPlayerView.m
//  daydays
//
//  Created by amaker on 15/11/3.
//  Copyright © 2015年 daydays. All rights reserved.
//

#import "JYTPlayerView.h"

@implementation JYTPlayerView

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
