//
//  AlbumDao.m
//  SQLiteDemo
//
//  Created by Yang.Lv on 2017/7/14.
//  Copyright © 2017年 czl. All rights reserved.
//

#import "AlbumDao.h"
#import "SQLiteManager.h"

@implementation AlbumDao

#pragma mark - public
+ (BOOL)insertAlbum:(AlbumModel *)album
{
    __block BOOL    success = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inDatabase:^(FMDatabase *_Nonnull db) {
        success = [self _insertAlbum:album dataBase:db];
    }];

    return success;
}

+ (BOOL)insertAlbums:(NSArray *)albums
{
    __block BOOL    success = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        for (AlbumModel *model in albums) {
            success = [self _insertAlbum:model dataBase:db];

            if (!success) {
                *rollback = YES;
                break;
            }
        }
    }];
    
    return success;
}

+ (BOOL)updateAlbum:(AlbumModel *)album
{
    __block BOOL    success = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inDatabase:^(FMDatabase *_Nonnull db) {
        success = [self _updateAlbum:album dataBase:db];
    }];

    return success;
}

+ (BOOL)updateAlbums:(NSArray *)albums
{
    __block BOOL    success = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        for (AlbumModel *model in albums) {
            success = [self _updateAlbum:model dataBase:db];

            if (!success) {
                *rollback = YES;
                break;
            }
        }
    }];

    return success;
}

+ (BOOL)insertOrUpdateAlbum:(AlbumModel *)album
{
    BOOL    success = NO;
    BOOL    exist = [self isAlbumExist:album];

    if (exist) {
        success = [self updateAlbum:album];
    } else {
        success = [self insertAlbum:album];
    }

    return success;
}

+ (BOOL)insertOrUpdateAlbums:(NSArray *)albums
{
    __block BOOL    success = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        for (AlbumModel *model in albums) {
            BOOL exist = [self _isAlbumExist:model dataBase:db];

            if (exist) {
                success = [self _updateAlbum:model dataBase:db];
            } else {
                success = [self _insertAlbum:model dataBase:db];
            }

            if (!success) {
                *rollback = YES;
                break;
            }
        }
    }];

    return success;
}

+ (BOOL)addPhoto:(NSString *)photoId toAlbum:(NSString *)albumId
{
    __block BOOL    success = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inDatabase:^(FMDatabase *_Nonnull db) {
        success = [self _addPhoto:photoId toAlbum:albumId dataBase:db];
    }];

    return success;
}

+ (BOOL)addPhotos:(NSArray <PhotoModel *> *)photos toAlbum:(NSString *)albumId
{
    __block BOOL    success = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        for (PhotoModel *photo in photos) {
            success = [self _addPhoto:photo.photoId toAlbum:albumId dataBase:db];

            if (!success) {
                *rollback = YES;
                break;
            }
        }
    }];

    return success;
}

+ (BOOL)isAlbumExist:(AlbumModel *)album
{
    __block BOOL    exist = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inDatabase:^(FMDatabase *_Nonnull db) {
        exist = [self _isAlbumExist:album dataBase:db];
    }];

    return exist;
}

+ (void)loadAllAlbumsCompleted:(void (^)(NSError *error, NSArray *results))completed
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *dataArray = [NSMutableArray array];
        NSString *sqlString = @"select * from album;";
        FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

        [queue inDatabase:^(FMDatabase *_Nonnull db) {
            FMResultSet *set = [db executeQuery:sqlString];

            if (!set) {
                completed(db.lastError, nil);
                return;
            }

            while ([set next]) {
                NSDictionary *result = [set resultDictionary];
                AlbumModel *model = [[AlbumModel alloc] init];
                model.localAlbumId = [[result objectForKey:@"localAlbumId"] integerValue];
                model.albumId = [result objectForKey:@"albumId"];
                model.albumUrl = [result objectForKey:@"albumUrl"];
                model.name = [result objectForKey:@"name"];
                model.albumType = [result objectForKey:@"albumType"];
                model.modifyTime = [result objectForKey:@"modifyTime"];
                [dataArray addObject:model];
            }

            [set close];

            completed(nil, dataArray);
        }];
    });
}

+ (void)loadPhotosInAlbum:(AlbumModel *)album completed:(void (^)(NSError *error, NSArray *results))completed
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *dataArray = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"select a.* from photo a, albumPhoto b where b.albumId = '%@' and a.photoId = b.photoId", album.albumId];
        FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

        [queue inDatabase:^(FMDatabase *_Nonnull db) {
            FMResultSet *set = [db executeQuery:sqlString];

            if (!set) {
                completed(db.lastError, nil);
                return;
            }

            while ([set next]) {
                NSDictionary *result = [set resultDictionary];
                PhotoModel *photo = [[PhotoModel alloc] init];
                photo.localPhotoId = [[result objectForKey:@"localPhotoId"] integerValue];
                photo.photoId = [result objectForKey:@"photoId"];
                photo.url = [result objectForKey:@"url"];
                photo.modifyTime = [result objectForKey:@"modifyTime"];
                [dataArray addObject:photo];
            }

            [set close];

            completed(nil, dataArray);
        }];
    });
}

