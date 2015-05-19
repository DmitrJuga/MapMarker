//
//  ListViewController.m
//  MapLesson
//
//  Created by DmitrJuga on 17.05.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "AppConstants.h"
#import "ListViewController.h"
#import "PointTableViewCell.h"
#import "DDUModel.h"


@interface ListViewController ()

@property (weak, nonatomic) IBOutlet UIView *customNavBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayPoints;

@end


@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customNavBar.layer.borderWidth = 0.5;
    self.customNavBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.arrayPoints = [DDUModel sharedModel].arrayPoints;
    self.tableView.tableFooterView = [[UIView alloc]init];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

// кол-во строк в таблице
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayPoints.count;
}

// заполнение ячейки в таблице
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PointTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:POINT_CELL_ID];
    [cell setWithDict: self.arrayPoints[indexPath.row]];
    return cell;
}


#pragma mark - UITableViewDelegate

// выбор строки в таблице - показываем выбранную точку (аннотацию) на карте
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // переключаемся на вью с картой
    self.tabBarController.selectedIndex = 0;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // отправляем нотификацию для перехода на аннотацию
    NSDictionary *pointDict = self.arrayPoints[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:SELECT_NOTIF object:self userInfo:pointDict];
}

// разрешаем редактирование таблицы
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// удаление одной строки
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.arrayPoints removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

#pragma mark - Buttons Actions

// обработчик нажатия кнопки "Очистить"
- (IBAction)btnClearPressed:(id)sender {
    [self.arrayPoints removeAllObjects];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}


@end
