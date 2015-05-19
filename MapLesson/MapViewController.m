//
//  ViewController.m
//  MapLesson
//
//  Created by DmitrJuga on 12.05.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "AppConstants.h"
#import "MapViewController.h"
#import "DDUModel.h"


typedef NSDictionary * (^PointArrayElementBlock)(NSString *street, NSString *city, NSString *zipCode);

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet UIView *customNavBar;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *arrayPoints;

@end


@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.customNavBar.layer.borderWidth = 0.5;
    self.customNavBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // CoreLocation Authorization (for iOS >= 8.0)
    if ([UIDevice currentDevice].systemVersion.intValue >=8) {
        [self.locationManager requestWhenInUseAuthorization];// если авторизация выполнена, метод ничего не делает
    }
    // устанавливаем ссылку на синглтон
    self.arrayPoints = [DDUModel sharedModel].arrayPoints;
    
    // устанавливаем обработчик нотификации выбора аннотации из списка
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSelectNotif:) name:SELECT_NOTIF object:nil];
}

// обновление перел отображение
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadAnnotations];
}


#pragma mark - CLLocationManagerDelegate

// включаем обновление геолокации, если пользователь разрешил
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
        [self.locationManager startUpdatingLocation];
    }
}

// обновление геолокации
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // фокус на текущцю локацию
    CLLocation *location = locations.lastObject;
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, DEF_MAP_SCALE, DEF_MAP_SCALE) animated:YES];
    // приостанавливаем обновление геолокации
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - MKMapViewDelegate

// создание кастомного view для аннотации
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if (![annotation isKindOfClass:MKUserLocation.class]) {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
        annotationView.image = [UIImage imageNamed:@"map_marker"];
        annotationView.canShowCallout = NO;
        
        [annotationView addSubview:[self getCalloutView:annotation.title]];
        return annotationView;
    }
    return nil;
}

// обработка нажатия на маркер (выбор аннотации)
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (![view.annotation isKindOfClass:MKUserLocation.class]) {
        // фокус на аннотацию (если не по центру - ставим по центру)
        MKPointAnnotation *annotation = view.annotation;
        if (annotation.coordinate.latitude != mapView.region.center.latitude ||
            annotation.coordinate.longitude != mapView.region.center.longitude) {
            MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, mapView.region.span);
            [mapView setRegion:region animated:YES];
        }
        // анимировнное появление calloutView
        UIView *calloutView = view.subviews.firstObject;
        [UIView animateWithDuration:0.4 animations:^{
            calloutView.alpha = 1;
            calloutView.transform = CGAffineTransformIdentity;
        }];
        
    }
}

// обработка отмены нажатия на маркер аннотации
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    // анимировнное исчезание calloutView
    UIView *calloutView = view.subviews.firstObject;
    [UIView animateWithDuration:0.4 animations:^{
        calloutView.alpha = 0;
        calloutView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        
    }];
}

#pragma mark - MapView routines

// создание кастомного CalloutView для аннотации
- (UIView *)getCalloutView:(NSString*)title {
    
    // view
    UIView * calloutView = [[UIView alloc]initWithFrame:CGRectMake(-74, -48, 180, 48)];
    calloutView.backgroundColor = [UIColor whiteColor];
    calloutView.layer.borderWidth = .5;
    calloutView.layer.cornerRadius = 5;
    calloutView.layer.borderColor = [UIColor brownColor].CGColor;
    
    // label
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, 176, 44)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont systemFontOfSize:12];
    label.text = title;
    [calloutView addSubview:label];
    
    calloutView.alpha = 0;
    calloutView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    
    return calloutView;
}

// обновление (добавление) аннотаций на карте
- (void)reloadAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (NSDictionary *pointDict in self.arrayPoints) {
        MKPointAnnotation *annotation = pointDict[ANNOTATION_KEY];
        [self.mapView addAnnotation:annotation];
    }
}

// масштабирование карты для отображения ВСЕХ аннотаций
- (void)fitAnnotations {
    MKMapRect zoomRect = MKMapRectNull;
    for (MKPointAnnotation *annotation in self.mapView.annotations) {
        if (![annotation isKindOfClass:MKUserLocation.class]) {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    double inset = -zoomRect.size.width * 0.1;
    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) animated:YES];
}

// обработчик нотификации выбора аннотации из списка
- (void)handleSelectNotif:(NSNotification *)notif {
    // фркусируемся на аннотацию
    MKPointAnnotation *annotation = notif.userInfo[ANNOTATION_KEY];
    [self.mapView selectAnnotation:annotation animated:YES];
    
    // масштабируем
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, DEF_MAP_SCALE, DEF_MAP_SCALE);
    [self.mapView setRegion:region animated:YES];
}


#pragma mark - Gesture Recognizer Handler

// обработчик длинного нажатия
- (IBAction)longPressHandle:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        // определяем координаты и локацию нажатия на карте
        CGPoint touchPoint = [sender locationInView:self.mapView];
        CLLocationCoordinate2D touchCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        CLLocation *touchLocation = [[CLLocation alloc] initWithLatitude:touchCoordinate.latitude longitude:touchCoordinate.longitude];
        
        // посылаем данные в массив (передавая блок с кодом формирования элемента массива)
        [self addToArrayPointFromLocation:touchLocation withData:^(NSString *street, NSString *city, NSString *zipCode) {
            
            // создаём аннотацию
            MKPointAnnotation * annotation = [[MKPointAnnotation alloc]init];
            annotation.title = [NSString stringWithFormat:@"%@\n%@, %@", street, zipCode, city];
            annotation.coordinate = touchLocation.coordinate;
            
            // создаём словарь - элемент массива
            NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:
                                    annotation, ANNOTATION_KEY,
                                    zipCode, ZIP_KEY,
                                    city, CITY_KEY,
                                    street, STREET_KEY, nil];
            return dict;
        }];
    }
}


// добавление точки в массив (с блоком для формирования элемента массива)
- (void)addToArrayPointFromLocation:(CLLocation *)location withData:(PointArrayElementBlock)getArrayElementBlock {
    // получаем дополнительные геоданные для локации
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *place = placemarks.firstObject;
            NSDictionary *addressDict = place.addressDictionary;
            
            // проверка на пустые значения
            NSString *street = addressDict[STREET_KEY];
            street = (street) ? street : addressDict[NAME_KEY];
            NSString *city = addressDict[CITY_KEY];
            city = (city) ? city : addressDict[COUNTRY_KEY];
            NSString *zipCode = addressDict[ZIP_KEY];
            zipCode = (zipCode) ? zipCode : @"xxxxxx";
            
            // добавляем в массив (вызывая блок для формирования элемента массива)
            [self.arrayPoints addObject:getArrayElementBlock(street, city, zipCode)];
            
            // сообщение пользователю
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Точка добавлена"
                                                           message:[NSString stringWithFormat:@"%@\n%@, %@", street, zipCode, city]
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [alert show];
        }
    }];
}


#pragma mark - Buttons Actions

// обработчик нажатия кнопки "Обновить"
- (IBAction)btnRefreshPressed:(id)sender {
    if (self.arrayPoints.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Нет точек"
                                                       message:@"Сначала добавьте точки долгим нажатием на карту"
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
    } else {
        [self reloadAnnotations];
        [self fitAnnotations];
    }
}

// обработчик нажатия кнопки "Очистить"
- (IBAction)btnClearPressed:(id)sender {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.arrayPoints removeAllObjects];
    
    // запускаем обновление текущего положения
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

@end