//
//  PhotoModel.h
//  SQLiteDemo
//
//  Created by Yang.Lv on 2017/7/10.
//  Copyright © 2017年 czl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoModel : NSObject

@property (nonatomic, assign) NSInteger localPhotoId;
@property (nonatomic, strong) NSString  *photoId;
@property (nonatomic, strong) NSString  *url;

@property (nonatomic, strong) NSNumber *modifyTime;

@end
