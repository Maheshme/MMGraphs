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

@interface ViewController ()

@property (nonatomic, strong) UIButton *menuButton;
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
    
    _arrayOfGraphs = [[NSArray alloc]initWithObjects:@"Interactive Line",@"Interactive Bar", @"Interactive Symmetry", @"Scattert Plot",@"Multi scatter Plot", @"Stacked bar", @"Area graph", @"Horizontal bar", @"Dynamic line", @"Dynamic Bar", @"Dynamic sctter",nil];
    
    _menuButton = [[UIButton alloc]init];
    [_menuButton addTarget:self  action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
    _menuButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    [_menuButton.layer setShadowColor:[UIColor whiteColor].CGColor];
    [_menuButton.layer setShadowRadius:MINIMUM_WIDTH_OF_BUTTON/3];
    [_menuButton.layer setShadowOpacity:1];
    [self.view addSubview:_menuButton];
}

-(void)viewWillLayoutSubviews
{
    self.view.frame = [UIScreen mainScreen].bounds;
    _backGroundImageView.frame = self.view.bounds;
    _menuButton.frame = CGRectMake(0, 0, MENU_SIZE.width, MENU_SIZE.height);
    _menuButton.layer.cornerRadius = _menuButton.frame.size.width/2;
    _menuButton.center = MENU_CENTER;
    _menuView.frame = self.view.bounds;
    
    _graphView.frame = CGRectMake(0, self.view.frame.size.height*0.25, self.view.frame.size.width, self.view.frame.size.height*0.6);
    _graphView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + MENU_CENTER.y);
    
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

-(void)graphSelectedWith:(id)sender
{
    [self menuClicked];
    
    if (_graphView != nil)
    {
        [_graphView removeFromSuperview];
        _graphView =  nil;
    }
    
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
   
    if (_graphView != nil)
        [self.view addSubview:_graphView];
    
}

@end
