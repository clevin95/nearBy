//
//  CELCoreDataStore.m
//  swipeToMenu
//
//  Created by Carter Levin on 7/10/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import "CELCoreDataStore.h"
#import "User.h"
#import "Post.h"
#import "CELCloudDataStore.h"

@implementation CELCoreDataStore

@synthesize context = _context;

+ (instancetype)sharedDataStore {
    static CELCoreDataStore *_sharedDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataStore = [[CELCoreDataStore alloc] init];
    });
    return _sharedDataStore;
}

- (NSManagedObjectContext *)context
{
    if (_context != nil) {
        return _context;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"swipeToMenu.sqlite"];
    NSError *error = nil;
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"swipeToMenu")];
    NSString *path = [bundle pathForResource:@"Model" ofType:@"momd"];
    NSURL *momdURL = [NSURL fileURLWithPath:path];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momdURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if (coordinator != nil) {
        _context = [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:coordinator];
    }
    return _context;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)savePostWithText:(NSString *)text
                   image:(UIImage *)image
                    rate:(NSNumber*) rate
                latitude:(CGFloat)latitdue
               longitude:(CGFloat)longitude
{
    Post *newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.context];
    newPost.text = text;
    newPost.rate = rate;
    newPost.latitude = @(latitdue);
    newPost.longitude = @(longitude);
    NSData *imageData = UIImagePNGRepresentation(image);
    newPost.image = imageData;
    newPost.user = self.currentUser;
    [CELCloudDataStore savePostToCloud:newPost];
}

- (void)createUserWithName:(NSString *)name
                   passWord:(NSString *)password
                 completion:(void (^)(NSString *error))completion;
{
    
    [CELCloudDataStore createUserWithName:name password:password completionBlock:^(NSString *error, NSString *userID) {
        
        
        if (error){
            completion(error);
        }
        
        User *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.context];
        newUser.name = name;
        newUser.password = password;
        newUser.uniqueID = userID;
        self.currentUser = newUser;
        
        NSLog(@"%@", newUser);
        completion(error);
    }];
}

- (void)validateForUserWithName:(NSString *)name
                       password:(NSString *)password
                  wasErrorBlock:(void (^)(NSString *error))wasErrorBlock
{
    [CELCloudDataStore validateUserWithName:name password:password userPassback:^(NSString *error, NSDictionary *userDic) {
        if (error){
            NSString * errorString = [NSString stringWithFormat:@"%@",error];
            wasErrorBlock(errorString);
        }
        
        User *loginUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.context];
        loginUser.name = userDic[@"username"];
        loginUser.password = userDic[@"password"];
        self.currentUser = loginUser;
        wasErrorBlock(error);
    }];
}






- (void)loadAllPosts
{
    [CELCloudDataStore getAllPosts:^(NSArray *allPosts) {
        for (NSDictionary *postDic in allPosts){
            [self savePostWithDictionary:postDic];
        }
    }];
}

- (void)savePostWithDictionary:(NSDictionary *)postDictionary
{
    
    Post *newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.context];
    if (![postDictionary[@"content"] isKindOfClass:[NSNull class]]){
        newPost.text = postDictionary[@"content"];
    }
    if (![postDictionary[@"rate"] isKindOfClass:[NSNull class]]){
        newPost.rate = [NSNumber numberWithInteger:[postDictionary[@"rate"] integerValue]];
    }
    if (![postDictionary[@"longitude"] isKindOfClass:[NSNull class]]){
        newPost.latitude = [NSNumber numberWithFloat:[postDictionary[@"latitude"] floatValue]];
    }else{
        NSLog(@"%@",postDictionary[@"longitude"]);
    }
    if (![postDictionary[@"latitude"] isKindOfClass:[NSNull class]]){
         newPost.longitude = [NSNumber numberWithFloat:[postDictionary[@"longitude"] floatValue]];
    }
    NSLog(@"newLatitude: %@\n newLongitude: %@", newPost.latitude, newPost.longitude);
}

- (void)save
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.context;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
