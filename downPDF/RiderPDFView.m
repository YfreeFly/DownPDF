//
//  RiderPDFView.m
//  downPDF
//
//  Created by 姚志飞 on 2017/5/3.
//  Copyright © 2017年 姚志飞. All rights reserved.
//

#import "RiderPDFView.h"

@interface  RiderPDFView() {
    
    CGPDFDocumentRef  documentRef;//用它来记录传递进来的PDF资源数据
    int  pageNum;//记录需要显示页码
}

@end

@implementation RiderPDFView

-(instancetype)initWithFrame:(CGRect)frame isLoaclFile:(BOOL)isLoaclFile documentRef:(NSString *)docRefString andPageNum:(int)page{
    if (self = [super initWithFrame:frame ]) {
        
        self.filePath = docRefString;
        if (isLoaclFile)
            documentRef = [self pdfRefByFilePath];
        else
            documentRef = [self getPDFSourceData];
        
        pageNum = page;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setIsLocalFile:(BOOL)isLocalFile{
    _isLocalFile = isLocalFile;
    
}

-(void)drawRect:(CGRect)rect{
    [self drawPDFIncontext:UIGraphicsGetCurrentContext()];
}

- (void)drawPDFIncontext:(CGContextRef)context {
    
    CGContextTranslateCTM(context,0.0,self.frame.size.height);
    
    CGContextScaleCTM(context,1.0, -1.0);
    
    //上面两句是对环境做一个仿射变换，如果不执行上面两句那么绘制出来的PDF文件会呈倒置效果，第二句的作用是使图形呈正立显示，第一句是调整图形的位置，如不执行绘制的图形会不在视图可见范围内
    
    CGPDFPageRef  pageRef =CGPDFDocumentGetPage(documentRef,pageNum);//获取需要绘制的页码的数据。两个参数，第一个数传递进来的PDF资源数据，第二个是传递进来的需要显示的页码
    
    CGContextSaveGState(context);//记录当前绘制环境，防止多次绘画
    
    CGAffineTransform  pdfTransForm =CGPDFPageGetDrawingTransform(pageRef,kCGPDFCropBox,self.bounds,0,true);//创建一个仿射变换的参数给函数。第一个参数是对应页数据；第二个参数是个枚举值，我每个都试了一下，貌似没什么区别……但是网上看的资料都用的我当前这个，所以就用这个了；第三个参数，是图形绘制的区域，我设置的是当前视图整个区域，如果有需要，自然是可以修改的；第四个是旋转的度数，这里不需要旋转了，所以设置为0；第5个，传递true，会保持长宽比
    
    CGContextConcatCTM(context, pdfTransForm);//把创建的仿射变换参数和上下文环境联系起来
    
    CGContextDrawPDFPage(context, pageRef);//把得到的指定页的PDF数据绘制到视图上
    
    CGContextRestoreGState(context);//恢复图形状态
    
}

//获取网络的PDF文件
-(CGPDFDocumentRef)getPDFSourceData{
    NSURL *url = [NSURL URLWithString:self.filePath];//将传入的字符串转化为一个NSURL地址
    CFURLRef reUrl = (__bridge_retained CFURLRef)url;//将的到的NSURL转化为CFURLRefrefURL备用
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL(reUrl);//通过CFURLRefrefURL获取文件内容
    CFRelease(reUrl);//过河拆桥，释放使用完毕的CFURLRefrefURL，这个东西并不接受自动内存管理，所以要手动释放
    if (document) {
        return document;//返回获取到的数据
    }else{
        return NULL;
    }
}

//获取本地的PDF文件
-(CGPDFDocumentRef)pdfRefByFilePath
{
    //     CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (__bridge CFStringRef)[aFilePath lastPathComponent], NULL, (__bridge CFStringRef)@"files");
    //    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
    //
    CFStringRef path;
    CFURLRef url;
    CGPDFDocumentRef document;
    
    //pdf的扩展名必须重命名一下，才可以取到
    NSString* aFilePath2 = [self.filePath  stringByReplacingOccurrencesOfString:@".dat" withString:@".pdf"];
    //拷贝地址，如果有了，会报错
//    NSError* error;
//    //[[NSFileManager defaultManager] moveItemAtPath:aFilePath2 toPath:aFilePath2 error:nil];
//    NSFileManager* fileManager =[NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:self.filePath]) {
//        //get new resource path with different extension
//        
//        //copy it over
//        [fileManager copyItemAtPath:self.filePath toPath:aFilePath2 error:&error];
//    }
    
    path = CFStringCreateWithCString (NULL, [aFilePath2   UTF8String],
                                      kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath (NULL, path,
                                         kCFURLPOSIXPathStyle, 0);
    CFRelease (path);
    document = CGPDFDocumentCreateWithURL (url);
    CFRelease(url);
//    if (document == nil) {
//        [fileManager copyItemAtPath:aFilePath2 toPath:self.filePath error:&error];
//    }
    
    return document;
    
}


@end
