//
//  GraphConfig.h
//  MMGraphs
//
//  Created by Mahesh.me on 2/7/17.
//  Copyright © 2017 Mahesh.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphPlotObj.h"
#import <UIKit/UIKit.h>

@interface GraphConfig : NSObject

@property (nonatomic) float startingX, startingY, endingX, endingY, widthOfPath, unitSpacing, maxHeightOfBar, totalBarWidth, percentageOfPlot, maxWidthOfBar;
@property (nonatomic, strong) NSArray<GraphPlotObj *> *firstPlotAraay, *secondPlotArray, *thirdPlotArray;
@property (nonatomic, strong) NSArray *colorsArray;
@property (nonatomic) BOOL xAxisLabelsEnabled;
@property (nonatomic,strong) UIFont *labelFont;

-(void)needCalluculator;

@end
