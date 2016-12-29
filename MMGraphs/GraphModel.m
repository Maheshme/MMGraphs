//
//  GraphModel.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/27/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "GraphModel.h"

@implementation GraphModel

+(NSArray *)getDataForDays:(int)days
{
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    components.day -= days;
    components.hour = 0;
    components.minute = 2;
    components.second = 0;
    
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    dateFormat.timeZone = [NSTimeZone systemTimeZone];
    if (days < 8)
        dateFormat.dateFormat = DATE_FORMAT_DAY;
    else
        dateFormat.dateFormat = DATE_FORMAT_MMM_DD;
    
    int64_t referenceTime = [[components date] timeIntervalSince1970];
    
    NSMutableArray *arrayOfPlotData = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < days; i++)
    {
        GraphPlotObj *graphObj = [[GraphPlotObj alloc]init];
        graphObj.value = [GraphModel getRandomNumberInBetween:0 upper:100];
        graphObj.position = i;
        graphObj.timeStamp = referenceTime + i*SECONDS_IN_A_DAY;
        graphObj.labelName = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:graphObj.timeStamp]];
        
        [arrayOfPlotData addObject:graphObj];
    }
    
    return (NSArray *)arrayOfPlotData;
}

//Get random numbers between two numbers
+(float)getRandomNumberInBetween:(int)lower upper:(int)upper
{
    float rndValue = lower + arc4random() % (upper - lower);
    return rndValue;
}

+(GraphPlotObj *)getMinuteDataInBetween:(int)lower upper:(int)upper forMinute:(int)min
{
    GraphPlotObj *plotObject = [[GraphPlotObj alloc]init];
    plotObject.position = min;
    plotObject.value = [GraphModel getRandomNumberInBetween:lower upper:upper];
    plotObject.timeStamp = [[NSDate date] timeIntervalSince1970];
    
    return plotObject;
}

+(NSArray *)getMinuteDataFor:(int)numberOfMinutes
{
    NSMutableArray *minuteData = [[NSMutableArray alloc]init];
    
    for (int i = 0; i <= numberOfMinutes; i++)
        [minuteData addObject: [GraphModel getMinuteDataInBetween:0 upper:100 forMinute:i]];
    
    return (NSArray *)minuteData;
}

@end
