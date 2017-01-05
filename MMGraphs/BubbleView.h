//
//  BubbleView.h
//  MMGraphs
//
//  Created by Mahesh.me on 12/27/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Graph_Type)
{
    Graph_Type_Vertical,
    Graph_Type_Horizantal
};

@interface BubbleView : UIView

@property (nonatomic, strong) UIView *mainView, *indicationView;
@property (nonatomic, strong) UILabel *valueLabel;

-(instancetype)initWithGraphType:(Graph_Type)graphType;

@end
