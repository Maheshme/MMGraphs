//
//  InteractiveLineGraph.h
//  MMGraphs
//
//  Created by Mahesh.me on 12/28/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisualScrollView.h"
#import "GraphConfig.h"

@interface InteractiveLineGraph : VisualScrollView

- (instancetype)initWithConfigData:(GraphConfig *)configData;

@end
