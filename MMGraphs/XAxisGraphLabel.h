//
//  XAxisGraphLabel.h
//  MMGraphs
//
//  Created by Mahesh.me on 12/27/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XAxisGraphLabel : UILabel

-(instancetype)initWithText:(NSString *)labelText textAlignement:(NSTextAlignment)textAlignment andTextColor:(UIColor *)textColor;
@property (nonatomic, strong) UIView *dotView;
@property (nonatomic) int position;
@property (nonatomic) int yPosition;
@property (nonatomic) float dotPading;

@end
