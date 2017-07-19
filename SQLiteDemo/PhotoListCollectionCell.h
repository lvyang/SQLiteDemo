//
//  PhotoListCollectionCell.h
//  dodoedu
//
//  Created by Yang.Lv on 16/8/3.
//  Copyright © 2016年 bosu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoModel.h"

@interface PhotoListCollectionCell : UICollectionViewCell

- (void)configureCellWithModel:(PhotoModel *)aModel atIndexPath:(NSIndexPath *)indexPath;

@end
