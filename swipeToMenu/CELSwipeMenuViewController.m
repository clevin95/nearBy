//
//  CELSwipeMenuViewController.m
//  swipeToMenu
//
//  Created by Carter Levin on 7/3/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import "CELSwipeMenuViewController.h"
#import "CELMenuView.h"
#import <MapKit/MapKit.h>
#import <KNSemiModalViewController/UIViewController+KNSemiModal.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>


@interface CELSwipeMenuViewController () <CLLocationManagerDelegate, UISearchBarDelegate, UIImagePickerControllerDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *worldMap;

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterByPosterSelector;

@property (weak, nonatomic) IBOutlet UITextView *postTextView;
@property (weak, nonatomic) IBOutlet UIButton *postPostButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelPostButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *postTypeSelector;
@property (weak, nonatomic) IBOutlet UIButton *postTransitionButton;

@property (weak, nonatomic) IBOutlet UISearchBar *searchAndFilterBar;
@property (weak, nonatomic) IBOutlet UIView *searchBarAndCancelButtonView;
@property (weak, nonatomic) IBOutlet UIView *travelPieChart;
@property (weak, nonatomic) IBOutlet UIView *postScreenView;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UICollisionBehavior *topBoundry;
@property (strong, nonatomic) UICollisionBehavior *bottomBoundry;
@property (strong, nonatomic) UIPushBehavior *push;
@property (strong, nonatomic) UIGravityBehavior *downwardGravity;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) MKCoordinateRegion previousViewRegion;

@property (strong, nonatomic) UIView *inputAccessoryView;

//Sets bounds for dissmissing and reentering menu
@property (nonatomic) CGPoint previousMenuPosition;
@property (nonatomic) CGPoint topLeft;
@property (nonatomic) CGPoint topRight;
@property (nonatomic) CGPoint bottomLeft;
@property (nonatomic) CGPoint bottomRight;
@property (nonatomic) NSInteger menuTabLength;

//constraints which change for animation
@property (strong, nonatomic) NSLayoutConstraint *searchViewBottom;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

- (IBAction)makePost:(id)sender;
- (IBAction)cancelPost:(id)sender;
- (IBAction)postPost:(id)sender;
- (IBAction)postTypeSelected:(id)sender;

@end

@implementation CELSwipeMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchAndFilterBar.delegate = self;
    [self setUpMap];
    [self setUpMenu];
    [self setUpConstraints];
    
    
    
    
    self.imagePickerController = [[UIImagePickerController alloc]init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        //self.imagePickerController.mediaTypes = @[kUTTypeImage];
    }
    
}

