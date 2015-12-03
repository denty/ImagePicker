//
//  ViewController.m
//  WeiXinPhoto
//
//  Created by 苏贵明 on 15/9/3.
//  Copyright (c) 2015年 苏贵明. All rights reserved.
//

#import "ViewController.h"
#import "SGMAlbumViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,SGMAlbumViewControllerDelegate>

@end

@implementation ViewController{

    UITableView* mainTable;
    NSMutableArray* selectedPhotoArray;
    
    ALAssetsLibrary* assetLibrary;//照片的生命周期跟它有关，所以弄成全局变量在这里初始化

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    selectedPhotoArray = [[NSMutableArray alloc]init];
    
    //全局变量
    assetLibrary = [[ALAssetsLibrary alloc]init];
    
    mainTable = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    mainTable.dataSource = self;
    mainTable.delegate = self;
    mainTable.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:mainTable];
    
}

-(void)btTap{
    SGMAlbumViewController* viewVC = [[SGMAlbumViewController alloc] init];
    viewVC.assetsLibrary =assetLibrary;
    viewVC.limitNum = 3;//不设置即不限制
    [viewVC setDelegate:self];
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:viewVC];
    [self presentViewController:nav animated:YES completion:nil];

}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    UIButton* bt = [[UIButton alloc]initWithFrame:tableView.tableFooterView.bounds];
    [bt setTitle:@"选择照片" forState:UIControlStateNormal];
    [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(btTap) forControlEvents:UIControlEventTouchUpInside];
    return bt;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 80;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return selectedPhotoArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString* identify = @"cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    if ([[selectedPhotoArray objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]])
    {
        ALAsset *asset = [[selectedPhotoArray objectAtIndex:indexPath.row] objectForKey:@"asset"];
        cell.imageView.image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    }
    if ([[selectedPhotoArray objectAtIndex:indexPath.row] isKindOfClass:[UIImage class]])
    {
        cell.imageView.image = [selectedPhotoArray objectAtIndex:indexPath.row];
    }
    else
    {
        NSLog(@"类型错误");
    }
    
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SGMAlbumViewControllerDelegate
- (BOOL)sendImageWithAssetsArray:(NSArray *)array
{
    if (array.count>0) {
        [selectedPhotoArray addObjectsFromArray:array];
        [mainTable reloadData];
        return YES;
    }
    return NO;
}
@end
