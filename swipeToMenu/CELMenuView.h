//
//  CELMenuView.h
//  swipeToMenu
//
//  Created by Carter Levin on 7/4/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CELMenuProtocal.h"

@interface CELMenuView : UIView

@property (nonatomic) NSInteger menuVelocity;

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterByPosterSelector;
@property (weak, nonatomic) IBOutlet UIButton *postTransitionButton;

@property (weak, nonatomic) id <CELMenuProtocal> delegat;

- (IBAction)makePost:(id)sender;


@end
