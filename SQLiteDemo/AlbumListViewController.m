//
//  AlbumListViewController.m
//  SQLiteDemo
//
//  Created by Yang.Lv on 2017/7/18.
//  Copyright © 2017年 czl. All rights reserved.
//

#import "AlbumListViewController.h"
#import "AlbumModel.h"
#import "AlbumDao.h"
#import "AlbumDetailViewController.h"

static NSString *ALBUM_CELL_IDENTIFIER = @"albumCellIdentifier";

@interface AlbumListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (nonatomic, strong) NSMutableArray        *dataArray;

@end

@implementation AlbumListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataArray = [NSMutableArray array];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ALBUM_CELL_IDENTIFIER];

    [self loadData];
}

- (void)loadData
{
    [self showLoadingProgress:nil];
    [AlbumDao loadAllAlbumsCompleted:^(NSError *error, NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingProgress];

            if (error) {
                [self showPrompt:error.localizedDescription];
                return;
            }

            [self.dataArray setArray:results];
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ALBUM_CELL_IDENTIFIER forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    AlbumModel *model = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.name;

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard                *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AlbumDetailViewController   *vc = [storyboard instantiateViewControllerWithIdentifier:@"AlbumDetailViewController"];
    vc.album = [self.dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
