//
//  SGMPhotosViewController.m
//  WeiXinPhoto
//
//  Created by 苏贵明 on 15/9/4.
//  Copyright (c) 2015年 苏贵明. All rights reserved.
//
#define kScreenWidth     [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight    [[UIScreen mainScreen] bounds].size.height
#define imageTagBase         10
#define buttonTagBase        20

#import "SGMPhotosViewController.h"
#import "DNPhotoBrowser.h"

@interface SGMPhotosViewController ()<UITableViewDataSource,UITableViewDelegate,DNPhotoBrowserDelegate>

@end

@implementation SGMPhotosViewController{
    
    float VIEW_WIDTH;
    float VIEW_HEIGHT;
    
    float imgWidth;//照片宽度
    float imgGap;//照片间隙宽度

    UITableView* mainTable;
    NSMutableArray* assetArray;
    NSMutableArray* selectedArray;
    
    long numOfPerRow;//每行几张照片
    long rowNum;//总共多少行
    
    //--- footerView上的控件
    UIButton* previewBt;
    UIButton* finishBt;
    UILabel* numLabel;

}
@synthesize group,limitNum;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    VIEW_WIDTH = self.view.frame.size.width;
    VIEW_HEIGHT = self.view.frame.size.height;
    
    imgWidth = (kScreenWidth-5-5-5-5-5)/4;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(cancelBtTap)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:nil];
    
    NSString* name =[group valueForProperty:ALAssetsGroupPropertyName];
    if ([name  isEqual: @"Camera Roll"]) {
        name = @"相机胶卷";
    }
    self.title =name;
    
    assetArray = [[NSMutableArray alloc]init];
    selectedArray = [[NSMutableArray alloc]init];
    numOfPerRow = 4;//默认
    
    CGRect tableFrame = self.view.bounds;
    tableFrame.size.height -= 45;
    mainTable = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
    mainTable.dataSource = self;
    mainTable.delegate = self;
    mainTable.tableFooterView = [[UIView alloc] init];
    mainTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:mainTable];
    
    [self initFooterView];
    
    //---获取group中的asset
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                NSMutableDictionary* tmpDic = [[NSMutableDictionary alloc]init];
                [tmpDic setObject:result forKey:@"asset"];
                [tmpDic setObject:[NSString stringWithFormat:@"%d",(int)index] forKey:@"assetIndex"];
                [tmpDic setObject:@NO forKey:@"select"];
                [assetArray addObject:tmpDic];
            }else{
                [self calculateNum];
                [mainTable reloadData];
            }
        }];
}
-(void)calculateNum
{
    numOfPerRow = 4;
    if (assetArray.count%numOfPerRow == 0) {
        rowNum = assetArray.count/numOfPerRow;
    }
    else
    {
        rowNum = assetArray.count/numOfPerRow+1;
    }
    imgGap = 5;
}

-(void)initFooterView{
   
    UIView* backView = [[UIView alloc]initWithFrame:CGRectMake(0, VIEW_HEIGHT-45, VIEW_WIDTH, 45)];
    backView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    [self.view addSubview:backView];
    
    UILabel* grayLine = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, 1)];
    grayLine.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
    [backView addSubview:grayLine];
    
    previewBt = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 45)];
    [previewBt setTitle:@"预览" forState:UIControlStateNormal];
    previewBt.titleLabel.font = [UIFont systemFontOfSize:15];
    [previewBt setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.3] forState:UIControlStateNormal];
    [previewBt addTarget:self action:@selector(previewBtTaped) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:previewBt];
    
    finishBt = [[UIButton alloc]initWithFrame:CGRectMake(VIEW_WIDTH-60, 0, 60, 45)];
    [finishBt setTitle:@"完成" forState:UIControlStateNormal];
    finishBt.titleLabel.font = [UIFont systemFontOfSize:15];
    [finishBt addTarget:self action:@selector(finishBtTaped) forControlEvents:UIControlEventTouchUpInside];
    [finishBt setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.3] forState:UIControlStateNormal];
    [backView addSubview:finishBt];
    
    numLabel = [[UILabel alloc]initWithFrame:CGRectMake(VIEW_WIDTH-70, 13, 20, 20)];
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.textColor = [UIColor whiteColor];
    numLabel.font = [UIFont systemFontOfSize:12];
    numLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:101.0 /255.0 blue:0 / 255.0 alpha:1];
    numLabel.layer.cornerRadius = 10;
    numLabel.layer.masksToBounds = YES;
    [backView addSubview:numLabel];
    numLabel.hidden = YES;
}
-(void)previewBtTaped
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in selectedArray) {
        [assets addObject:[dic objectForKey:@"asset"]];
    }
    DNPhotoBrowser *brower = [[DNPhotoBrowser alloc] initWithPhotos:assets currentIndex:0 fullImage:YES];
    [brower setDelegate:self];
    [self.navigationController pushViewController:brower animated:YES];
}

