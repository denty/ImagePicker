//
//  DNPhotoBrowserViewController.h
//  ImagePicker
//
//  Created by DingXiao on 15/2/28.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSInteger, DNImagePickerNavigationBarPosition) {
    DNImagePickerNavigationBarPositionLeft,
    DNImagePickerNavigationBarPositionRight
};

@class DNImageFlowViewController;
@class DNPhotoBrowser;
@protocol DNPhotoBrowserDelegate <NSObject>

@required
- (void)sendImagesFromPhotobrowser:(DNPhotoBrowser *)photoBrowse currentAsset:(ALAsset *)asset;
- (NSUInteger)seletedPhotosNumberInPhotoBrowser:(DNPhotoBrowser *)photoBrowser;
- (BOOL)photoBrowser:(DNPhotoBrowser *)photoBrowser currentPhotoAssetIsSeleted:(ALAsset *)asset;
- (BOOL)photoBrowser:(DNPhotoBrowser *)photoBrowser seletedAsset:(ALAsset *)asset;
- (void)photoBrowser:(DNPhotoBrowser *)photoBrowser deseletedAsset:(ALAsset *)asset;
- (void)photoBrowser:(DNPhotoBrowser *)photoBrowser seleteFullImage:(BOOL)fullImage;
- (BOOL)ableToSelectImageWithPhotoBrowser:(DNPhotoBrowser *) photoBrowser;
@end

@interface DNPhotoBrowser : UIViewController

@property (nonatomic, weak) id<DNPhotoBrowserDelegate> delegate;

- (instancetype)initWithPhotos:(NSArray *)photosArray
                  currentIndex:(NSInteger)index
                     fullImage:(BOOL)isFullImage;

- (void)hideControls;
- (void)toggleControls;
@end
