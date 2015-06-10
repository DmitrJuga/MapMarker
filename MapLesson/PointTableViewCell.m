//
//  PointTableViewCell.m
//  MapLesson
//
//  Created by DmitrJuga on 15.05.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "PointTableViewCell.h"

@interface PointTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end


@implementation PointTableViewCell

// заполнение ячейки
- (void)setupWithPoint:(DDPoint *)point {
    self.nameLabel.text = point.name;
    self.addressLabel.text = point.address;
}

@end
