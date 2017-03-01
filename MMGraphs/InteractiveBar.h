//
//  InteractiveBar.h
//  MMGraphs
//
//  Created by Mahesh.me on 12/27/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisualScrollView.h"
#import "GraphConfig.h"
#import "GraphLuminosity.h"

@interface InteractiveBar : UIScrollView

- (instancetype)initWithConfigData:(GraphConfig *)configData andGraphLuminance:(GraphLuminosity *)luminance;

@end
