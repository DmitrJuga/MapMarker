//
//  DDUoint.h
//  MapMarker
//
//  Created by DmitrJuga on 06.06.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDCoreDataHelper.h"

@interface DDPoint : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *address;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;


@end