+ (NSInteger)countOfAlbum
{
    NSString            *sqlString = @"select count(*) from album";
    FMDatabaseQueue     *queue = [SQLiteManager dataBaseQueue];
    __block NSInteger   count = 0;

    [queue inDatabase:^(FMDatabase *_Nonnull db) {
        FMResultSet *set = [db executeQuery:sqlString];

        while ([set next]) {
            NSDictionary *result = [set resultDictionary];
            count = [[result objectForKey:@"count(*)"] integerValue];
        }

        [set close];
    }];

    return count;
}

#pragma mark - private
+ (BOOL)_insertAlbum:(AlbumModel *)album dataBase:(FMDatabase *)dataBase
{
    BOOL            success = NO;
    NSString        *sqlString = [self _assembleInsertAlbumString];
    NSDictionary    *dictionary = [self _transferAlbumModelToInsertDictionary:album];

    if (dictionary.count == 0) {
        return NO;
    }

    success = [dataBase executeUpdate:sqlString withParameterDictionary:dictionary];
    album.localAlbumId = dataBase.lastInsertRowId;

    return success;
}

+ (BOOL)_updateAlbum:(AlbumModel *)album dataBase:(FMDatabase *)dataBase
{
    BOOL            success = NO;
    NSString        *sqlString = [self _assembleUpdateAlbumString:album];
    NSDictionary    *dictionary = [self _transferAlbumModelToUpdateDictionary:album];

    if (dictionary.count == 0) {
        return NO;
    }

    success = [dataBase executeUpdate:sqlString withParameterDictionary:dictionary];

    return success;
}

+ (BOOL)_addPhoto:(NSString *)photoId toAlbum:(NSString *)albumId dataBase:(FMDatabase *)dataBase
{
    NSString            *sqlString = [NSString stringWithFormat:@"insert into albumPhoto (albumId, photoId) values (:albumId, :photoId)"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    [params setObject:photoId forKey:@"photoId"];
    [params setObject:albumId forKey:@"albumId"];

    return [dataBase executeUpdate:sqlString withParameterDictionary:params];
}

+ (BOOL)_isAlbumExist:(AlbumModel *)album dataBase:(FMDatabase *)dataBase
{
    BOOL        exist = NO;
    NSString    *sqlString = [NSString stringWithFormat:@"select count(*) from album where albumId = '%@'", album.albumId];
    FMResultSet *set = [dataBase executeQuery:sqlString];

    while ([set next]) {
        NSDictionary *dictionary = [set resultDictionary];

        if ([[dictionary objectForKey:@"count(*)"] integerValue] == 0) {
            exist = NO;
        } else {
            exist = YES;
        }
    }

    [set close];

    return exist;
}

+ (NSString *)_assembleInsertAlbumString
{
    NSDictionary    *dic = [[SQLiteManager shareManager] albumTableCollumn];
    NSMutableString *string = [NSMutableString stringWithString:@"insert into album ("];
    NSArray         *keys = [dic allKeys];
    NSInteger       index = 0;

    for (NSString *key in keys) {
        if (index == 0) {
            index = 1;
        } else {
            [string appendString:@","];
        }

        [string appendString:key];
    }

    [string appendString:@") values ("];

    index = 0;
    for (NSString *key in keys) {
        if (index == 0) {
            index = 1;
        } else {
            [string appendString:@","];
        }

        if ([key isEqualToString:@"localAlbumId"]) {
            [string appendString:@"NULL"];
        } else {
            [string appendFormat:@":%@", key];
        }
    }

    [string appendString:@")"];

    return string;
}

+ (NSString *)_assembleUpdateAlbumString:(AlbumModel *)album
{
    NSDictionary    *dictionary = [[SQLiteManager shareManager] albumTableCollumn];
    NSMutableString *string = [[NSMutableString alloc]initWithString:@"update album set "];
    NSInteger       ctrl = 0;

    for (NSString *key in [dictionary allKeys]) {
        if ([key isEqualToString:@"localAlbumId"]) {
            continue;
        }

        if (ctrl == 0) {
            ctrl = 1;
        } else {
            [string appendString:@","];
        }

        [string appendFormat:@"%@=:%@", key, key];
    }

    [string appendFormat:@" where albumId = '%@'", album.albumId];

    return string;
}

+ (NSDictionary *)_transferAlbumModelToInsertDictionary:(AlbumModel *)album
{
    if (album.name == nil) {
        album.name = @"";
    }

    if (album.albumType == nil) {
        album.albumType = @0;
    }

    if (album.albumId == nil) {
        album.albumId = (NSString *)[NSNull null];
    }

    if (album.albumUrl == nil) {
        album.albumUrl = @"";
    }

    NSDictionary *dictionary = @{@"albumId"      : album.albumId,
                                 @"albumUrl"     : album.albumUrl,
                                 @"name"         : album.name,
                                 @"albumType"    : album.albumType,
                                 @"modifyTime"   : @([[NSDate date] timeIntervalSince1970])};
    return dictionary;
}

+ (NSDictionary *)_transferAlbumModelToUpdateDictionary:(AlbumModel *)album
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (album.albumId) {
        [dictionary setObject:album.albumId forKey:@"albumId"];
    }

    if (album.albumUrl) {
        [dictionary setObject:album.albumUrl forKey:@"albumUrl"];
    }

    if (album.name) {
        [dictionary setObject:album.name forKey:@"name"];
    }

    if (album.albumType) {
        [dictionary setObject:album.albumType forKey:@"albumType"];
    }

    [dictionary setObject:@([[NSDate date] timeIntervalSince1970]) forKey:@"modifyTime"];

    return dictionary;
}

@end
