//
//  ViewController.h
//  MapLesson
//
//  Created by DmitrJuga on 12.05.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "CoreLocation/CoreLocation.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

- (void)selectAnnotation:(id<MKAnnotation>)annotation;

@end