-(void)finishBtTaped{
    if (selectedArray.count>0)
    {
        if ([self.delegate respondsToSelector:@selector(sendImageWithALassetArray:)]) {
            [self.delegate sendImageWithALassetArray:selectedArray];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)refreshFooterView{
    if (selectedArray.count>0) {
        [self bouncesAnimate:numLabel];
        [previewBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [finishBt setTitleColor:[UIColor colorWithRed:143/255.0 green:195/255.0 blue:31/255.0 alpha:1] forState:UIControlStateNormal];
        numLabel.hidden = NO;
        numLabel.text = [NSString stringWithFormat:@"%d",(int)selectedArray.count];
        
    }else{
        [previewBt setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.3] forState:UIControlStateNormal];
        [finishBt setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.3] forState:UIControlStateNormal];
        numLabel.hidden = YES;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self refreshFooterView];
    [mainTable reloadData];
}

-(void)cancelBtTap{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return rowNum;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return imgWidth+imgGap;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* identify = @"cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
        [self formatCellWith:cell IndexPath:indexPath WithReuse:NO];
    }
    else
    {
        [self formatCellWith:cell IndexPath:indexPath WithReuse:YES];
    }
    tableView.separatorColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)imgViewTaped:(UITapGestureRecognizer*)gest
{
    UIImageView* imgV = (UIImageView*)[gest view];
    
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in assetArray) {
        [assets addObject:[dic objectForKey:@"asset"]];
    }
    DNPhotoBrowser *brower = [[DNPhotoBrowser alloc] initWithPhotos:assets currentIndex:imgV.superview.tag-imageTagBase+imgV.tag fullImage:YES];
    [brower setDelegate:self];
    [self.navigationController pushViewController:brower animated:YES];
}

-(void)bouncesAnimate:(UIView*)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = @[@(1), @(1.2), @(0.9), @(1)];
    
    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;
    
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

-(void)selectBtTaped:(UIButton*)bt{
    
    [self bouncesAnimate:bt];

    if (bt.selected) {
        bt.selected = NO;
        //取消选中
        NSArray * tmpArray = [NSArray arrayWithArray: selectedArray];
        for (NSMutableDictionary* dic in tmpArray) {
            int assetIndex = [[dic objectForKey:@"assetIndex"] intValue];
            if (assetIndex == (int)bt.superview.superview.tag+bt.tag-buttonTagBase) {
                [dic setObject:@NO forKey:@"select"];
                [selectedArray removeObject:dic];
            }
        }
        
    }else{
        if (limitNum>0) {
            if (selectedArray.count>=limitNum) {
                UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"最多只能选择%d张照片",limitNum] delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
        }
        
        bt.selected = YES;
        //选中图片
        NSMutableDictionary* tmpDic = [assetArray objectAtIndex:(int)bt.superview.superview.tag+bt.tag-buttonTagBase];
        [tmpDic setObject:@YES forKey:@"select"];
        [selectedArray addObject:tmpDic];
    }
    [self refreshFooterView];
    
}


