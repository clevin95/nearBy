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

- (void)savePostWithDictionary:(NSDictionary *)postDictionary
{
    Post *newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.context];
    newPost.text = postDictionary[@"content"];
    newPost.image =  postDictionary[@"image"];
    newPost.rate = [NSNumber numberWithInteger:[postDictionary[@"rate"] integerValue]];
    newPost.latitude = [NSNumber numberWithInteger:[postDictionary[@"longitude"] integerValue]];
    newPost.longitude = [NSNumber numberWithInteger:[postDictionary[@"latitude"] integerValue]];
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
