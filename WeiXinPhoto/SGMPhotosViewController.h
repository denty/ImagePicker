//
//  SGMPhotosViewController.h
//  WeiXinPhoto
//
//  Created by 苏贵明 on 15/9/4.
//  Copyright (c) 2015年 苏贵明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol SGMPhotosViewControllerDelegate <NSObject>

@required
- (BOOL)sendImageWithALassetArray:(NSArray *) array;

@end

@interface SGMPhotosViewController : UIViewController

@property(nonatomic,retain)ALAssetsGroup *group;
@property(nonatomic,weak) id<SGMPhotosViewControllerDelegate> delegate;
@property int limitNum;

@end
