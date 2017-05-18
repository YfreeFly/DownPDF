//
//  ViewController.m
//  downPDF
//
//  Created by 姚志飞 on 2017/5/3.
//  Copyright © 2017年 姚志飞. All rights reserved.
//

#import "ViewController.h"
#import "RiderPDFView.h"
#import "DownPdfManager.h"
#import "PDFCollectionViewCell.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,PDFCollectCellCellDelegate,downPDFFileDelegate>

{
    
    UICollectionView *pdfCollectionView; //展示用的CollectionView
    
    NSString *_docRefString; //需要获取的PDF资源文件
    
}

@property(nonatomic,strong)NSMutableArray*dataArray;//存数据的数组

@property(nonatomic,assign)int totalPage;//一共有多少页

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _docRefString = @"http://teaching.csse.uwa.edu.au/units/CITS4401/practicals/James1_files/SPMP1.pdf";//通过test函数获取PDF文件资源，test函数的实现为我们最上面的方法，当然下面又写了一遍
    

    DownPdfManager *downPdf = [[DownPdfManager alloc]init];
    downPdf.delegate = self;
    [downPdf downloadPDF:_docRefString];
   // [self.view addSubview:downview];
    
    UICollectionViewFlowLayout*layout = [[UICollectionViewFlowLayout alloc]init];//UICollectionView需要在创建的时候传入一个布局参数，故在创建它之前，先创建一个布局，这里使用系统的布局就好
    
    layout.itemSize= CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - 64);//设置CollectionView中每个item及集合视图中每单个元素的大小，我们每个视图使用一页来显示，所以设置为当前视图的大小
    
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];//设置滑动方向为水平方向，也可以设置为竖直方向
    
    layout.minimumLineSpacing=0;//设置item之间最下行距
    
    layout.minimumInteritemSpacing=0;//设置item之间最小间距
    
    pdfCollectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];//创建一个集合视图，设置其大小为当前view的大小，布局为上面我们创建的布局
    
    pdfCollectionView.pagingEnabled=YES;//设置集合视图一页一页的翻动
    pdfCollectionView.backgroundColor = [UIColor whiteColor];
    [pdfCollectionView registerClass:[PDFCollectionViewCell class]forCellWithReuseIdentifier:@"Cell"];//为集合视图注册单元格
    
    pdfCollectionView.delegate=self;//设置代理
    pdfCollectionView.dataSource=self;//设置数据源
    
    [self.view addSubview:pdfCollectionView];//将集合视图添加到当前视图上
}

//通过地址字符串获取PDF资源

CGPDFDocumentRef test(NSString*fileName) {
    
    NSURL*url = [NSURL URLWithString:fileName];
    
    CFURLRef refURL = (__bridge_retained CFURLRef)url;
    
    CGPDFDocumentRef document =CGPDFDocumentCreateWithURL(refURL);
    
    CFRelease(refURL);
    
    if(document) {
        
        return document;
        
    }else{
        
        return NULL;
        
    }
    
}

//获取所有需要显示的PDF页面

- (void)getDataArrayValue:(NSString *)filePath {
    
  //  size_t totalPages =CGPDFDocumentGetNumberOfPages(test(filePath));//获取总页数
    size_t totalPages =CGPDFDocumentGetNumberOfPages([self pdfRefByFilePath:filePath]);
    self.totalPage= (int)totalPages;//给全局变量赋值
    
    NSMutableArray*arr = [NSMutableArray new];
    
    //通过循环创建需要显示的PDF页面，并把这些页面添加到数组中
    for(int i =1; i <= totalPages; i++) {
        
        RiderPDFView *view = [[RiderPDFView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) isLoaclFile:YES documentRef:filePath andPageNum:i];
        [arr addObject:view];
        
    }
    self.dataArray= arr;//给数据数组赋值
    [pdfCollectionView reloadData];
    
}

//获取本地的PDF文件
-(CGPDFDocumentRef)pdfRefByFilePath:(NSString *)filePath
{

    CFStringRef path;
    CFURLRef url;
    CGPDFDocumentRef document;
    size_t count;
    
    //pdf的扩展名必须重命名一下，才可以取到
    NSString* aFilePath2 = [filePath  stringByReplacingOccurrencesOfString:@".dat" withString:@".pdf"];
    NSError* error;
    path = CFStringCreateWithCString (NULL, [aFilePath2   UTF8String],
                                      kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath (NULL, path,
                                         kCFURLPOSIXPathStyle, 0);
    CFRelease (path);
    document = CGPDFDocumentCreateWithURL (url);
    CFRelease(url);
    return document;
    
}

//返回集合视图共有几个分区

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    
    return 1;
    
}

//返回集合视图中一共有多少个元素——自然是总页数

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.totalPage;
    
}

//复用、返回cell

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    
    PDFCollectionViewCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"forIndexPath:indexPath];
    
    cell.cellTapDelegate=self;//设置tap事件代理
    
    cell.showView=self.dataArray[indexPath.row];//赋值，设置每个item中显示的内容
    
    return cell;
    
}

//当集合视图的item被点击后触发的事件，根据个人需求写

- (void)collectioncellTaped:(PDFCollectionViewCell *)cell {
    
    NSLog(@"我点了咋的？");
    
}

//集合视图继承自scrollView，所以可以用scrollView 的代理事件，这里的功能是当某个item不在当前视图中显示的时候，将它的缩放比例还原

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView {
    
    for(UIView *view in pdfCollectionView.subviews) {
        
        if([view isKindOfClass:[PDFCollectionViewCell class]]) {
            
            PDFCollectionViewCell *cell = (PDFCollectionViewCell *)view;
            
            [cell.contentScrollView setZoomScale:1.0];
            
        }
        
    }
    
}

-(void)dowmSuccess:(NSString *)LocalPath{
    [self getDataArrayValue:LocalPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
