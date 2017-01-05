//
//  VisualScrollView.h
//  MMGraphs
//
//  Created by Mahesh.me on 12/27/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisualScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) UIVisualEffectView *blurrView;

@end
