//
//  AlbumDao.h
//  SQLiteDemo
//
//  Created by Yang.Lv on 2017/7/14.
//  Copyright © 2017年 czl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlbumModel.h"
#import "PhotoModel.h"

@interface AlbumDao : NSObject

+ (BOOL)insertAlbum:(AlbumModel *)album;
+ (BOOL)insertAlbums:(NSArray *)albums; // 事务操作

+ (BOOL)updateAlbum:(AlbumModel *)album;
+ (BOOL)updateAlbums:(NSArray *)albums; // 事务操作

+ (BOOL)insertOrUpdateAlbum:(AlbumModel *)album;
+ (BOOL)insertOrUpdateAlbums:(NSArray *)albums; // 事务操作

+ (BOOL)addPhoto:(NSString *)photoId toAlbum:(NSString *)albumId;
+ (BOOL)addPhotos:(NSArray <PhotoModel *> *)photos toAlbum:(NSString *)albumId; // 事务操作

+ (BOOL)isAlbumExist:(AlbumModel *)album;

+ (void)loadAllAlbumsCompleted:(void (^)(NSError *error, NSArray *results))completed;
+ (void)loadPhotosInAlbum:(AlbumModel *)album completed:(void (^)(NSError *error, NSArray *results))completed;

+ (NSInteger)countOfAlbum;

@end
