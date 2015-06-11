//
//  DDCalloutView.m
//  MapMarker
//
//  Created by DmitrJuga on 10.06.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "DDCalloutView.h"

@implementation DDCalloutView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // view
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderColor = [UIColor brownColor].CGColor;
    self.layer.borderWidth = .5;
    self.layer.cornerRadius = 5;

    // titleLabel
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, self.frame.size.width - 4, 17)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor brownColor];
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    // subtitleLabel
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 20, self.frame.size.width - 4, 30)];
    subtitleLabel.numberOfLines = 2;
    subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.textColor = [UIColor darkGrayColor];
    subtitleLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:subtitleLabel];
    self.subtitleLabel = subtitleLabel;
}


@end
