//
//  CELMakePostViewController.h
//  swipeToMenu
//
//  Created by Carter Levin on 7/8/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CELMakePostProtocal.h"

@interface CELMakePostViewController : UIViewController

@property (weak, nonatomic) id <CELMakePostProtocal> delegate;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;

@end
