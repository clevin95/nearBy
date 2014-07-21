//
//  CELCoreDataStore.h
//  swipeToMenu
//
//  Created by Carter Levin on 7/10/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface CELCoreDataStore : NSObject


@property (readonly, strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) User *currentUser;
+ (instancetype)sharedDataStore;
- (void)savePostWithText:(NSString *)text
                   image:(UIImage *)image
                    rate:(NSNumber*) rate
                latitude:(CGFloat)latitdue
               longitude:(CGFloat)longitude;

- (void)savePostWithDictionary:(NSDictionary *)postDictionary;

- (void)loadAllPosts;

- (void)createUserWithName:(NSString *)name
                   passWord:(NSString *)password
                 completion:(void (^)(NSString *error))completion;

- (void)validateForUserWithName:(NSString *)name
                       password:(NSString *)password
                  wasErrorBlock:(void (^)(NSString *error))wasErrorBlock;



@end
