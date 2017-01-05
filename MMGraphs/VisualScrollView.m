//
//  VisualScrollView.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/27/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "VisualScrollView.h"

@implementation VisualScrollView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.delegate = self;
        
        _blurrView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        [self addSubview:_blurrView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _blurrView.frame = self.bounds;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _blurrView.center = CGPointMake(scrollView.contentOffset.x + self.frame.size.width/2, self.frame.size.height/2);
}

@end
