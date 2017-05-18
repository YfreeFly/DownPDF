//
//  PictureViewController.m
//  downPDF
//
//  Created by 姚志飞 on 2017/5/3.
//  Copyright © 2017年 姚志飞. All rights reserved.
//

#import "PictureViewController.h"
#import "DownPdfManager.h"

@interface PictureViewController ()<downPDFFileDelegate>

@property (nonatomic,strong)UIImageView *pictureImgView;
@property (nonatomic,strong)UIScrollView *pictureScrollView;
@end

@implementation PictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    DownPdfManager *downPdf = [[DownPdfManager alloc]init];
    downPdf.delegate = self;
    downPdf.downType = @"image";
    [downPdf downloadPDF:@"http://wujieshan-new.oss-cn-hzjbp-a.aliyuncs.com/policy/718732613644974.jpg"];
    
    [self.view addSubview:self.pictureScrollView];
    [self.pictureScrollView addSubview:self.pictureImgView];
    
    
}

-(UIImageView *)pictureImgView{
    if (!_pictureImgView) {
        _pictureImgView = [[UIImageView alloc]initWithFrame:self.view.frame];
        _pictureImgView.backgroundColor = [UIColor cyanColor];
    }
    return _pictureImgView;
}

-(UIScrollView *)pictureScrollView{
    if (!_pictureScrollView) {
        _pictureScrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
        _pictureScrollView.minimumZoomScale=0.5;//设置最小缩放比例
        _pictureScrollView.maximumZoomScale=2.5;//设置最大的缩放比例
        self.pictureScrollView.contentSize = self.view.frame.size;
    }
    return _pictureScrollView;
}

-(void)dowmSuccess:(NSString *)LocalPath{
    //读取图片
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:LocalPath];
    self.pictureImgView.image = savedImage;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
