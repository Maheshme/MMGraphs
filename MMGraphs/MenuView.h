//
//  MenuView.h
//  GraphMenu
//
//  Created by Mahesh.me on 12/23/16.
//  Copyright © 2016 Mahesh.me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuView : UIVisualEffectView

@property (nonatomic, strong) NSMutableArray *arrayOfGraphButtons;
@property (nonatomic, strong) UIButton *backgroundButton;

-(instancetype)initWithArrayOfLabels:(NSArray *)arrayOfLabels andBlurEffect:(UIBlurEffect *)blurrEffect;

@end
