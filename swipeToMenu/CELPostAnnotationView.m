//
//  CELPostAnnotationView.m
//  swipeToMenu
//
//  Created by Carter Levin on 7/11/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import "CELPostAnnotationView.h"
#import "Post.h"

@implementation CELPostAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithPost:(Post *)post
{
    self = [super init];
    if (self) {
        [self createCustomAnotationView];
    }
    return self;
}


- (void) createCustomAnotationView
{
    self.frame = CGRectMake(10, 10, 10, 10);
    NSLog(@"klsfaskl");
}

- (void)drawRect:(CGRect)rect
{
    self.frame = CGRectMake(0, 0, 10, 10);
    self.layer.backgroundColor = [UIColor redColor].CGColor;
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*

*/

@end
