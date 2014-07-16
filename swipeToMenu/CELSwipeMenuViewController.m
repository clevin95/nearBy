//
//  CELSwipeMenuViewController.m
//  swipeToMenu
//
//  Created by Carter Levin on 7/3/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>
#import <KNSemiModalViewController/UIViewController+KNSemiModal.h>

#import "CELSwipeMenuViewController.h"
#import "CELMenuView.h"
#import "CELMakePostViewController.h"
#import "CELMenuProtocal.h"
#import "CELMakePostProtocal.h"
#import "CELMakePostViewController.h"
#import "CELSearchBarView.h"
#import "CELPostMapAnotation.h"
#import "CELFetchUpdates.h"
#import "Post.h"
#import "CELPostAnnotationView.h"


@interface CELSwipeMenuViewController () <CLLocationManagerDelegate, UISearchBarDelegate, CELMakePostProtocal, CELFetchUpdatesProtocal, MKMapViewDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *worldMap;
@property (weak, nonatomic) IBOutlet CELMenuView *menuView;
@property (weak, nonatomic) IBOutlet UIView *makePostControllerContainer;
@property (weak, nonatomic) IBOutlet UISearchBar *searchAndFilterBar;
@property (weak, nonatomic) IBOutlet CELSearchBarView *searchBarAndCancelButtonView;
@property (weak, nonatomic) IBOutlet UIView *travelPieChart;
@property (weak, nonatomic) IBOutlet UIButton *cancelSearchButton;


@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UICollisionBehavior *topBoundry;
@property (strong, nonatomic) UICollisionBehavior *bottomBoundry;
@property (strong, nonatomic) UIPushBehavior *push;
@property (strong, nonatomic) UIGravityBehavior *downwardGravity;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) MKCoordinateRegion previousViewRegion;
@property (strong, nonatomic) UIView *inputAccessoryView;
@property (nonatomic, weak) CELMakePostViewController *makePostViewController;


//Sets bounds for dissmissing and reentering menu
@property (nonatomic) CGPoint previousMenuPosition;
@property (nonatomic) CGPoint topLeft;
@property (nonatomic) CGPoint topRight;
@property (nonatomic) CGPoint bottomLeft;
@property (nonatomic) CGPoint bottomRight;
@property (nonatomic) NSInteger menuTabLength;

//constraints which change for animation
@property (strong, nonatomic) NSLayoutConstraint *searchViewBottom;
@property (strong, nonatomic) NSLayoutConstraint *searchBarRight;
@property (strong, nonatomic) NSLayoutConstraint *postScreenHeight;
@property (strong, nonatomic) NSLayoutConstraint *postScreenWidth;
@property (strong, nonatomic) NSLayoutConstraint *postScreenY;
@property (strong, nonatomic) NSArray *searchViewHorizontal;
@property (strong, nonatomic) NSDictionary *views;
@property (strong, nonatomic) CELFetchUpdates *postFetcher;

- (IBAction)transtitionToMakePost:(id)sender;
- (IBAction)cancelSearchTapped:(id)sender;


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
    [self setUpPostsFetch];
    [self assignDelegates];
    [self setUpMap];
    [self setUpMakePostView];
    [self setUpMenu];
    [self setUpSearchView];
    [self setUpConstraints];
}

- (void)assignDelegates
{
    self.searchAndFilterBar.delegate = self;
    self.postFetcher.delegate = self;
    self.worldMap.delegate = self;
}

- (void)setUpPostsFetch
{
    self.postFetcher = [[CELFetchUpdates alloc] initForEntityNamed:@"Post"];
    
    
    
    [CELCoreDataStore loadAllPosts];
}

- (void)fetchedNewObject:(id)object
{
    Post *newPost = (Post *)object;
    [self makeAnotationFromPost:newPost];
}


- (void)makeAnotationFromPost:(Post *)post
{
    CELPostMapAnotation *newAnotation = [[CELPostMapAnotation alloc] initWithPost:post];
    [newAnotation annotationView];
    [self.worldMap addAnnotation:newAnotation];
}




- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[CELPostMapAnotation class]]) {
        CELPostMapAnotation *postAnnototion = (CELPostMapAnotation *)annotation;
        MKAnnotationView *annotationView  = [mapView dequeueReusableAnnotationViewWithIdentifier:@"CELPostMapAnotation"];
        if (annotationView == nil){
            annotationView = postAnnototion.annotationView;
            UIImage *annotationImage = [UIImage imageNamed:@"defaultImage.jpg"];
            annotationView.image = annotationImage;
            annotationView.frame = CGRectMake(0, 0, 30, 30);
            annotationView.layer.borderWidth = 2;
            annotationView.layer.cornerRadius = 15;
        }else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }else{
        return nil;
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[CELPostMapAnotation class]]) {
        CELPostMapAnotation *postAnotation = view.annotation;
        Post *selectedPost = postAnotation.post;
        CGRect postViewRect = CGRectMake(0, 0, 300, 100);
        UIView *viewPostView = [[UIView alloc]initWithFrame:postViewRect];
        viewPostView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        viewPostView.alpha = 0.5;
        UITextView *postText = [[UITextView alloc]initWithFrame:viewPostView.frame];
        postText.text = selectedPost.text;
        postText.editable = NO;
        postText.textColor = [UIColor blackColor];
        [viewPostView addSubview:postText];
        [self presentSemiView:viewPostView];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.makePostViewController = segue.destinationViewController;
    self.makePostViewController.delegate = self;
}

