//
//  VideoViewController.m
//  downPDF
//
//  Created by 姚志飞 on 2017/5/3.
//  Copyright © 2017年 姚志飞. All rights reserved.
//

#import "VideoViewController.h"
#import "TYDownLoadDataManager.h"
#import "CLPlayerView.h"

@interface VideoViewController ()<TYDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIButton *downBtn;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic,strong) TYDownloadModel *downloadModel;

/**CLplayer*/
@property (nonatomic,weak) CLPlayerView *playerView;

@end

static NSString * const downloadUrl = @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";

@implementation VideoViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [TYDownLoadDataManager manager].delegate = self;
    [self refreshDowloadInfo];
}

-(void)refreshDowloadInfo{
    _downloadModel = [[TYDownLoadDataManager manager] downLoadingModelForURLString:downloadUrl];
    if (_downloadModel) {
        [self startDownlaod];
        return;
    }
    
    // 没有正在下载的model 重新创建
    TYDownloadModel *model = [[TYDownloadModel alloc]initWithURLString:downloadUrl];
    TYDownloadProgress *progress = [[TYDownLoadDataManager manager]progessWithDownloadModel:model];
    
    self.progressView.progress = progress.progress;
    [self.downBtn setTitle:[[TYDownLoadDataManager manager] isDownloadCompletedWithDownloadModel:model] ? @"下载完成，重新下载":@"开始" forState:UIControlStateNormal];
    _downloadModel = model;
}

- (void)startDownlaod
{
    TYDownLoadDataManager *manager = [TYDownLoadDataManager manager];
    __weak typeof(self) weakSelf = self;
    [manager startWithDownloadModel:_downloadModel progress:^(TYDownloadProgress *progress) {
        weakSelf.progressView.progress = progress.progress;
        
    } state:^(TYDownloadState state, NSString *filePath, NSError *error) {
        if (state == TYDownloadStateCompleted) {
            weakSelf.progressView.progress = 1.0;
        }
        
        [weakSelf.downBtn setTitle:[weakSelf stateTitleWithState:state] forState:UIControlStateNormal];
        
        NSLog(@"state %ld error%@ filePath%@",state,error,filePath);
    }];
}


- (IBAction)downVideo:(id)sender {
    TYDownLoadDataManager *manager = [TYDownLoadDataManager manager];
    
    if (_downloadModel.state == TYDownloadStateReadying) {
        [manager cancleWithDownloadModel:_downloadModel];
        return;
    }
    
    if ([manager isDownloadCompletedWithDownloadModel:_downloadModel]) {
        //销毁播放器
        [_playerView destroyPlayer];
        _playerView = nil;
        self.videoView.userInteractionEnabled = YES;
        CLPlayerView *playerView = [[CLPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.videoView.frame.size.width, self.videoView.frame.size.height)];
        
        _playerView = playerView;
        [self.videoView addSubview:_playerView];
        
        
        //根据旋转自动支持全屏，默认支持
       // _playerView.autoFullScreen = NO;
        //重复播放，默认不播放
        //    _playerView.repeatPlay     = YES;
        //如果播放器所在页面支持横屏，需要设置为Yes，不支持不需要设置(默认不支持)
        //        _playerView.isLandscape    = YES;
        //设置等比例全屏拉伸，多余部分会被剪切
         //  _playerView.fillMode = ResizeAspectFill;
        
        //视频地址
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _playerView.url = [NSURL fileURLWithPath:_downloadModel.filePath];
            //播放
            [_playerView playVideo];
            
        });
        
        //返回按钮点击事件回调
        [_playerView backButton:^(UIButton *button) {
            NSLog(@"返回按钮被点击");
        }];
        
        //播放完成回调
        [_playerView endPlay:^{
            
            //销毁播放器
            [_playerView destroyPlayer];
            _playerView = nil;
            NSLog(@"播放完成");
        }];
        return;
    }
    
    if (_downloadModel.state == TYDownloadStateRunning) {
        [manager suspendWithDownloadModel:_downloadModel];
        return;
    }
    [self startDownlaod];
}

- (NSString *)stateTitleWithState:(TYDownloadState)state
{
    switch (state) {
        case TYDownloadStateReadying:
            return @"等待下载";
            break;
        case TYDownloadStateRunning:
            return @"暂停下载";
            break;
        case TYDownloadStateFailed:
            return @"下载失败";
            break;
        case TYDownloadStateCompleted:
            return @"下载完成，重新下载";
            break;
        default:
            return @"开始下载";
            break;
    }
}

#pragma mark - TYDownloadDelegate

- (void)downloadModel:(TYDownloadModel *)downloadModel didUpdateProgress:(TYDownloadProgress *)progress
{
    NSLog(@"delegate progress %.3f",progress.progress);
}

- (void)downloadModel:(TYDownloadModel *)downloadModel didChangeState:(TYDownloadState)state filePath:(NSString *)filePath error:(NSError *)error
{
    NSLog(@"delegate state %ld error%@ filePath%@",state,error,filePath);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
