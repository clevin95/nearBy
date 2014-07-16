//
//  CELMenuView.m
//  swipeToMenu
//
//  Created by Carter Levin on 7/4/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import "CELMenuView.h"

@implementation CELMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self generalSetup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self generalSetup];
    }
    return self;
}

-(void)generalSetup
{
    
}

-(void)awakeFromNib
{
    [self setUpSubviews];
    [self setUpMenuConstraints];
}


- (void)setUpSubviews
{
    self.userImage.image = [UIImage imageNamed:@"defaultImage.jpg"];
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2;
    self.userImage.clipsToBounds = YES;
}

- (void)setUpMenuConstraints
{
    [self removeConstraints:self.constraints];
    [self.superview removeConstraints:self.superview.constraints];
    [self.userImage removeConstraints:self.userImage.constraints];
    [self.filterByPosterSelector removeConstraints:self.filterByPosterSelector.constraints];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.userImage.translatesAutoresizingMaskIntoConstraints = NO;
    //Constraints for subViews
    NSDictionary *views = NSDictionaryOfVariableBindings(_userImage, _filterByPosterSelector, _postTransitionButton);
    
    NSArray *menuTabHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=2)-[_userImage(45)]-(>=2)-[_filterByPosterSelector(215)]-(>=2)-[_postTransitionButton]-(3)-|" options:0 metrics:nil views:views];
    
    NSArray *menuTabLeftVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_userImage]-(3)-|" options:0 metrics:nil views:views];
    
    NSArray *menuTabCenterVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_filterByPosterSelector]-(3)-|" options:0 metrics:nil views:views];
    
    NSArray *menuTabRightVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_postTransitionButton]-(3)-|" options:0 metrics:nil views:views];
    
    [self addConstraints:menuTabHorizontalConstraints];
    [self addConstraints:menuTabLeftVerticalConstraints];
    [self addConstraints:menuTabCenterVerticalConstraints];
    [self addConstraints:menuTabRightVerticalConstraints];
    
    NSLayoutConstraint *centerSelectorConstraint = [NSLayoutConstraint constraintWithItem:self.filterByPosterSelector
                                                                                attribute:NSLayoutAttributeCenterX
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeCenterX
                                                                               multiplier:1
                                                                                 constant:0];
    NSLayoutConstraint *userImageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.userImage
                                                                                     attribute:NSLayoutAttributeHeight
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.userImage
                                                                                     attribute:NSLayoutAttributeWidth
                                                                                    multiplier:1
                                                                                      constant:0];
    
    [self addConstraints:@[userImageViewHeightConstraint, centerSelectorConstraint]];
    
}

@end
