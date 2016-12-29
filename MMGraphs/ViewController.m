//
//  ViewController.m
//  MMGraphs
//
//  Created by Mahesh.me on 12/20/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import "ViewController.h"
#import "MenuView.h"
#import "GraphModel.h"

#import "InteractiveBar.h"
#import "HorizantalGraph.h"
#import "SymmetryBarGraph.h"
#import "ScatterPlotGraph.h"
#import "MultiScatterGraph.h"
#import "InteractiveLineGraph.h"
#import "AreaGraph.h"
#import "DynamicGraphs.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *menuButton, *removeGraph;
@property (nonatomic, strong) MenuView *menuView;
@property (nonatomic, strong) NSArray *arrayOfGraphs;
@property (nonatomic, strong) UIImageView *backGroundImageView;

@property (nonatomic, strong) UIScrollView *graphView;

@end

@implementation ViewController

-(void)loadView
{
    self.view = [[UIView alloc]init];
    
    _backGroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bgimage"]];
    [self.view addSubview:_backGroundImageView];
    
    _arrayOfGraphs = [[NSArray alloc]initWithObjects:@"Interactive Line", @"Interactive Bar", @"Interactive Symmetry", @"Scattert Plot",@"Multi scatter Plot", @"Area graph", @"Horizontal bar", @"Dynamic line", @"Dynamic Bar", @"Dynamic Scattert",nil];
    
    _menuButton = [[UIButton alloc]init];
    [_menuButton addTarget:self  action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
    _menuButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    [_menuButton.layer setShadowColor:[UIColor whiteColor].CGColor];
    [_menuButton.layer setShadowRadius:MINIMUM_WIDTH_OF_BUTTON/3];
    [_menuButton.layer setShadowOpacity:1];
    [self.view addSubview:_menuButton];
    
    _removeGraph = [[UIButton alloc]init];
    [_removeGraph addTarget:self  action:@selector(removeCurrentGraph) forControlEvents:UIControlEventTouchUpInside];
    _removeGraph.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    [_removeGraph.titleLabel setTextColor:[UIColor whiteColor]];
    [_removeGraph.layer setShadowColor:[UIColor whiteColor].CGColor];
    [_removeGraph setTitle:@"X" forState:UIControlStateNormal];
    [_removeGraph.layer setShadowRadius:MINIMUM_WIDTH_OF_BUTTON/3];
    [_removeGraph.layer setShadowOpacity:1];
    [self.view addSubview:_removeGraph];
    
    _removeGraph.hidden = YES;
}

-(void)viewWillLayoutSubviews
{
    self.view.frame = [UIScreen mainScreen].bounds;
    _backGroundImageView.frame = self.view.bounds;
    _menuButton.frame = CGRectMake(0, 0, MENU_SIZE.width, MENU_SIZE.height);
    _menuButton.layer.cornerRadius = _menuButton.frame.size.width/2;
    _menuButton.center = MENU_CENTER;
    _menuView.frame = self.view.bounds;
    
    _graphView.frame = CGRectMake(0, self.view.frame.size.height*0.25, self.view.frame.size.width, self.view.frame.size.height*0.5);
    _graphView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + MENU_CENTER.y);
    
    _removeGraph.frame = CGRectMake(0, _graphView.frame.origin.y - MINIMUM_WIDTH_OF_BUTTON*0.75, MINIMUM_WIDTH_OF_BUTTON, MINIMUM_HEIGHT_OF_BUTTON);
    _removeGraph.layer.cornerRadius = MINIMUM_WIDTH_OF_BUTTON/2;
    
    
    [self.view bringSubviewToFront:_menuButton];
}

