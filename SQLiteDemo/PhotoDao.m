//
//  PhotoDao.m
//  SQLiteDemo
//
//  Created by Yang.Lv on 2017/7/17.
//  Copyright © 2017年 czl. All rights reserved.
//

#import "PhotoDao.h"
#import "SQLiteManager.h"

@implementation PhotoDao

#pragma mark - public
+ (BOOL)insertPhoto:(PhotoModel *)photo
{
    __block BOOL    success = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inDatabase:^(FMDatabase *_Nonnull db) {
        success = [self _insertPhoto:photo dataBase:db];
    }];

    return success;
}

+ (BOOL)insertPhotos:(NSArray *)photos
{
    __block BOOL    success = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        for (PhotoModel *model in photos) {
            if (![model isKindOfClass:[PhotoModel class]]) {
                continue;
            }

            success = [self _insertPhoto:model dataBase:db];

            if (!success) {
                *rollback = YES;
                break;
            }
        }
    }];
    return success;
}

+ (BOOL)updatePhoto:(PhotoModel *)photo
{
    __block BOOL    success = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inDatabase:^(FMDatabase *_Nonnull db) {
        success = [self _updatePhoto:photo dataBase:db];
    }];

    return success;
}

+ (BOOL)updatePhotos:(NSArray *)photos
{
    __block BOOL    success = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        for (PhotoModel *model in photos) {
            success = [self _updatePhoto:model dataBase:db];

            if (!success) {
                *rollback = YES;
                break;
            }
        }
    }];

    return success;
}

+ (BOOL)insertOrUpdatePhoto:(PhotoModel *)photo
{
    if (![photo isKindOfClass:[PhotoModel class]]) {
        return NO;
    }

    BOOL    success = NO;
    BOOL    exist = [self isPhotoExist:photo];

    if (exist) {
        success = [self updatePhoto:photo];
    } else {
        success = [self insertPhoto:photo];
    }

    return success;
}

+ (BOOL)insertOrUpdatePhotos:(NSArray *)photos
{
    __block BOOL    success = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        for (PhotoModel *model in photos) {
            if (![model isKindOfClass:[PhotoModel class]]) {
                continue;
            }

            BOOL exist = [self _isPhotoExist:model dataBase:db];

            if (exist) {
                success = [self _updatePhoto:model dataBase:db];
            } else {
                success = [self _insertPhoto:model dataBase:db];
            }

            if (!success) {
                *rollback = YES;
                break;
            }
        }
    }];

    return success;
}

+ (BOOL)isPhotoExist:(PhotoModel *)photo
{
    __block BOOL    exist = NO;
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];

    [queue inDatabase:^(FMDatabase *_Nonnull db) {
        exist = [self _isPhotoExist:photo dataBase:db];
    }];

    return exist;
}

#pragma mark - private
+ (BOOL)_insertPhoto:(PhotoModel *)photo dataBase:(FMDatabase *)dataBase
{
    BOOL            success = NO;
    NSString        *sqlString = [self _assembleInsertPhotoString];
    NSDictionary    *dictionary = [self _transferPhotoModelToInsertDictionary:photo];

    if (dictionary.count == 0) {
        return NO;
    }

    success = [dataBase executeUpdate:sqlString withParameterDictionary:dictionary];
    photo.localPhotoId = dataBase.lastInsertRowId;

    return success;
}

+ (BOOL)_updatePhoto:(PhotoModel *)photo dataBase:(FMDatabase *)dataBase
{
    BOOL            success = NO;
    NSString        *sqlString = [self _assembleUpdatePhotoString:photo];
    NSDictionary    *dictionary = [self _transferPhotoModelToUpdateDictionary:photo];

    if (dictionary.count == 0) {
        return NO;
    }

    success = [dataBase executeUpdate:sqlString withParameterDictionary:dictionary];

    return success;
}

+ (BOOL)_isPhotoExist:(PhotoModel *)photo dataBase:(FMDatabase *)dataBase
{
    BOOL        exist = NO;
    NSString    *sqlString = [NSString stringWithFormat:@"select count(*) from photo where photoId = '%@'", photo.photoId];
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

+ (NSString *)_assembleInsertPhotoString
{
    NSDictionary    *dic = [[SQLiteManager shareManager] photoTableCollumn];
    NSMutableString *string = [NSMutableString stringWithString:@"insert into photo ("];
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

        if ([key isEqualToString:@"localPhotoId"]) {
            [string appendString:@"NULL"];
        } else {
            [string appendFormat:@":%@", key];
        }
    }

    [string appendString:@")"];

    return string;
}

+ (NSString *)_assembleUpdatePhotoString:(PhotoModel *)photo
{
    NSDictionary    *dictionary = [[SQLiteManager shareManager] photoTableCollumn];
    NSMutableString *string = [[NSMutableString alloc]initWithString:@"update photo set "];
    NSInteger       ctrl = 0;

    for (NSString *key in [dictionary allKeys]) {
        if ([key isEqualToString:@"localPhotoId"]) {
            continue;
        }

        if (ctrl == 0) {
            ctrl = 1;
        } else {
            [string appendString:@","];
        }

        [string appendFormat:@"%@=:%@", key, key];
    }

    [string appendFormat:@" where photoId = '%@'", photo.photoId];

    return string;
}

+ (NSDictionary *)_transferPhotoModelToInsertDictionary:(PhotoModel *)photo
{
    if (photo.photoId == nil) {
        photo.photoId = @"";
    }

    if (photo.url == nil) {
        photo.url = @"";
    }

    NSDictionary *dictionary = @{@"photoId"     : photo.photoId,
                                 @"url"         : photo.url,
                                 @"modifyTime"  : @([[NSDate date] timeIntervalSince1970])};
    return dictionary;
}

+ (NSDictionary *)_transferPhotoModelToUpdateDictionary:(PhotoModel *)photo
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (photo.photoId) {
        [dictionary setObject:photo.photoId forKey:@"photoId"];
    }

    if (photo.url) {
        [dictionary setObject:photo.url forKey:@"url"];
    }

    [dictionary setObject:@([[NSDate date] timeIntervalSince1970]) forKey:@"modifyTime"];

    return dictionary;
}

@end
