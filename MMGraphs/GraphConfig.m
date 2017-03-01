//
//  GraphConfig.m
//  MMGraphs
//
//  Created by Mahesh.me on 2/7/17.
//  Copyright © 2017 Mahesh.me. All rights reserved.
//

#import "GraphConfig.h"

@implementation GraphConfig

-(instancetype)init
{
    self = [super init];
    if (self)
        _xAxisLabelsEnabled = YES;
    
    return self;
}

-(void)needCalluculator
{
    _maxHeightOfBar = _startingY - _endingY;
    _maxWidthOfBar = _endingX - _startingX;
    _totalBarWidth = _widthOfPath+_unitSpacing;
    _percentageOfPlot = _widthOfPath/_totalBarWidth;
        
    if (_labelFont == nil)
        _labelFont = [UIFont systemFontOfSize:12];
}

@end
