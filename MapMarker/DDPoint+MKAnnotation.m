//
//  DDPoint+MKAnnotation.m
//  MapMarker
//
//  Created by DmitrJuga on 09.06.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "DDPoint+MKAnnotation.h"

@implementation DDPoint (MKAnnotation)

- (CLLocationCoordinate2D) coordinate {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.latitude = newCoordinate.latitude;
    self.longitude = newCoordinate.longitude;
}

- (NSString *)title {
    return self.name;
}

- (void)setTitle:(NSString *)newTitle {
    self.name = [newTitle copy];
}

- (NSString *)subtitle {
    return self.address;
}

- (void)setSubtitle:(NSString *)newSubtitle {
    self.address = [newSubtitle copy];
}


@end
