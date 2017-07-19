//
//  AlbumModel.m
//  SQLiteDemo
//
//  Created by Yang.Lv on 2017/7/10.
//  Copyright © 2017年 czl. All rights reserved.
//

#import "AlbumModel.h"

@implementation AlbumModel

- (id)init
{
    if (self = [super init]) {
        self.photos = [NSMutableArray array];
    }
    
    return self;
}

@end
