//
//  AlbumDetailViewController.m
//  SQLiteDemo
//
//  Created by Yang.Lv on 2017/7/18.
//  Copyright © 2017年 czl. All rights reserved.
//

#import "AlbumDetailViewController.h"
#import "AlbumDao.h"
#import "PhotoListCollectionCell.h"

static NSString *PHOTO_CELL_ID = @"photoCellId";

@interface AlbumDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView   *collectionView;
@property (nonatomic, strong) NSMutableArray            *dataArray;

@end

@implementation AlbumDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = YES;
    self.dataArray = [NSMutableArray array];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[PhotoListCollectionCell class] forCellWithReuseIdentifier:PHOTO_CELL_ID];
    self.collectionView.collectionViewLayout = [self flowLayout];

    [self loadData];
}

- (void)loadData
{
    [self showLoadingProgress:nil];
    [AlbumDao loadPhotosInAlbum:self.album completed:^(NSError *error, NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingProgress];
            [self.dataArray setArray:results];
            [self.collectionView reloadData];
        });
    }];
}

- (UICollectionViewFlowLayout *)flowLayout
{
    CGFloat                     screenWidth = [UIScreen mainScreen].bounds.size.width;
    UICollectionViewFlowLayout  *layout = [UICollectionViewFlowLayout new];

    layout.itemSize = CGSizeMake((screenWidth - 15) / 4, (screenWidth - 15) / 4);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 5;

    return layout;
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoListCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PHOTO_CELL_ID forIndexPath:indexPath];

    [cell configureCellWithModel:self.dataArray[indexPath.row] atIndexPath:indexPath];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

@end
