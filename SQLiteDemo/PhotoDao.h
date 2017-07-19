//
//  PhotoDao.h
//  SQLiteDemo
//
//  Created by Yang.Lv on 2017/7/17.
//  Copyright © 2017年 czl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoModel.h"

@interface PhotoDao : NSObject

+ (BOOL)insertPhoto:(PhotoModel *)photo;
+ (BOOL)insertPhotos:(NSArray *)photos; // 事务操作

+ (BOOL)updatePhoto:(PhotoModel *)photo;
+ (BOOL)updatePhotos:(NSArray *)photos; // 事务操作

+ (BOOL)insertOrUpdatePhoto:(PhotoModel *)photo;
+ (BOOL)insertOrUpdatePhotos:(NSArray *)photos; // 事务操作

+ (BOOL)isPhotoExist:(PhotoModel *)photo;

@end
