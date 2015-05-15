//
//  ViewController.m
//  MapLesson
//
//  Created by DmitrJuga on 12.05.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "MapLessonViewController.h"
#import "PointTableViewCell.h"
#import "AppConstants.h"

@interface MapLessonViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayPoints;

@end


@implementation MapLessonViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    // CL Authorization (for iOS > 8.0)
    if ([UIDevice currentDevice].systemVersion.intValue >=8) {
        // если авторизация выполнена, метод ничего не делает
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.arrayPoints = [[NSMutableArray alloc]init];
    self.tableView.tableFooterView = [[UIView alloc]init];
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
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, DEFAULT_MAP_SCALE, DEFAULT_MAP_SCALE) animated:YES];
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
- (void)annotationsReload {
    [self.mapView removeAnnotations:self.mapView.annotations];

    MKMapRect zoomRect = MKMapRectNull;
    for (NSDictionary *pointDict in self.arrayPoints) {
        // добпаляем аанотацию
        MKPointAnnotation *annotation = pointDict[ANNOTATION_KEY];
        [self.mapView addAnnotation:annotation];
        // вычисляем область, в которую попадают все аннотации
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    // зум для отображения ВСЕХ добавленных аннотаций
    double inset = -zoomRect.size.width * 0.1;
    [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) animated:YES];
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


#pragma mark - UITableViewDataSource

// кол-во строк в таблице
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayPoints.count;
}

// заполнение ячейки в таблице
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PointTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:POINT_CELL_ID];
    NSDictionary *pointDict = self.arrayPoints[indexPath.row];
    
    cell.streetLabel.text = pointDict[STREET_KEY];
    cell.cityLabel.text = [NSString stringWithFormat:@"%@, %@", pointDict[ZIP_KEY], pointDict[CITY_KEY]];
    
    return cell;
}

// перезагрузка строк таблицы
- (void)tableViewReload {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];});
}


#pragma mark - UITableViewDelegate

// выбор строки в таблице - показываем выбранную точку (аннотацию) на карте
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *pointDict = self.arrayPoints[indexPath.row];
    
    MKPointAnnotation *annotation = pointDict[ANNOTATION_KEY];
    [self.mapView selectAnnotation:annotation animated:YES];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, DEFAULT_MAP_SCALE, DEFAULT_MAP_SCALE);
    [self.mapView setRegion:region animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Gesture Recognizer Handler

// обработчик длинного нажатия
- (IBAction)longPressHandle:(UILongPressGestureRecognizer *)sender {
   
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        // определяем координаты и локацию нажатия на карте
        CGPoint touchPoint = [sender locationInView:self.mapView];
        CLLocationCoordinate2D touchCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        CLLocation *touchLocation = [[CLLocation alloc] initWithLatitude:touchCoordinate.latitude longitude:touchCoordinate.longitude];
        
        // получаем дополнительные геоданные для точки
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        [geocoder reverseGeocodeLocation:touchLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error) {
                CLPlacemark *place = placemarks.firstObject;
                NSDictionary *addressDict = place.addressDictionary;
                
                // проверка на пустые значения
                NSString *street = addressDict[STREET_KEY];
                street = (street) ? street : addressDict[NAME_KEY];
                NSString *city = addressDict[CITY_KEY];
                city = (city) ? city : addressDict[COUNTRY_KEY];
                NSString *zip = addressDict[ZIP_KEY];
                zip = (zip) ? zip : @"xxxxxx";

                NSString *addressString = [NSString stringWithFormat:@"%@\n%@, %@", street, zip, city];
                
                // создаём аннотацию
                MKPointAnnotation * annotation = [[MKPointAnnotation alloc]init];
                annotation.title = addressString;
                annotation.coordinate = touchCoordinate;
                
                // сохраняем аннотацию и адресные данные в массив
                NSDictionary *pointDict = [[NSDictionary alloc]initWithObjectsAndKeys:
                                           annotation, ANNOTATION_KEY,
                                           zip, ZIP_KEY, city, CITY_KEY, street, STREET_KEY, nil];
                [self.arrayPoints addObject:pointDict];
                
                // сообщение пользователю
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Точка добавлена" message:addressString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}


#pragma mark - Buttons Actions

// обработчик нажатия кнопки "Обновить"
- (IBAction)btnRefreshPressed:(id)sender {
    if (self.arrayPoints.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Нет точек" message:@"Сначала добавьте точки долгим нажатием на карту" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [self annotationsReload];
        [self tableViewReload];
    }
}

// обработчик нажатия кнопки "Очистить"
- (IBAction)btnClearPressed:(id)sender {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.arrayPoints removeAllObjects];
    [self tableViewReload];
    
    // запускаем обновление текущего положения
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

@end
