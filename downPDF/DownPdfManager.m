//
//  DownPdfManager.m
//  downPDF
//
//  Created by 姚志飞 on 2017/5/3.
//  Copyright © 2017年 姚志飞. All rights reserved.
//

#import "DownPdfManager.h"
#import <AFNetworking.h>

@interface DownPdfManager()

@property (nonatomic,strong)NSString *folderName;
// 文件管理
@property (nonatomic, strong) NSFileManager *fileManager;
@end

@implementation DownPdfManager


-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

-(void)setDownType:(NSString *)downType{
    _downType = downType;
}

//是否下载还是打开文件
- (void)downloadPDF:(NSString *)downloadUrl{
    
    if ([self.downType isEqualToString:@"image"]) {
        self.folderName = @"YFDownImageCache";
    }else
        self.folderName = @"YFDownPDFCache";
    
    NSArray *array = [downloadUrl componentsSeparatedByString:@"/"]; //从字符/中分隔成多个元素的数组
    
    NSString *file = [array lastObject];
    
    if ([self isFileExist:file]) {
        
        //获取Documents 下的文件路径
         NSString* path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:self.folderName];
        
        NSString *pathString = [path stringByAppendingFormat:@"/%@",file];
    
        [self.delegate dowmSuccess:pathString];
    }else{
        //从新下载
        [self downloadDocxWithUrlPath:downloadUrl];
    }
}

#pragma mark   第二步    判断沙盒中是否存在此文件
-(BOOL) isFileExist:(NSString *)fileName

{
    //获取Documents 下的文件路径
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:self.folderName];
    
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL result = [fileManager fileExistsAtPath:filePath];
    
    NSLog(@"这个文件已经存在：%@",result?@"是的":@"不存在");
    
    return result;
    
}


/**
 下载文件
 @param urlPath  文件网络地址
 
 */
-(void)downloadDocxWithUrlPath:(NSString *)urlPath {
    //[MBProgressHUD showMessage:@"正在下载文件" toView:self.view];
    
    NSString *fileName = [urlPath lastPathComponent];
    //设置下载文件保存的目录
    NSString* docPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:self.folderName];
    [self createDirectory:docPath];
    
    NSURL *url = [NSURL URLWithString:[urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%lld   %lld",downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *path = [docPath stringByAppendingPathComponent:fileName];
        NSLog(@"文件路径＝＝＝%@",path);
        return [NSURL fileURLWithPath:path];//这里返回的是文件下载到哪里的路径 要注意的是必须是携带协议
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        NSString *name = [filePath path];
        
        NSLog(@"下载完成文件路径＝＝＝%@",name);
        
        [self.delegate dowmSuccess:name];
    }];
    [task resume];//开始下载 要不然不会进行下载的
    
}

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [[NSFileManager alloc]init];
    }
    return _fileManager;
}

//  创建缓存目录文件
- (void)createDirectory:(NSString *)directory
{
    if (![self.fileManager fileExistsAtPath:directory]) {
        [self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

@end