-(void)dealloc{
    [assetArray removeAllObjects];
    assetArray = nil;
    group = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - formatCellMethod
/**
 *  @author Denty, 15-12-02 09:12:17
 *
 *  填充cell数据
 *
 *  @param cell      准备填充的cell
 *  @param indexPath cell所属的indexPath
 *  @param yesOrNo   当前cell是否重用cell
 */
- (void) formatCellWith:(UITableViewCell *) cell IndexPath:(NSIndexPath *) indexPath WithReuse:(BOOL) yesOrNo
{
    for (int i=0; i<numOfPerRow; i++)
    {
        long assetIndex = indexPath.row*numOfPerRow+i;
        
        if (assetIndex < assetArray.count) {
            ALAsset *asset = [[assetArray objectAtIndex:assetIndex] objectForKey:@"asset"];
            BOOL isSelected = [[[assetArray objectAtIndex:assetIndex] objectForKey:@"select"] boolValue];
            
            if (yesOrNo)
            {
                UIImageView* imgView;
                if ([[cell.contentView viewWithTag:imageTagBase+i] isKindOfClass:[UIImageView class]])
                {
                    imgView = (UIImageView*)[cell.contentView viewWithTag:imageTagBase+i];
                    [imgView setHidden:NO];
//                    [imgView setImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]]];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        //裁切
                        UIImage * image = [self imageWithImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]] scaledToSize:CGSizeMake(150, [UIImage imageWithCGImage:[asset aspectRatioThumbnail]].size.height/[UIImage imageWithCGImage:[asset aspectRatioThumbnail]].size.width*150)];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //完成，设置到view
                            [imgView setImage:image];
                        });
                    });
//                    [imgView setImage:[self imageWithImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]] scaledToSize:CGSizeMake(70, 70)]];
                    imgView.superview.tag = assetIndex-i;
                }
                else
                {
                    //imageView异常
                }
            }
            else
            {
                UIImageView* imgView = [[UIImageView alloc]initWithFrame:CGRectMake(imgGap+(imgWidth+imgGap)*i, imgGap, imgWidth, imgWidth)];
                [imgView setContentMode:UIViewContentModeScaleAspectFill];
                [imgView setClipsToBounds:YES];
//                [imgView setImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]]];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //裁切
                    UIImage * image = [self imageWithImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]] scaledToSize:CGSizeMake(150, [UIImage imageWithCGImage:[asset aspectRatioThumbnail]].size.height/[UIImage imageWithCGImage:[asset aspectRatioThumbnail]].size.width*150)];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //完成，设置到view
                        [imgView setImage:image];
                    });
                });
