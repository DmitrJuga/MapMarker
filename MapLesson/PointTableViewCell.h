//
//  PointTableViewCell.h
//  MapLesson
//
//  Created by DmitrJuga on 15.05.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPoint.h"

@interface PointTableViewCell : UITableViewCell

- (void)setupWithPoint:(DDPoint *)point;

@end
