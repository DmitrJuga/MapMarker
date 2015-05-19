//
//  PointTableViewCell.m
//  MapLesson
//
//  Created by DmitrJuga on 15.05.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "AppConstants.h"
#import "PointTableViewCell.h"

@interface PointTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *streetLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@end


@implementation PointTableViewCell

// заполнение ячейки
- (void)setWithDict:(NSDictionary *)dict {
    self.streetLabel.text = dict[STREET_KEY];
    self.cityLabel.text = [NSString stringWithFormat:@"%@, %@", dict[ZIP_KEY], dict[CITY_KEY]];
}

@end
