//
//  GraphModel.h
//  MMGraphs
//
//  Created by Mahesh.me on 12/27/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphPlotObj.h"

@interface GraphModel : NSObject

+(NSArray *)getDataForDays:(int)days withUpperLimit:(int)upperLimit andLowerlimit:(int)lowerLimit;
+(GraphPlotObj *)getMinuteDataInBetween:(int)lower upper:(int)upper;
+(NSArray *)getMinuteDataFor:(int)numberOfMinutes;

@end