//                [imgView setImage:[self imageWithImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]] scaledToSize:CGSizeMake(70, 70)]];
                imgView.superview.tag = assetIndex-i;
                imgView.userInteractionEnabled = YES;
                [imgView setTag:imageTagBase+i];
                [cell.contentView addSubview:imgView];
                UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgViewTaped:)];
                [imgView addGestureRecognizer:tapGes];
            }
            if (yesOrNo)
            {
                if ([[(UIImageView*)[cell.contentView viewWithTag:imageTagBase+i] viewWithTag:buttonTagBase+i] isKindOfClass:[UIButton class]]) {
                    UIButton *checkBt = (UIButton *)[(UIImageView*)[cell.contentView viewWithTag:imageTagBase+i] viewWithTag:buttonTagBase+i];
                    [checkBt setHidden:NO];
                    if (isSelected)
                    {
                        checkBt.selected = YES;
                    }
                    else
                    {
                        checkBt.selected = NO;
                    }
                    checkBt.superview.superview.tag = assetIndex-i;
                }
                else
                {
                    //button 异常
                }
                
            }
            else
            {
                UIButton* checkBt = [[UIButton alloc]initWithFrame:CGRectMake(imgWidth-30-2, 2, 30, 30)];
                [checkBt setImageEdgeInsets:UIEdgeInsetsMake(3, 11,11, 3)];
                [checkBt setImage:[UIImage imageNamed:@"notSelected"] forState:UIControlStateNormal];
                [checkBt setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
                [checkBt setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateHighlighted];
                checkBt.superview.superview.tag = assetIndex-i;
                [checkBt addTarget:self action:@selector(selectBtTaped:) forControlEvents:UIControlEventTouchUpInside];
                [[cell.contentView viewWithTag:imageTagBase+i] addSubview:checkBt];
                [checkBt setTag:buttonTagBase+i];
                if (isSelected)
                {
                    checkBt.selected = YES;
                }
                else
                {
                    checkBt.selected = NO;
                }
            }
            
        }
        else
        {
            if (yesOrNo)
            {
                UIImageView* imgView;
                if ([[cell.contentView viewWithTag:imageTagBase+i] isKindOfClass:[UIImageView class]])
                {
                    imgView = (UIImageView*)[cell.contentView viewWithTag:imageTagBase+i];
                    [imgView setHidden:YES];
                }
                else
                {
                    //imageView异常
                }
                if ([[(UIImageView*)[cell.contentView viewWithTag:imageTagBase+i] viewWithTag:buttonTagBase+i] isKindOfClass:[UIButton class]])
                {
                    UIButton *checkBt = (UIButton *)[(UIImageView*)[cell.contentView viewWithTag:imageTagBase+i] viewWithTag:buttonTagBase+i];
                    [checkBt setHidden:YES];
                }
                else
                {
                    //button 异常
                }
            }
        }
    }
}

/**
 *  @author Denty, 15-12-02 09:12:33
 *
 *  减小图片大小
 *
 *  @param image   准备缩放的图片
 *  @param newSize 想要得到的缩放尺寸
 *
 *  @return 缩放之后的图片
 */
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

#pragma mark - photoBrowserDelegate
- (void)sendImagesFromPhotobrowser:(DNPhotoBrowser *)photoBrowse currentAsset:(ALAsset *)asset
{
    //发送图片
}
- (NSUInteger)seletedPhotosNumberInPhotoBrowser:(DNPhotoBrowser *)photoBrowser
{
    return selectedArray.count;
}
- (BOOL)photoBrowser:(DNPhotoBrowser *)photoBrowser currentPhotoAssetIsSeleted:(ALAsset *)asset
{
    for (NSDictionary *dic in selectedArray)
    {
        ALAsset * selectAlasset = (ALAsset *)[dic objectForKey:@"asset"];
        if ([selectAlasset isEqual:asset])
        {
            return YES;
        }
    }
    return NO;
}
- (BOOL)photoBrowser:(DNPhotoBrowser *)photoBrowser seletedAsset:(ALAsset *)asset
{
    for (NSMutableDictionary *dic in assetArray)
    {
        ALAsset * selectAlasset = (ALAsset *)[dic objectForKey:@"asset"];
        if ([selectAlasset isEqual:asset])
        {
            [dic setObject:@YES forKey:@"select"];
            [selectedArray addObject:dic];
            return YES;
        }
    }
    return NO;
}
- (void)photoBrowser:(DNPhotoBrowser *)photoBrowser deseletedAsset:(ALAsset *)asset
{
    for (NSMutableDictionary *dic in assetArray)
    {
        ALAsset * selectAlasset = (ALAsset *)[dic objectForKey:@"asset"];
        if ([selectAlasset isEqual:asset])
        {
            [selectedArray removeObject:dic];
            [dic setObject:@NO forKey:@"select"];
        }
    }
}
- (void)photoBrowser:(DNPhotoBrowser *)photoBrowser seleteFullImage:(BOOL)fullImage
{
    
}

- (BOOL)ableToSelectImageWithPhotoBrowser:(DNPhotoBrowser *)photoBrowser
{
    if (selectedArray.count>=limitNum)
    {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"最多只能选择%d张照片",limitNum] delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    else
    {
        return YES;
    }
}
@end