- (void)setUpConstraints
{
    [self.view removeConstraints:self.view.constraints];
    [self.menuView removeConstraints:self.menuView.constraints];
    [self.postScreenView removeConstraints:self.postScreenView.constraints];
    [self.searchBarAndCancelButtonView removeConstraints:self.searchBarAndCancelButtonView.constraints];
    self.postScreenView.translatesAutoresizingMaskIntoConstraints = NO;
    self.menuView.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchBarAndCancelButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *menuViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.menuView
                                                                                attribute:NSLayoutAttributeHeight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.view
                                                                                attribute:NSLayoutAttributeHeight
                                                                               multiplier:1
                                                                                 constant:0];
    NSLayoutConstraint *menuViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.menuView
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.view
                                                                               attribute:NSLayoutAttributeWidth
                                                                              multiplier:1
                                                                                constant:0];
    
    NSLayoutConstraint *menuViewCenterConstraint = [NSLayoutConstraint constraintWithItem:self.menuView
                                                                                attribute:NSLayoutAttributeCenterX
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.view
                                                                                attribute:NSLayoutAttributeCenterX
                                                                               multiplier:1
                                                                                 constant:0];
    NSLayoutConstraint *menuViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.menuView
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.view
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1
                                                                                 constant:self.menuTabLength];
    [self.view addConstraints:@[menuViewHeightConstraint, menuViewWidthConstraint, menuViewCenterConstraint, menuViewBottomConstraint]];
    
    
    
    NSLayoutConstraint *mapTop = [NSLayoutConstraint constraintWithItem:self.worldMap
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:1];
    NSLayoutConstraint *mapBottom = [NSLayoutConstraint constraintWithItem:self.worldMap
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1
                                                                  constant:0];
    NSLayoutConstraint *mapLeft = [NSLayoutConstraint constraintWithItem:self.worldMap attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1
                                                                constant:0];
    NSLayoutConstraint *mapRight = [NSLayoutConstraint constraintWithItem:self.worldMap
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeRight
                                                               multiplier:1
                                                                 constant:0];
    
    [self.view addConstraints:@[ mapRight, mapLeft, mapBottom, mapTop]];
    
    NSLayoutConstraint *searchViewCenter = [NSLayoutConstraint constraintWithItem:self.searchBarAndCancelButtonView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1 constant:0];
    NSLayoutConstraint *searchViewWidth = [NSLayoutConstraint constraintWithItem:self.searchBarAndCancelButtonView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1
                                                                        constant:0];
    NSLayoutConstraint *searchViewHeight = [NSLayoutConstraint constraintWithItem:self.searchBarAndCancelButtonView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:0.1
                                                                         constant:0];
    self.searchViewBottom = [NSLayoutConstraint constraintWithItem:self.searchBarAndCancelButtonView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1
                                                          constant:0];
    [self.view addConstraints:@[searchViewCenter, searchViewWidth, self.searchViewBottom, searchViewHeight]];
    //Constraints for post view
    NSLayoutConstraint *postScreenTop = [NSLayoutConstraint constraintWithItem:self.postScreenView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:20];

    NSLayoutConstraint *postScreenHeight = [NSLayoutConstraint constraintWithItem:self.postScreenView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:0.3
                                                                         constant:0];
    NSLayoutConstraint *postScreenLeft = [NSLayoutConstraint constraintWithItem:self.postScreenView
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:5];
    NSLayoutConstraint *postScreenRight = [NSLayoutConstraint constraintWithItem:self.postScreenView
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1
                                                                        constant:-5];
    
    [self.view addConstraints:@[postScreenHeight,postScreenLeft,postScreenTop, postScreenRight]];
    [self setUpMenuConstraints];
    [self setUpPostViewContraints];
}


- (void)setUpPostViewContraints
{
    [self.cancelPostButton removeConstraints:self.cancelPostButton.constraints];
    [self.postPostButton removeConstraints:self.postPostButton.constraints];
    [self.postTextView removeConstraints:self.postTextView.constraints];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_cancelPostButton, _postPostButton, _postTypeSelector, _postTextView);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cancelPostButton(50)]-(5)-[_postTypeSelector]-(5)-[_postPostButton(==_cancelPostButton)]|" options:0 metrics:nil views:views];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_postTypeSelector]-[_postTextView]|" options:0 metrics:nil views:views];
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


