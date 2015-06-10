//
//  DDPoint.m
//  MapLesson
//
//  Created by DmitrJuga on 06.06.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "DDPoint.h"

@implementation DDPoint

@dynamic name;
@dynamic address;
@dynamic latitude;
@dynamic longitude;

+ (NSString *)entityName { return @"Point"; }

@end
