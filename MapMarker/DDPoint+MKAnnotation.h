//
//  DDPoint+MKAnnotation.h
//  MapMarker
//
//  Created by DmitrJuga on 09.06.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "DDPoint.h"
#import "MapKit/MapKit.h"

@interface DDPoint (MKAnnotation) <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
