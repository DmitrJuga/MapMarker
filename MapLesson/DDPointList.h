//
//  DDPointList.h
//  MapLesson
//
//  Created by DmitrJuga on 16.05.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDPoint.h"

@interface DDPointList : NSObject

@property (readonly, nonatomic) NSArray *array;
@property (readonly, nonatomic) NSUInteger count;

+ (instancetype)sharedPointList;

- (void)addPoint:(DDPoint *)point;
- (void)deletePointAtIndex:(NSUInteger)index;
- (void)deleteAllPoints;

@end
