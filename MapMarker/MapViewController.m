//
//  ViewController.m
//  MapMarker
//
//  Created by DmitrJuga on 12.05.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "AppConstants.h"
#import "MapViewController.h"
#import "DDPointList.h"
#import "DDPoint+MKAnnotation.h"
#import "DDCalloutView.h"

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet UIView *customNavBar;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) DDPointList *pointList;

@end


@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // custom NavigationBar
    self.customNavBar.layer.borderWidth = 0.5;
    self.customNavBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    // CoreLocation manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];// (если авторизация выполнена, метод ничего не делает)
    }
    // модель
    self.pointList = [DDPointList sharedPointList];
}

// обновление перед отображением
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadAnnotations];
}


#pragma mark - MapView routines

// обновление (перекстановка) аннотаций на карте
- (void)reloadAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (id<MKAnnotation> annotation in self.pointList.array) {
        [self.mapView addAnnotation:annotation];
    }
}

// масштабирование карты для отображения ВСЕХ аннотаций
- (void)fitAnnotations {
    MKMapRect zoomRect = MKMapRectNull;
    for (id<MKAnnotation>annotation in self.mapView.annotations) {
        if (![annotation isKindOfClass:MKUserLocation.class]) {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    double insetW = -zoomRect.size.width * 0.1;
    double insetH = -zoomRect.size.height * 0.1;
    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, insetW, insetH) animated:YES];
}

// выбор аннотации
- (void)selectAnnotation:(id<MKAnnotation>)annotation {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, DEF_MAP_SCALE, DEF_MAP_SCALE);
    [self.mapView setRegion:region animated:YES];
    [self.mapView selectAnnotation:annotation animated:YES];
}


#pragma mark - MKMapViewDelegate

// создание кастомного view для аннотации
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:MKUserLocation.class]) {
        return nil;
    }
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:ANNOTATION_ID];
    annotationView.image = [UIImage imageNamed:@"map_marker"];
    annotationView.centerOffset = CGPointMake(0, -1 * annotationView.image.size.height / 2);
    annotationView.canShowCallout = NO;
    // создаём кастомный calloutView
    CGRect frame = CGRectMake(annotationView.frame.size.width / 2 - CALLUOT_VIEW_WIDTH / 2,
                              - CALLUOT_VIEW_HEIGHT,
                              CALLUOT_VIEW_WIDTH,
                              CALLUOT_VIEW_HEIGHT);
    DDCalloutView *calloutView = [[DDCalloutView alloc] initWithFrame:frame];
    calloutView.titleLabel.text = annotation.title;
    calloutView.subtitleLabel.text = annotation.subtitle;
    // по умолчанию невидим и сжат
    calloutView.alpha = 0;
    calloutView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [annotationView addSubview:calloutView];
    return annotationView;
}

// обработка нажатия на маркер (выбор аннотации)
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (![view.annotation isKindOfClass:MKUserLocation.class]) {
        // фокус на аннотацию (если не по центру - ставим по центру)
        id<MKAnnotation>annotation = view.annotation;
        if (annotation.coordinate.latitude != mapView.region.center.latitude ||
            annotation.coordinate.longitude != mapView.region.center.longitude) {
            MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, mapView.region.span);
            [mapView setRegion:region animated:YES];
        }
        // анимировнное появление calloutView
        UIView *calloutView = view.subviews.firstObject;
        [UIView animateWithDuration:0.4 animations:^{
            calloutView.alpha = .85;
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
        calloutView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    }];
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
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // фокус на текущцю локацию
    CLLocation *location = locations.lastObject;
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, DEF_MAP_SCALE, DEF_MAP_SCALE) animated:YES];
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - Gesture Recognizer Handler

// обработчик длинного нажатия
- (IBAction)longPressHandle:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        // определяем координаты и локацию нажатия на карте
        CGPoint touchPoint = [sender locationInView:self.mapView];
        CLLocationCoordinate2D touchCoordinate = [self.mapView convertPoint:touchPoint
                                                       toCoordinateFromView:self.mapView];
        CLLocation *touchLocation = [[CLLocation alloc] initWithLatitude:touchCoordinate.latitude
                                                               longitude:touchCoordinate.longitude];
        
        // временная аннотация в точке нажатия
        MKPointAnnotation *tmpAnnotation = [[MKPointAnnotation alloc] init];
        tmpAnnotation.coordinate = touchCoordinate;
        [self.mapView addAnnotation:tmpAnnotation];
        
        // запрашиваем и обрабатываем геоинформацию (нужен адрес точки)
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        [geocoder reverseGeocodeLocation:touchLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"error: %@", error);
                [self.mapView removeAnnotation:tmpAnnotation];
                return;
            }
            NSDictionary *addressDict = ((CLPlacemark *)placemarks.firstObject).addressDictionary;
            // формируем адресную строку (+ проверка на пустые значения)
            NSString *street = addressDict[STREET_KEY];
            street = (street) ?: addressDict[NAME_KEY];
            NSString *city = addressDict[CITY_KEY];
            city = (city) ?: addressDict[COUNTRY_KEY];
            NSString *zipCode = addressDict[ZIP_KEY];
            zipCode = (zipCode) ? [NSString stringWithFormat:@"%@, ", zipCode] : @"";
            NSString *address = [NSString stringWithFormat:@"%@%@, %@", zipCode, city, street];
            
            // запрашиваем у пользователя название точки
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Новая точка"
                                                                           message:address
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Название точки";
                textField.returnKeyType = UIReturnKeyDone;
                textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            }];
            [alert addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self.mapView removeAnnotation:tmpAnnotation];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Добавить" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                // создаём аннотацию
                DDPoint *annotation = [DDPoint newCoreDataObject];
                UITextField *textField = alert.textFields.firstObject;
                annotation.name = ([textField.text isEqualToString:@""]) ? @"Безымянная точка" : textField.text;
                annotation.address = address;
                annotation.coordinate = touchCoordinate;
                [self.pointList addPoint:annotation];
                [self.mapView removeAnnotation:tmpAnnotation];
                [self.mapView addAnnotation:annotation];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }];

    }
}


#pragma mark - Button Actions

// обработчик нажатия кнопки "Текущее положение"
- (IBAction)btnClearPressed:(id)sender {
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

// обработчик нажатия кнопки "Масштаб"
- (IBAction)btnRefreshPressed:(id)sender {
    if (self.pointList.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Нет точек"
                                                                       message:@"Сначала добавьте точки долгим нажатием на карту"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self fitAnnotations];
    }
}


@end