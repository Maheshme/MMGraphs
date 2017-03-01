//
//  GraphLuminosity.h
//  MMGraphs
//
//  Created by Mahesh.me on 2/19/17.
//  Copyright © 2017 Mahesh.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GraphLuminosity : NSObject

@property (nonatomic, strong) UIColor *backgroundColor, *bubbleTextColor, *labelTextColor;
@property (nonatomic, strong) NSArray *gradientColors, *bubbleColors;
@property (nonatomic, strong) UIFont *labelFont, *bubbleFont;

@end