-(void)menuClicked
{
    if (_menuView == nil)
    {
        _menuView = [[MenuView alloc]initWithArrayOfLabels:_arrayOfGraphs andBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        [self.view addSubview:_menuView];
        
        [_menuView.backgroundButton addTarget:self  action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
        
        for (UIButton *graphsButtons in _menuView.arrayOfGraphButtons)
            [graphsButtons addTarget:self action:@selector(graphSelectedWith:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_menuView removePath];
                             for (UIButton *menu in _menuView.arrayOfGraphButtons)
                                 menu.center = CGPointMake(-2*MENU_SIZE.width, menu.center.y);
                             
                         } completion:^(BOOL finished) {
                             [_menuView removeFromSuperview];
                             _menuView = nil;
                         }];
    }
}

-(void)removeCurrentGraph
{
    if (_graphView != nil)
    {
        [_graphView removeFromSuperview];
        _graphView =  nil;
        
        _removeGraph.hidden = YES;
    }
}


-(void)graphSelectedWith:(id)sender
{
    [self menuClicked];
    
    [self removeCurrentGraph];
    
    UIButton *clickedButton = (UIButton *)sender;
    
    if ([clickedButton.titleLabel.text isEqualToString:@"Interactive Bar"])
    {
        InteractiveBar *interaciveBar = [[InteractiveBar alloc]initWithPlotArray:[GraphModel getDataForDays:365]];
        _graphView = interaciveBar;
    }
    else if([clickedButton.titleLabel.text isEqualToString:@"Horizontal bar"])
    {
        HorizantalGraph *interaciveHorizantalBar = [[HorizantalGraph alloc]initWithPlotArray:[GraphModel getDataForDays:365]];
        _graphView = interaciveHorizantalBar;
    }
    else if([clickedButton.titleLabel.text isEqualToString:@"Interactive Symmetry"])
    {
        SymmetryBarGraph *interaciveSymmetryBar = [[SymmetryBarGraph alloc]initWithFirstPlotArray:[GraphModel getDataForDays:365] andSecondPlotArray:[GraphModel getDataForDays:365]];
        _graphView = interaciveSymmetryBar;
    }
    else if([clickedButton.titleLabel.text isEqualToString:@"Scattert Plot"])
    {
        ScatterPlotGraph *scatterPlotGraph = [[ScatterPlotGraph alloc]initWithPlotArray:[GraphModel getDataForDays:365]];
        _graphView = scatterPlotGraph;
    }
    else if([clickedButton.titleLabel.text isEqualToString:@"Multi scatter Plot"])
    {
        MultiScatterGraph *multiScatterPlotGraph = [[MultiScatterGraph alloc]initWithFirstPlotArray:[GraphModel getDataForDays:365] andSecondPlotArray:[GraphModel getDataForDays:365]];
        _graphView = multiScatterPlotGraph;
    }
    else if([clickedButton.titleLabel.text isEqualToString:@"Dynamic line"])
    {
        DynamicGraphs *interactiveLine = [[DynamicGraphs alloc]initWithTypeOfGraph:Graph_Type_Line];
        _graphView = interactiveLine;
    }
    else if([clickedButton.titleLabel.text isEqualToString:@"Interactive Line"])
    {
        InteractiveLineGraph *interactiveLine = [[InteractiveLineGraph alloc]initWithPlotArray:[GraphModel getMinuteDataFor:60]];
        _graphView = interactiveLine;
    }
    else if([clickedButton.titleLabel.text isEqualToString:@"Area graph"])
    {
        AreaGraph *areaGraph = [[AreaGraph alloc]initWithPlotArray:[GraphModel getDataForDays:30]];
        _graphView = areaGraph;
    }
    else if([clickedButton.titleLabel.text isEqualToString:@"Dynamic Bar"])
    {
        DynamicGraphs *dynamicBar = [[DynamicGraphs alloc]initWithTypeOfGraph:Graph_Type_Bar];
        _graphView = dynamicBar;
    }
    else if([clickedButton.titleLabel.text isEqualToString:@"Dynamic Scattert"])
    {
        DynamicGraphs *dynamicScattert = [[DynamicGraphs alloc]initWithTypeOfGraph:Graph_Type_Scatter];
        _graphView = dynamicScattert;
    }
    
   
    if (_graphView != nil)
    {
        [self.view addSubview:_graphView];
        _removeGraph.hidden = NO;
    }
}

@end
