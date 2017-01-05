//
//  GraphPlotObj.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/27/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "GraphPlotObj.h"

@implementation GraphPlotObj

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _coordinate = [[Coordinates alloc]init];
    }
    return self;
}

@end
