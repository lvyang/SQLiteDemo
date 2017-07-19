//
//  SQLiteManager.h
//  SQLiteDemo
//
//  Created by Yang.Lv on 2017/7/10.
//  Copyright © 2017年 czl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface SQLiteManager : NSObject

+ (instancetype)shareManager;
+ (FMDatabaseQueue *)dataBaseQueue;
- (void)createDataBase;

// collumns
- (NSDictionary *)photoTableCollumn;
- (NSDictionary *)albumTableCollumn;
- (NSDictionary *)albumPhotoTableCollumn;

@end
