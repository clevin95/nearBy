//
//  CELCloudDataStore.h
//  swipeToMenu
//
//  Created by Carter Levin on 7/14/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

@interface CELCloudDataStore : NSObject <NSURLConnectionDelegate>

+ (void)savePostToCloud:(Post *)newPost;
+ (void)getAllPosts;

@end