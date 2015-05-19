//
//  DDUModel.h
//  MapLesson
//
//  Created by DmitrJuga on 16.05.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDUModel : NSObject

@property (nonatomic, strong) NSMutableArray *arrayPoints;

+ (DDUModel *)sharedModel;

@end
