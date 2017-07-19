//
//  AlbumModel.h
//  SQLiteDemo
//
//  Created by Yang.Lv on 2017/7/10.
//  Copyright © 2017年 czl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumModel : NSObject

@property (nonatomic, assign) NSInteger localAlbumId;

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSNumber  *albumType;
@property (nonatomic, strong) NSString  *albumId;
@property (nonatomic, strong) NSString  *albumUrl;

@property (nonatomic, strong) NSNumber *modifyTime;

@property (nonatomic, strong) NSMutableArray *photos;

@end
