//
//  CELPostMapAnotation.h
//  swipeToMenu
//
//  Created by Carter Levin on 7/10/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Post.h"


@interface CELPostMapAnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) Post *post;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;
- (id)initWithPost:(Post *)post;
-(MKAnnotationView *)annotationView;

@end
