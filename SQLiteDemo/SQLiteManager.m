//
//  SQLiteManager.m
//  SQLiteDemo
//
//  Created by Yang.Lv on 2017/7/10.
//  Copyright © 2017年 czl. All rights reserved.
//

#import "SQLiteManager.h"

@interface SQLiteManager ()


@end

@implementation SQLiteManager

+ (instancetype)shareManager
{
    static SQLiteManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SQLiteManager alloc] init];
    });
    return manager;
}

+ (FMDatabaseQueue *)dataBaseQueue
{
    static FMDatabaseQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [FMDatabaseQueue databaseQueueWithPath:[self dataBasePath]];
    });
    return queue;
}

#pragma mark - public
- (void)createDataBase
{
    [self createTables];
    [self createIndexes];
}

#pragma mark - private
+ (NSString *)dataBasePath
{
    NSString        *searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString        *downloadPath = [searchPath stringByAppendingPathComponent:@"data"];
    NSString        *fileName = @"camera.sqlite";
    NSFileManager   *manager = [NSFileManager defaultManager];
    NSError         *error = nil;
    
    [manager createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error) {
        return nil;
    }
    
    return [downloadPath stringByAppendingPathComponent:fileName];
}

#pragma mark - create tables & index & view
- (void)createTables
{
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        [db executeUpdate:[self assembleCreatePhotoTableString]];
        [db executeUpdate:[self assembleCreateAlbumTableString]];
        [db executeUpdate:[self assembleCreateAlbumPhotoTableString]];
    }];
}

- (void)createIndexes
{
    [self addTableIndex:@"photo_photoId_index" indexSql:@"create index photo_photoId_index on photo(photoId)"];
}

// add index
- (void)addTableIndex:(NSString *)indexName indexSql:(NSString *)indexSql
{
    NSArray *indexes = [self queryTableIndexes];
    
    for (NSString *name in indexes) {
        if ([indexName isEqualToString:name]) {
            return;
        }
    }
    
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:indexSql];
    }];
}

// delete index
- (void)deleteTableIndex:(NSString *)indexName
{
    NSString *sqlString = nil;
    NSArray *indexes = [self queryTableIndexes];
    
    for (NSString *index in indexes) {
        if ([index isEqualToString:indexName]) {
            sqlString = [NSString stringWithFormat:@"drop index %@",indexName];
            break;
        }
    }
    
    if (!sqlString) {
        return;
    }
    
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:sqlString];
    }];
}

- (NSArray *)queryTableIndexes
{
    NSMutableArray *indexes = [NSMutableArray array];
    NSString *sqlString = @"select name from sqlite_master where type = 'index'";
    FMDatabaseQueue *queue = [SQLiteManager dataBaseQueue];
    
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:sqlString];
        while ([set next]) {
            NSDictionary *dictionary = [set resultDictionary];
            if ([dictionary objectForKey:@"name"]) {
                [indexes addObject:[dictionary objectForKey:@"name"]];
            }
        }
        [set close];
    }];
    
    return indexes;
}

#pragma mark - assemble SQL strings
- (NSString *)assembleCreatePhotoTableString
{
    NSDictionary *collumn = [self photoTableCollumn];
    NSMutableString *string = [NSMutableString stringWithString:@"create table if not exists photo ("];
    __block BOOL index = 0;
    [collumn enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (index == 0) {
            index = 1;
        } else {
            [string appendString:@", "];
        }
        
        NSString *field = [NSString stringWithFormat:@"%@ %@",key,obj];
        [string appendString:field];
        
        if ([key isEqualToString:@"localPhotoId"]) {
            [string appendString:@" primary key autoincrement"];
        }
    }];
    [string appendString:@")"];
    
    return string;
}

- (NSString *)assembleCreateAlbumTableString
{
    NSDictionary *collumn = [self albumTableCollumn];
    NSMutableString *string = [NSMutableString stringWithString:@"create table if not exists album ("];
    __block BOOL index = 0;
    [collumn enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (index == 0) {
            index = 1;
        } else {
            [string appendString:@", "];
        }
        
        NSString *field = [NSString stringWithFormat:@"%@ %@",key,obj];
        [string appendString:field];
        
        if ([key isEqualToString:@"localAlbumId"]) {
            [string appendString:@" primary key autoincrement"];
        }
    }];
    [string appendString:@")"];
    
    return string;
}

- (NSString *)assembleCreateAlbumPhotoTableString
{
    NSDictionary *collumn = [self albumPhotoTableCollumn];
    NSMutableString *string = [NSMutableString stringWithString:@"create table if not exists albumPhoto ("];
    __block BOOL index = 0;
    
    [collumn enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (index == 0) {
            index = 1;
        } else {
            [string appendString:@", "];
        }
        
        NSString *field = [NSString stringWithFormat:@"%@ %@",key,obj];
        [string appendString:field];
    }];
    
    [string appendString:@")"];
    
    return string;
}

#pragma mark -  table collumns
- (NSDictionary *)photoTableCollumn
{
    NSDictionary *collumn = @{@"localPhotoId" : @"integer",
                              @"photoId"      : @"text",
                              @"url"          : @"text",
                              @"modifyTime"   : @"integer"};

    return collumn;
}

- (NSDictionary *)albumTableCollumn
{
    NSDictionary *collumn = @{@"localAlbumId" : @"integer",
                              @"albumId"      : @"text",
                              @"albumUrl"     : @"text",
                              @"name"         : @"text",
                              @"albumType"    : @"integer",
                              @"modifyTime"   : @"integer"};
    
    return collumn;
}

- (NSDictionary *)albumPhotoTableCollumn
{
    NSDictionary *collumn = @{@"albumId" : @"text",
                              @"photoId" : @"text"};
    
    return collumn;
}

@end
