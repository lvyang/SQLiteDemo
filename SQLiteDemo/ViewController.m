//
//  ViewController.m
//  SQLiteDemo
//
//  Created by Yang.Lv on 2017/6/19.
//  Copyright © 2017年 czl. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AlbumModel.h"
#import "PhotoModel.h"
#import <CommonCrypto/CommonDigest.h>
#import "SQLiteManager.h"
#import "AlbumDao.h"
#import "PhotoDao.h"
#import "BSStringUtil.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *albums;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.albums = [NSMutableArray array];
}

- (IBAction)importPhotos:(id)sender
{
    if ([AlbumDao countOfAlbum] != 0) {
        [self showPrompt:@"照片已经导入过了"];
        return;
    }

    [self showLoadingProgress:nil];
    [self loadImagesFromLibraryCompleted:^(NSError *error, NSArray *result) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoadingProgress];
                [self showPrompt:error.localizedDescription];
            });
            return;
        }

        for (ALAssetsGroup *group in result) {
            AlbumModel *album = [[AlbumModel alloc] init];
            album.name = [group valueForProperty:ALAssetsGroupPropertyName];
            album.albumType = [group valueForProperty:ALAssetsGroupPropertyType];
            album.albumId = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
            album.albumUrl = [group valueForProperty:ALAssetsGroupPropertyURL];
            [self.albums addObject:album];

            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    PhotoModel *photo = [[PhotoModel alloc] init];
                    photo.url = [[result valueForProperty:ALAssetPropertyAssetURL] absoluteString];
                    photo.photoId = [BSStringUtil md5String:photo.url];
                    [album.photos addObject:photo];
                }
            }];
        }

        NSDate *date = [NSDate date];
        BOOL success = NO;

        // 相册存储
        {
            success = [AlbumDao insertOrUpdateAlbums:self.albums];

            if (success) {
                NSLog(@"相册存储成功");
            } else {
                NSLog(@"相册存储失败");
            }
        }

        // 照片存储
        {
            NSMutableArray *photos = [NSMutableArray array];

            for (AlbumModel *album in self.albums) {
                [photos addObjectsFromArray:album.photos];
            }

            /*
             *   大量插入更新操作使用事务，否则将会十分耗时，例如下面这种写法
             *
             *   for (PhotoModel *photo in photos) {
             *      [PhotoDao insertOrUpdatePhoto:photo];
             *   }
             */
            success = [PhotoDao insertOrUpdatePhotos:photos];

            if (success) {
                NSLog(@"照片存储成功");
            } else {
                NSLog(@"照片存储失败");
            }
        }

        // 中间表存储
        {
            success = NO;

            for (AlbumModel *album in self.albums) {
                success = [AlbumDao addPhotos:album.photos toAlbum:album.albumId];

                if (!success) {
                    break;
                }
            }

            if (success) {
                NSLog(@"关系表存储成功");
            } else {
                NSLog(@"关系表存储失败");
            }
        }

        NSLog(@"%f", [[NSDate date] timeIntervalSinceDate:date]);

        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingProgress];
        });
    }];
}

- (void)loadImagesFromLibraryCompleted:(void (^)(NSError *error, NSArray <ALAssetsGroup *> *result))completed
{
    NSMutableArray  *groups = [NSMutableArray array];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // group == nil means an enumerate end
        if (!group) {
            completed(nil, groups);
            return;
        }

        [groups addObject:group];
    } failureBlock:^(NSError *error) {
        completed(error, nil);
    }];
}

@end
