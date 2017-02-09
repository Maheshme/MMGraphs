//
//  DynamicGraphs.h
//  MMGraphs
//
//  Created by Mahesh.me on 12/29/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisualScrollView.h"
#import "GraphPlotObj.h"
#import "GraphConfig.h"

typedef NS_ENUM(NSInteger, Graph_Type) {
    Graph_Type_Line,
    Graph_Type_Bar,
    Graph_Type_Scatter
};

@interface DynamicGraphs : VisualScrollView

-(void)createDataWithPlotObj:(GraphPlotObj *)plotObj;
- (instancetype)initWithConfigData:(GraphConfig *)configData typeOfGraph:(Graph_Type)typeOfGraph;

@end
