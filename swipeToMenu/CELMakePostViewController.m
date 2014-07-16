//
//  CELMakePostViewController.m
//  swipeToMenu
//
//  Created by Carter Levin on 7/8/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import "CELMakePostViewController.h"
#import "CELCoreDataStore.h"
#import "CELSwipeMenuViewController.h"

@interface CELMakePostViewController ()

@property (weak, nonatomic) IBOutlet UITextView *postTextView;
@property (weak, nonatomic) IBOutlet UIButton *postPostButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelPostButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *postTypeSelector;


- (IBAction)cancelPost:(id)sender;
- (IBAction)postPost:(id)sender;
- (IBAction)postTypeSelected:(id)sender;

@end

@implementation CELMakePostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cancelPostButton.alpha = 1;
    
    self.view.layer.shouldRasterize = YES;
    self.view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [self setUpSubviews];
    [self setUpPostViewContraints];
    
    // Do any additional setup after loading the view.
}


- (void)setUpSubviews
{
    self.postTextView.layer.cornerRadius = 5;
    UIColor *parkGreenColor = [UIColor colorWithRed:(195.0/255.0) green:(217.0/255.0) blue:(180/255.0) alpha:1];
    
    [self.cancelPostButton setTitleColor:parkGreenColor forState:UIControlStateNormal];
}


- (void)setUpPostViewContraints
{
    [self.view removeConstraints:self.view.constraints];
    for (UIView *view in self.view.subviews){
        [view removeConstraints:view.constraints];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    
    [self.cancelPostButton removeConstraints:self.cancelPostButton.constraints];
    [self.postPostButton removeConstraints:self.postPostButton.constraints];
    [self.postTextView removeConstraints:self.postTextView.constraints];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_cancelPostButton, _postPostButton, _postTypeSelector, _postTextView);
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(4)-[_cancelPostButton(50)]-(5)-[_postTypeSelector]-(4)-[_postPostButton(==_cancelPostButton)]-(4)-|" options:0 metrics:nil views:views];
    
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_postTypeSelector]-[_postTextView]-|" options:0 metrics:nil views:views];
    
    
    NSArray *textViewWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[_postTextView]-(30)-|" options:0 metrics:nil views:views];
    NSLayoutConstraint *cancelButtonY = [NSLayoutConstraint constraintWithItem:self.cancelPostButton
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.postTypeSelector
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1
                                                                      constant:0];
    NSLayoutConstraint *postButtonY = [NSLayoutConstraint constraintWithItem:self.postPostButton
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.postTypeSelector
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0];
    [self.view addConstraints:horizontalConstraints];
    [self.view addConstraints:@[cancelButtonY,postButtonY]];
    [self.view addConstraints:verticalConstraints];
    [self.view addConstraints:textViewWidth];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelPost:(id)sender {
    
    [self.postTextView resignFirstResponder];
    [self.postTextView resignFirstResponder];
    [self.delegate exitFromMakePost];
    
}

- (IBAction)postPost:(id)sender {
    [self.postTextView resignFirstResponder];
    CELCoreDataStore *store = [CELCoreDataStore sharedDataStore];
    [self.delegate makePostAnimation];
    NSString *messageText = self.postTextView.text;
    [store savePostWithText:messageText image:nil rate:nil latitude:self.latitude longitude:self.longitude];
}

- (IBAction)postTypeSelected:(id)sender {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
