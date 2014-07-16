//
//  CELFetchUpdates.m
//  swipeToMenu
//
//  Created by Carter Levin on 7/10/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import "CELFetchUpdates.h"
#import "CELCloudDataStore.h"

@implementation CELFetchUpdates


- (instancetype)initForEntityNamed:(NSString *)entityName
{
    self = [super init];
    if (self) {
        [self setUpFetchForEntityName:entityName];
    }
    return self;
}

- (void)setUpFetchForEntityName:(NSString *)entityName
{
    self.store = [CELCoreDataStore sharedDataStore];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    NSSortDescriptor *contentSort = [NSSortDescriptor sortDescriptorWithKey:@"text" ascending:YES];
    fetch.sortDescriptors = @[contentSort];
    self.resultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch managedObjectContext:self.store.context sectionNameKeyPath:nil cacheName:nil];
    self.resultController.delegate = self;
    [self.resultController performFetch:nil];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    [self.delegate fetchedNewObject:anObject];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
}



@end