- (void)setUpSearchView
{
    self.cancelSearchButton.alpha = 0;
}

- (void)setUpMakePostView
{
    self.makePostControllerContainer.hidden = NO;
    self.makePostControllerContainer.alpha = 0;
    self.makePostControllerContainer.layer.cornerRadius = 10;
    self.makePostControllerContainer.layer.borderWidth = 3;
    UIColor *pinkBorderColor = [UIColor colorWithRed:(217.0/255.0) green:(143/255.0) blue:(137/255.0) alpha:0.5];
    self.makePostControllerContainer.layer.borderColor = pinkBorderColor.CGColor;
    self.makePostControllerContainer.clipsToBounds = YES;
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
    
    self.menuTabLength = 70;
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

//Deals with the panning of the menuView

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
            [self fadeOutViews:@[self.searchBarAndCancelButtonView] withSpeed:0.5];
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
        [self fadeInViews:@[self.cancelSearchButton]];
    }
    self.searchViewBottom.constant += multiplier * (self.view.frame.size.height - 60);
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.searchBarRight.constant += multiplier*50;
    }];
}


- (void)moveToPossition
{
    CGFloat currentLongitude = self.currentLocation.coordinate.longitude;
    CGFloat currentLatitude = self.currentLocation.coordinate.latitude;
    self.makePostViewController.latitude = currentLatitude;
    self.makePostViewController.longitude = currentLongitude;
    MKCoordinateSpan span = {.latitudeDelta =  0.002, .longitudeDelta =  0.002};
    CLLocationCoordinate2D coordinate = {currentLatitude - 0.00026,currentLongitude};
    MKCoordinateRegion region = {coordinate, span};
    [self.worldMap setRegion:region animated:YES];
}

- (void)fadeInViews:(NSArray *)views
{
    for (UIView *view in views){
        view.hidden = NO;
    }
    [UIView animateWithDuration:1 animations:^{
        for (UIView *view in views){
            view.alpha = 1;
        }
    }];
}

- (void)fadeOutViews:(NSArray *)views withSpeed:(CGFloat)speed
{
    [UIView animateWithDuration:speed animations:^{
        for (UIView *view in views){
            view.alpha = 0;
        }
    } completion:^(BOOL finished) {
        for (UIView *view in views){
            view.hidden = YES;
        }
    }];
}

-(void)makePostAnimation
{
    NSLayoutConstraint *oldHeight = self.postScreenHeight;
    NSLayoutConstraint *oldWidth = self.postScreenWidth;
    [self.view removeConstraints:@[oldHeight, oldWidth]];
    self.postScreenHeight = [NSLayoutConstraint constraintWithItem:self.makePostControllerContainer
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:0.11
                                                          constant:0];
    
    self.postScreenWidth = [NSLayoutConstraint constraintWithItem:self.makePostControllerContainer
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:0.16
                                                         constant:0];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"defaultImage.jpg"]];
    imageView.autoresizesSubviews = YES;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view addConstraints:@[self.postScreenWidth, self.postScreenHeight]];
        [self.view layoutIfNeeded];
        
        self.makePostControllerContainer.layer.cornerRadius = 25;
        
        imageView.frame = CGRectMake(0, 0, self.makePostControllerContainer.frame.size.width, self.makePostControllerContainer.frame.size.height);
        [self.makePostControllerContainer addSubview:imageView];
        [UIView transitionWithView:self.makePostControllerContainer duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^ {
                            [self.makePostControllerContainer addSubview:imageView];
                        }
                        completion:^(BOOL finished) {
                            usleep(500000);
                            self.makePostControllerContainer.hidden = YES;
                            [self.view removeConstraints:@[self.postScreenHeight, self.postScreenWidth]];
                            self.postScreenWidth =  oldWidth;
                            self.postScreenHeight = oldHeight;
                            [self.view addConstraints:@[oldWidth, oldHeight]];
                            self.makePostControllerContainer.layer.cornerRadius = 10;
                            imageView.image = nil;
                            [self exitFromMakePost];
                        }];
    }];
}




//Handel search bar;

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self animateSearchBar];
    [self dismissMenuView];
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
    pushMenu.pushDirection = CGVectorMake(0, 1000);
    
    [self.animator addBehavior:pushMenu];
    UICollisionBehavior *stopMenuReenter = [[UICollisionBehavior alloc]initWithItems:@[self.menuView]];
    
    
    CGPoint topLeftMenu = CGPointMake(0, self.menuTabLength);
    CGPoint topRightMenu = CGPointMake(self.view.frame.size.width, self.menuTabLength);
    
    [stopMenuReenter addBoundaryWithIdentifier:@"stopReenter"
                                     fromPoint:topLeftMenu
                                       toPoint:topRightMenu];
    [self.animator addBehavior:stopMenuReenter];
}