- (void)setUpMenuConstraints
{
    [self.userImage removeConstraints:self.userImage.constraints];
    [self.filterByPosterSelector removeConstraints:self.filterByPosterSelector.constraints];
    [self.postPostButton removeConstraints:self.postPostButton.constraints];
    self.userImage.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(_userImage, _filterByPosterSelector, _postTransitionButton);
    
    NSArray *menuTabHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(3)-[_userImage(45)]-(>=2)-[_filterByPosterSelector(220)]-(>=2)-[_postTransitionButton]-(3)-|" options:0 metrics:nil views:views];
    
    NSArray *menuTabLeftVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[_userImage]|" options:0 metrics:nil views:views];
    
    [self.menuView addConstraints:menuTabHorizontalConstraints];
    [self.menuView addConstraints:menuTabLeftVerticalConstraints];

    NSLayoutConstraint *centerSelectorConstraint = [NSLayoutConstraint constraintWithItem:self.filterByPosterSelector
                                                                                attribute:NSLayoutAttributeCenterX
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.menuView
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
    
    [self.menuView addConstraints:@[/*userImageViewWidthConstraint,*/ userImageViewHeightConstraint, centerSelectorConstraint]];
    
}

- (void)setUpMap
{
    self.worldMap.rotateEnabled = NO;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)setUpMenu
{
    self.menuView.layer.shadowRadius = 5.0;
    self.menuView.layer.shadowOffset = CGSizeMake(0,0);
    self.menuView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.menuView.layer.shadowOpacity = .9f;
    
    self.menuTabLength = 60;
    self.bottomLeft = CGPointMake(0, self.view.frame.size.height);
    self.bottomRight = CGPointMake(self.view.frame.size.width, self.view.frame.size.height);
    self.topLeft = CGPointMake(0, -self.view.frame.size.height + self.menuTabLength);
    self.topRight = CGPointMake(self.view.frame.size.width, -self.view.frame.size.height + self.menuTabLength);
    
    self.animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    UIGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.menuView addGestureRecognizer:pan];
    self.push = [[UIPushBehavior alloc]initWithItems:@[self.menuView] mode:UIPushBehaviorModeContinuous];
    
    self.topBoundry = [[UICollisionBehavior alloc] initWithItems:@[self.menuView]];
    self.bottomBoundry = [[UICollisionBehavior alloc] initWithItems:@[self.menuView]];
    self.userImage.image = [UIImage imageNamed:@"defaultImage.jpg"];
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2;
    self.userImage.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.menuView.frame = CGRectOffset(self.view.frame, 0, 0);
    
    //self.postTextView.hidden = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = locations[0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) updateMenuAndSearchAlpha
{
    //Using position of menu view to calculate alpha
    CGFloat verticalPossition = self.menuView.frame.origin.y;
    CGFloat possition = 0.1 + (verticalPossition / 2000.0) ;
    self.menuView.alpha = 0.85 + possition;
}


- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    
    CGPoint currentTouchPosition = [gesture locationInView:self.view];
    CGPoint velocity = [gesture velocityInView:gesture.view.superview];
    velocity.x  = 0;
    if (gesture.state == UIGestureRecognizerStateBegan){
        [self.animator removeAllBehaviors];
    }else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        NSInteger newY = self.menuView.frame.origin.y + (currentTouchPosition.y - self.previousMenuPosition.y);
        if (newY <= 0 && -(self.view.frame.size.height - self.menuTabLength) <= newY){
            [self updateMenuAndSearchAlpha];
            CGRect newMenuPosition = CGRectOffset(self.menuView.frame, 0, (currentTouchPosition.y - self.previousMenuPosition.y));
            self.menuView.frame = newMenuPosition;
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        UIDynamicItemBehavior *velocityBehavior = [[UIDynamicItemBehavior alloc]initWithItems:@[self.menuView]];
        [velocityBehavior addLinearVelocity:velocity forItem:self.menuView];
        [self.animator addBehavior:velocityBehavior];
        if (velocity.y > 0 ){
            [self fadeOutViews:@[self.searchBarAndCancelButtonView]];
        }else{
            [self fadeInViews:@[self.searchBarAndCancelButtonView]];
        }
        [self.topBoundry addBoundaryWithIdentifier:@"topBarrier"
                                         fromPoint:self.topLeft
                                           toPoint:self.topRight];
        [self.topBoundry addBoundaryWithIdentifier:@"bottomBarrier"
                                         fromPoint:self.bottomLeft
                                           toPoint:self.bottomRight];
        [self.animator addBehavior:self.topBoundry];
        self.push.pushDirection = CGVectorMake(velocity.x, velocity.y);
        [self.animator addBehavior:self.push];
        velocityBehavior.action = ^{
            [self updateMenuAndSearchAlpha];
        };
    }
    self.previousMenuPosition = currentTouchPosition;
}

//Section bellow deals with searching

- (void)animateSearchBar{
    NSInteger multiplier = 1;
    if (self.searchViewBottom.constant == 0)
    {
        multiplier = -1;
    }
    self.searchViewBottom.constant += multiplier * (self.view.frame.size.height - 80);
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}


