//
//  DDUCoreDataHelper.h
//  DDUtils
//
//  Created by DmitrJuga on 25.05.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#define     MODEL_FILE_NAME     @"Model"
#define     MODEL_FILE_EXT      @"momd"
#define     STORE_FILE_NAME     @"database.sqlite"

@interface DDCoreDataHelper : NSObject

+ (instancetype)sharedInstance;
- (void)save;

- (NSManagedObject *)addObjectForEntity:(NSString *)entityName;
- (NSArray *)fetchObjectsForEntity:(NSString *)entityName;
- (NSArray *)fetchObjectsForEntity:(NSString *)entityName sortedBy:(NSArray *)sortKeys;
- (void)deleteObject:(NSManagedObject *)object;

@end


// Расширение для NSManagedObject (поддержка работы с CoreDataHelper и моделью данных)
@interface NSManagedObject(DDCoreDataHelper)

+ (NSString *)entityName;
+ (instancetype)createObject;

@end