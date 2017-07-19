//
//  PhotoListCollectionCell.m
//  dodoedu
//
//  Created by Yang.Lv on 16/8/3.
//  Copyright © 2016年 bosu. All rights reserved.
//

#import "PhotoListCollectionCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoListCollectionCell ()

@property (nonatomic, strong) UIImageView *contentImageView;

@end

@implementation PhotoListCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.contentImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.contentImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.contentImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.contentImageView];
    }

    return self;
}

- (void)configureCellWithModel:(PhotoModel *)aModel atIndexPath:(NSIndexPath *)indexPath
{
    NSString        *urlString = aModel.url;
    NSURL           *url = [urlString isKindOfClass:[NSString class]] ?[NSURL URLWithString:urlString] : nil;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

    [library assetForURL:url resultBlock:^(ALAsset *asset) {
        self.contentImageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    } failureBlock:nil];
}

@end