-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self animateSearchBar];
    [self dismissMenuView];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [theSearchBar resignFirstResponder];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:theSearchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        //Error checking
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        MKCoordinateRegion region;
        region.center.latitude = placemark.location.coordinate.latitude;
        region.center.longitude = placemark.location.coordinate.longitude;
        MKCoordinateSpan span;
        
        double radius = [(CLCircularRegion *)placemark.region radius] / 1000; // convert to km
        span.latitudeDelta = radius / 112.0;
        region.span = span;
        [self.worldMap setRegion:region animated:YES];
    }];
    [self.animator removeAllBehaviors];
    [self reenterMenuView];
    [self animateSearchBar];
}

- (void)dismissMenuView
{
    [self.animator removeAllBehaviors];
    [UIView animateWithDuration:1 animations:^{
        self.menuView.frame = CGRectOffset(self.menuView.frame, 0, -self.view.frame.size.height);
    }];
}

- (void)reenterMenuView
{
    UIPushBehavior *pushMenu = [[UIPushBehavior alloc]initWithItems:@[self.menuView] mode:UIPushBehaviorModeContinuous];
    pushMenu.pushDirection = CGVectorMake(0, 150);
    [self.animator addBehavior:pushMenu];
    UICollisionBehavior *stopMenuReenter = [[UICollisionBehavior alloc]initWithItems:@[self.menuView]];
    CGPoint topLeftMenu = CGPointMake(0, 115);
    CGPoint topRightMenu = CGPointMake(self.view.frame.size.width, 115);
    
    [stopMenuReenter addBoundaryWithIdentifier:@"stopReenter"
                                     fromPoint:topLeftMenu
                                       toPoint:topRightMenu];
    [self.animator addBehavior:stopMenuReenter];
}


- (void)moveToPossition
{
    MKCoordinateSpan span = {.latitudeDelta =  0.002, .longitudeDelta =  0.002};
    CLLocationCoordinate2D coordinate = {self.currentLocation.coordinate.latitude + 0.0004,self.currentLocation.coordinate.longitude};
    MKCoordinateRegion region = {coordinate, span};
    [self.worldMap setRegion:region animated:YES];
}

- (void)fadeInViews:(NSArray *)views
{
    [UIView animateWithDuration:1.5 animations:^{
        for (UIView *view in views){
            view.alpha = 1;
        }
    }];
}

- (void)fadeOutViews:(NSArray *)views
{
    [UIView animateWithDuration:1 animations:^{
        for (UIView *view in views){
            view.alpha = 0;
        }
    }];
}

- (IBAction)makePost:(id)sender {
    [self.animator removeAllBehaviors];
    [self dismissMenuView];
    self.previousViewRegion = self.worldMap.region;
    [self moveToPossition];
    self.worldMap.scrollEnabled = NO;
    self.postPostButton.hidden = NO;
    self.cancelPostButton.hidden = NO;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    self.postTextView.hidden = NO;
    self.postTextView.layer.cornerRadius = 5;
    [self fadeInViews:@[self.postScreenView]];
    [self fadeOutViews:@[self.searchAndFilterBar]];
    self.postTextView.inputAccessoryView = nil;
}

//make and cancel post options

- (IBAction)cancelPost:(id)sender {
    [self.worldMap setRegion:self.previousViewRegion animated:YES];
    [self.postTextView resignFirstResponder];
    [self reenterMenuView];
    self.worldMap.scrollEnabled = YES;
    [self fadeInViews:@[self.searchAndFilterBar]];
    [self fadeOutViews:@[self.postScreenView]];
}

- (IBAction)postPost:(id)sender {
}

- (IBAction)postTypeSelected:(id)sender {
    UISegmentedControl *postTypeSegment = sender;
    NSLog(@"%@",postTypeSegment);
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}


/*
 - (UIView *)inputAccessoryView {
 if (!_inputAccessoryView) {
 CGRect accessFrame = CGRectMake(0.0, 0.0, 768.0, 40.0);
 _inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
 _inputAccessoryView.backgroundColor = [UIColor whiteColor];
 _inputAccessoryView.layer.borderColor = [UIColor blackColor].CGColor;
 UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
 compButton.frame = CGRectMake(313.0, 20.0, 158.0, 37.0);
 [compButton setTitle: @"Word Completions" forState:UIControlStateNormal];
 [compButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
 [_inputAccessoryView addSubview:compButton];
 }
 return _inputAccessoryView;
 }*/

@end
