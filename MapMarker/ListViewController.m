//
//  ListViewController.m
//  MapMarker
//
//  Created by DmitrJuga on 17.05.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "AppConstants.h"
#import "MapViewController.h"
#import "ListViewController.h"
#import "PointTableViewCell.h"
#import "DDPointList.h"


@interface ListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *customNavBar;
@property (nonatomic, strong) DDPointList *pointList;

@end


@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    // custom NavigationBar
    self.customNavBar.layer.borderWidth = 0.5;
    self.customNavBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    // модель
    self.pointList = [DDPointList sharedPointList];
}

// обновление перед отображением
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

// кол-во строк в таблице
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pointList.count;
}

// заполнение ячейки в таблице
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PointTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:POINT_CELL_ID];
    [cell setupWithPoint:self.pointList.array[indexPath.row]];
    return cell;
}


#pragma mark - UITableViewDelegate

// выбор строки в таблице - показываем выбранную точку (аннотацию) на карте
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // переключаемся на вью с картой
    self.tabBarController.selectedIndex = 0;
    MapViewController *mapVC = self.tabBarController.viewControllers[0];
    [mapVC selectAnnotation: self.pointList.array[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

// разрешаем редактирование таблицы
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// удаление одной строки
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.pointList deletePointAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:YES];
    }
}

#pragma mark - Button Actions

// обработчик нажатия кнопки "Очистить"
- (IBAction)btnClearPressed:(id)sender {
    if (self.pointList.count > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Удаление"
                                                                       message:@"Все точки будут удалены безвозвратно!"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Удалить" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            // удаляем
            [self.pointList deleteAllPoints];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                          withRowAnimation:UITableViewRowAnimationFade];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


@end
