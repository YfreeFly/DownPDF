//
//  RiderPDFView.h
//  downPDF
//
//  Created by 姚志飞 on 2017/5/3.
//  Copyright © 2017年 姚志飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RiderPDFView : UIView

/** 判断是从本地还是网络获取PDF文件*/
@property (nonatomic,assign)BOOL isLocalFile;

/** 文件路径或地址*/
@property (nonatomic,strong)NSString *filePath;
/** 页码*/
@property (nonatomic,assign)int page;

-(instancetype)initWithFrame:(CGRect)frame isLoaclFile:(BOOL)isLoaclFile documentRef:(NSString *)docRefString andPageNum:(int)page;
@end