- (IBAction)transtitionToMakePost:(id)sender {
    [self.animator removeAllBehaviors];
    [self dismissMenuView];
    [self fadeOutViews:@[self.searchBarAndCancelButtonView] withSpeed:0.5];
    self.previousViewRegion = self.worldMap.region;
    [self moveToPossition];
    self.worldMap.scrollEnabled = NO;
    self.makePostControllerContainer.hidden = NO;
    [self fadeInViews:@[self.makePostControllerContainer]];
}

-(void)exitFromMakePost
{
    [self reenterMenuView];
    [self fadeInViews:@[self.searchBarAndCancelButtonView]];
    self.worldMap.scrollEnabled = YES;
    [self fadeInViews:@[self.searchAndFilterBar]];
    [self.worldMap setRegion:self.previousViewRegion animated:YES];
    [self fadeOutViews:@[self.makePostControllerContainer] withSpeed:0.5 ];
}

- (IBAction)cancelSearchTapped:(id)sender {
    [self endSearchScreen];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    
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
    [self endSearchScreen];
}

- (void)endSearchScreen
{
    [self.searchAndFilterBar resignFirstResponder];
    [self fadeOutViews:@[self.cancelSearchButton] withSpeed:0.5];
    [self reenterMenuView];
    [self animateSearchBar];
}





- (void)setUpConstraints
{
    //[self.view removeConstraints:self.view.constraints];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    for (UIView *subview in self.view.subviews){
        if (subview != self.menuView){
            [subview removeConstraints:subview.constraints];
            subview.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    
    self.views = NSDictionaryOfVariableBindings(_menuView,_worldMap,_searchAndFilterBar,_searchBarAndCancelButtonView, _cancelSearchButton);
    
    [self mapViewConstraints];
    [self menuConstraints];
    [self postViewConstraints];
    [self searchViewConstraints];
     
}


- (void)mapViewConstraints
{
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
    [self.view addConstraints:@[mapRight, mapLeft, mapBottom, mapTop]];
}

- (void)searchViewConstraints
{
    NSLayoutConstraint *searchViewCenter = [NSLayoutConstraint constraintWithItem:self.searchBarAndCancelButtonView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1
                                                                         constant:0];
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
                                                                           toItem:self.searchAndFilterBar
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.1
                                                                         constant:0];
    self.searchViewBottom = [NSLayoutConstraint constraintWithItem:self.searchBarAndCancelButtonView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1
                                                          constant:0];
    [self.view addConstraints:@[searchViewCenter, searchViewWidth, self.searchViewBottom, searchViewHeight]];
    NSLayoutConstraint *searchBarLeft = [NSLayoutConstraint constraintWithItem:self.searchAndFilterBar
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.searchBarAndCancelButtonView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1
                                                                      constant:0];
    self.searchBarRight = [NSLayoutConstraint constraintWithItem:self.searchAndFilterBar
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.searchBarAndCancelButtonView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:0];
    
    [self.cancelSearchButton removeConstraints:self.cancelSearchButton.constraints];
    NSArray *cancelButtonLeftConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[_cancelSearchButton]-(4)-|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:self.views];
    
    NSArray *cancelButtonVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cancelSearchButton]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:self.views];
    
    NSArray *searchBarVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_searchAndFilterBar]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:self.views];
    [self.view addConstraints:@[searchBarLeft, self.searchBarRight]];
    [self.view addConstraints:@[searchBarLeft, self.searchBarRight]];
    [self.view addConstraints:cancelButtonLeftConstraints];
    [self.view addConstraints:cancelButtonVerticalConstraints];
    [self.searchBarAndCancelButtonView addConstraints:searchBarVertical];
}

-(void)menuConstraints
{
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
    [self.view addConstraints:@[menuViewHeightConstraint, menuViewCenterConstraint, menuViewWidthConstraint, menuViewBottomConstraint]];
}

- (void)postViewConstraints
{
    [self.makePostControllerContainer removeConstraints:self.makePostControllerContainer.constraints];
    NSLayoutConstraint *postScreenCenterX = [NSLayoutConstraint constraintWithItem:self.makePostControllerContainer
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1
                                                                    constant:0];
    
    self.postScreenY = [NSLayoutConstraint constraintWithItem:self.makePostControllerContainer
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1
                                                                          constant:-80];

    self.postScreenHeight = [NSLayoutConstraint constraintWithItem:self.makePostControllerContainer
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:0.4
                                                                         constant:0];
    
    self.postScreenWidth = [NSLayoutConstraint constraintWithItem:self.makePostControllerContainer
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:0.9
                                                                         constant:0];
    [self.view addConstraints:@[self.postScreenY, self.postScreenHeight,postScreenCenterX, self.postScreenWidth]];
}


@end
