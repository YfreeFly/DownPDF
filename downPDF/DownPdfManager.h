//
//  DownPdfManager.h
//  downPDF
//
//  Created by 姚志飞 on 2017/5/3.
//  Copyright © 2017年 姚志飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol downPDFFileDelegate <NSObject>

-(void)dowmSuccess:(NSString *)LocalPath;

@end

@interface DownPdfManager : NSObject

@property (nonatomic,weak)id <downPDFFileDelegate> delegate;

- (void)downloadPDF:(NSString *)downloadUrl;
@property (nonatomic,strong)NSString *downType;

@end
