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

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet MKMapView *worldMap;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UITextView *postTextView;
@property (weak, nonatomic) IBOutlet UIButton *postPostButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelPostButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *postTypeSelector;
@property (weak, nonatomic) IBOutlet UISearchBar *searchAndFilterBar;
@property (weak, nonatomic) IBOutlet UIView *searchBarAndCancelButtonView;

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
    [self setUpPostViews];
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
    self.menuView.translatesAutoresizingMaskIntoConstraints = NO;
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
    [self.view addConstraints:@[menuViewHeightConstraint, menuViewWidthConstraint]];
   // [self setUpMenuConstraints];
}


- (void)setUpMenuConstraints
{
    [self.userImage removeConstraints:self.userImage.constraints];
    NSLayoutConstraint *userImageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.menuView
                                                                                attribute:NSLayoutAttributeHeight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.view
                                                                                attribute:NSLayoutAttributeHeight
                                                                               multiplier:0.1
                                                                                 constant:0];
    NSLayoutConstraint *userImageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.menuView
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.view
                                                                               attribute:NSLayoutAttributeWidth
                                                                              multiplier:0.1
                                                                                constant:0];
    [self.view addConstraints:@[userImageViewWidthConstraint, userImageViewHeightConstraint]];
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
    
    self.bottomLeft = CGPointMake(0, self.view.frame.size.height);
    self.bottomRight = CGPointMake(self.view.frame.size.width, self.view.frame.size.height);
    self.topLeft = CGPointMake(0, -450);
    self.topRight = CGPointMake(self.view.frame.size.width, -450);
    
    self.animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    UIGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.menuView addGestureRecognizer:pan];
    self.push = [[UIPushBehavior alloc]initWithItems:@[self.menuView] mode:UIPushBehaviorModeContinuous];
    
    self.topBoundry = [[UICollisionBehavior alloc] initWithItems:@[self.menuView]];
    self.bottomBoundry = [[UICollisionBehavior alloc] initWithItems:@[self.menuView]];
    self.userImage.image = [UIImage imageNamed:@"defaultImage.jpg"];
}


- (void)setUpPostViews
{
    self.postTextView.alpha = 0;
    self.postTypeSelector.alpha = 0;
    self.cancelPostButton.alpha = 0;
    self.postPostButton.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.menuView.frame = CGRectOffset(self.view.frame, 0, 0);

    self.postTextView.hidden = YES;
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
        if (self.menuView.frame.origin.y + (currentTouchPosition.y - self.previousMenuPosition.y) <= 0){
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
    NSInteger searchBarFinalY = self.view.frame.origin.y +20;
    CGRect newPosition = CGRectMake(0,searchBarFinalY,self.searchAndFilterBar.frame.size.width, self.searchAndFilterBar.frame.size.height);
    
    
    //CGRect reducedSearchBarRect = CGRectMake(newPosition.origin.x, newPosition.origin.y, newPosition.size.width - 80, newPosition.size.height);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.searchBarAndCancelButtonView.frame = newPosition;
        //self.searchBarAndCancelButtonView.transform = CGAffineTransformMakeScale(0, 10);
        
    } completion:nil];
    
    
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
    [self dismissSearchBar];
}

- (void)dismissMenuView
{
    [UIView animateWithDuration:1 animations:^{
        self.menuView.frame = CGRectOffset(self.menuView.frame, 0, -self.view.frame.size.height);
    }];
}

- (void)dismissSearchBar{
    
    /*
    NSInteger finalYPos = self.view.frame.size.height - 30;
    CGRect restingSearchViewRect = CGRectOffset(self.searchBarAndCancelButtonView.frame, 0, finalYPos);
    [UIView animateWithDuration:0.3 animations:^{
        self.searchBarAndCancelButtonView.frame = restingSearchViewRect;
    }];
    */
    
    UIPushBehavior *pushSearch = [[UIPushBehavior alloc]initWithItems:@[self.searchBarAndCancelButtonView] mode:UIPushBehaviorModeContinuous];
    pushSearch.pushDirection = CGVectorMake(0, 100);
    [self.animator addBehavior:pushSearch];
    UICollisionBehavior *stopSearchDrop = [[UICollisionBehavior alloc]initWithItems:@[self.searchAndFilterBar]];
    CGPoint topLeftSearch = CGPointMake(0, 560);
    CGPoint topRightSearch = CGPointMake(self.view.frame.size.width, 560);
    [stopSearchDrop addBoundaryWithIdentifier:@"stopReenter"
                                    fromPoint:topLeftSearch
                                      toPoint:topRightSearch];

    [self.animator addBehavior:stopSearchDrop];
    
}

- (void)reenterMenuView
{
    //[self.animator removeAllBehaviors];
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

- (IBAction)cancelPost:(id)sender {
    [self.worldMap setRegion:self.previousViewRegion animated:YES];
    [self.postTextView resignFirstResponder];
    [self reenterMenuView];
    self.worldMap.scrollEnabled = YES;
    [self fadeInViews:@[self.searchAndFilterBar]];
    [self fadeOutViews:@[self.postTextView,self.postTypeSelector,self.cancelPostButton,self.postPostButton]];
}

- (IBAction)postPost:(id)sender {
}

- (IBAction)postTypeSelected:(id)sender {
    UISegmentedControl *postTypeSegment = sender;
    NSLog(@"%@",postTypeSegment);
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
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
    [self fadeInViews:@[self.postTextView,self.postTypeSelector,self.cancelPostButton,self.postPostButton]];
    [self fadeOutViews:@[self.searchAndFilterBar]];
    self.postTextView.inputAccessoryView = nil;
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
