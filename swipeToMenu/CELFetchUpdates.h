//
//  CELFetchUpdates.h
//  swipeToMenu
//
//  Created by Carter Levin on 7/10/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CELCoreDataStore.h"
#import "CELFetchUpdatesProtocal.h"

@interface CELFetchUpdates : NSObject <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) CELCoreDataStore *store;
@property (strong, nonatomic) NSFetchedResultsController *resultController;
@property (weak, nonatomic) id <CELFetchUpdatesProtocal> delegate;

- (instancetype)initForEntityNamed:(NSString *)entityName;
@end
