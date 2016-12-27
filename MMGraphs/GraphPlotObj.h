//
//  GraphPlotObj.h
//  MMGraphs
//
//  Created by Mahesh.me on 12/27/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphPlotObj : NSObject

//Y axis
@property (nonatomic) float value, barHeight;
//X axis
@property (nonatomic) int position;
@property (nonatomic) int64_t timeStamp;
//X axis label name
@property (nonatomic, strong) NSString *labelName;


@end
