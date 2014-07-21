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

+ (void)createUserWithName:(NSString *)name
                  password:(NSString *)password
           completionBlock:(void (^)(NSString *error, NSString *uniqueID))callbackBlock;
+ (void)validateUserWithName:(NSString *)name
                    password:(NSString *)password
                userPassback:(void (^) (NSString *error, NSDictionary *userDic))userPassback;
+ (void)savePostToCloud:(Post *)newPost;
+ (void)getAllPosts:(void (^) (NSArray *allPosts))postsPassback;

@end