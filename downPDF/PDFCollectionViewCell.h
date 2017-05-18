//
//  PDFCollectionViewCell.h
//  downPDF
//
//  Created by 姚志飞 on 2017/5/3.
//  Copyright © 2017年 姚志飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  PDFCollectionViewCell;

@protocol PDFCollectCellCellDelegate <NSObject>

@optional
- (void)collectioncellTaped:(PDFCollectionViewCell *)cell;

@end

@interface PDFCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong) UIScrollView *contentScrollView; //用于实现缩放功能的UISCrollView

@property(nonatomic,strong) UIView *showView;//这个就是现实PDF文件内容的视图

@property(nonatomic,weak)id <PDFCollectCellCellDelegate> cellTapDelegate;//代理

@end
