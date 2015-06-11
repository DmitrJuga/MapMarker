//
//  DDPointList.m
//  MapMarker
//
//  Created by DmitrJuga on 16.05.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "DDPointList.h"

@interface DDPointList()

@property (strong, nonatomic) NSMutableArray *pointList;
@property (weak, nonatomic) DDCoreDataHelper *coreData;

@end

@implementation DDPointList


// инициализатор класса (создаём необходимые объекты)
- (instancetype)init {
    self = [super init];
    if (self) {
        self.coreData = [DDCoreDataHelper sharedInstance];
        self.pointList = [NSMutableArray array];
    }
    return self;
}

// метод класса, возвращающий синглтон
+ (instancetype)sharedPointList {
    
    static DDPointList *singleton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
        [singleton loadPoints];
    });
    
    return singleton;
}

// getter для свойства array
- (NSArray *)array {
    return self.pointList;
}

// getter для свойства count
- (NSUInteger)count {
    return self.array.count;
}

// загрузка точек
- (void)loadPoints {
    [self.pointList removeAllObjects];
    [self.pointList addObjectsFromArray:[self.coreData fetchObjectsForEntity:[DDPoint entityName]]];
}

// добавление (сохранение) новой точки
- (void)addPoint:(DDPoint *)point {
    [self.pointList addObject:point];
    [self.coreData save];
}

// удаление точки
- (void)deletePointAtIndex:(NSUInteger)index {
    [self.coreData deleteObject:self.array[index]];
    [self.pointList removeObjectAtIndex:index];
    [self.coreData save];
}

// удаление всех точек
- (void)deleteAllPoints {
    for (DDPoint *point in self.pointList) {
        [self.coreData deleteObject:point];
    }
    [self.pointList removeAllObjects];
    [self.coreData save];
}

@end
