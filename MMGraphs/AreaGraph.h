//
//  AreaGraph.h
//  MMGraphs
//
//  Created by Mahesh.me on 12/29/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphConfig.h"
#import "GraphLuminosity.h"

@interface AreaGraph : UIScrollView

- (instancetype)initWithConfigData:(GraphConfig *)configData andGraphLuminance:(GraphLuminosity *)luminance;

@end
