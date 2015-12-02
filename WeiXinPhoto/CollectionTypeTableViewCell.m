//
//  CollectionTypeTableViewCell.m
//  WeiXinPhoto
//
//  Created by broydenty on 1/12/2015.
//  Copyright © 2015 苏贵明. All rights reserved.
//

#import "CollectionTypeTableViewCell.h"

@implementation CollectionTypeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        for (int i=0; i<numOfPerRow; i++)
        {
            long assetIndex = indexPath.row*numOfPerRow+i;
            
            if (assetIndex < assetArray.count) {
                ALAsset *asset = [[assetArray objectAtIndex:assetIndex] objectForKey:@"asset"];
                BOOL isSelected = [[[assetArray objectAtIndex:assetIndex] objectForKey:@"select"] boolValue];
                
                UIImageView* imgView = [[UIImageView alloc]initWithFrame:CGRectMake(imgGap+(imgWidth+imgGap)*i, imgGap, imgWidth, imgWidth)];
                [imgView setContentMode:UIViewContentModeScaleAspectFill];
                [imgView setImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]]];
                imgView.image = [self imageWithImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]] scaledToSize:CGSizeMake(imgWidth, imgWidth)];
                [imgView setClipsToBounds:YES];
                imgView.tag = assetIndex;
                imgView.userInteractionEnabled = YES;
                if (yesOrNo)
                {
                    [(UIImageView*)[cell.contentView viewWithTag:10] setImage:[UIImage imageWithCGImage:[asset aspectRatioThumbnail]]];
                }
                else
                {
                    
                }
                [cell.contentView addSubview:imgView];
                
                UIButton* checkBt = [[UIButton alloc]initWithFrame:CGRectMake(imgWidth-20-2, 2, 20, 20)];
                [checkBt setBackgroundImage:[UIImage imageNamed:@"notSelected"] forState:UIControlStateNormal];
                [checkBt setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
                [checkBt setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateHighlighted];
                checkBt.tag = assetIndex;
                [checkBt addTarget:self action:@selector(selectBtTaped:) forControlEvents:UIControlEventTouchUpInside];
                [imgView addSubview:checkBt];
                if (isSelected) {
                    checkBt.selected = YES;
                }
                
                UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgViewTaped:)];
                [imgView addGestureRecognizer:tapGes];
                
            }
        }
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
