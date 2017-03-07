//
//  InteractiveLineGraph.h
//  MMGraphs
//
//  Created by Mahesh.me on 12/28/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphConfig.h"
#import "GraphLuminosity.h"

@interface InteractiveLineGraph : UIScrollView

- (instancetype)initWithConfigData:(GraphConfig *)configData andGraphLuminance:(GraphLuminosity *)luminance;

@end
