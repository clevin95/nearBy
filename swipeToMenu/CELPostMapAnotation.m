//
//  CELPostMapAnotation.m
//  swipeToMenu
//
//  Created by Carter Levin on 7/10/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import "CELPostMapAnotation.h"
#import "CELPostAnnotationView.h"
#import "User.h"

@implementation CELPostMapAnotation

@synthesize coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}

- (id)initWithPost:(Post *)post {
    self = [super init];
    if (self) {
        [self setValuesForPost:post];
    }
    return self;
}

- (void)setValuesForPost:(Post *)post
{
    CGFloat latitude = [post.latitude floatValue];
    CGFloat longitude = [post.longitude floatValue];
    CLLocationCoordinate2D coord = {latitude, longitude};
    coordinate = coord;
    self.post = post;
}

-(MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"CELPostMapAnotation"];
    annotationView.layer.backgroundColor = [UIColor redColor].CGColor;
    annotationView.clipsToBounds = YES;
    annotationView.enabled = YES;
    annotationView.layer.backgroundColor = [UIColor redColor].CGColor;
    //annotationView.image = [UIImage imageNamed:@"defaultImage.jpg"];
    //annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return annotationView;
}



@end