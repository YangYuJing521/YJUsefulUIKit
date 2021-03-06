//
//  YJCycleScrollView.m
//  YJCycleScrollView
//
//  Created by 杨玉京 on 2020/6/22.
//

#import "YJCycleScrollView.h"
#import "YJCycleScrollViewCell.h"
#import "YJUICommon.h"
#import "UIImageView+WebCache.h"
NSString *const  cellID = @"GMCycleScrollViewCellID";
@interface YJCycleScrollView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong)UICollectionView *mainView; //轮播容器
@property(nonatomic,strong)UICollectionViewFlowLayout *flowLayout;
@property(nonatomic,strong)UIPageControl *pageControl;
@property(nonatomic,assign) NSUInteger totalPagesCount; //设置轮播的总长度个数
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, strong) NSArray *imagePathsGroup;

@end
@implementation YJCycleScrollView
+(instancetype)cycleScrollViewWithFrame:(CGRect)frame imageNamesGroup:(NSArray*)imageNameGroup{
    YJCycleScrollView * cycleView = [[YJCycleScrollView alloc]initWithFrame:frame];
    cycleView.localizationImageNamesGroup = imageNameGroup;
    return cycleView;
}
+(instancetype)cycleScrollViewWithFrame:(CGRect)frame imageUrlsGroup:(NSArray*)imageUrlsGroup{
    YJCycleScrollView * cycleView = [[YJCycleScrollView alloc]initWithFrame:frame];
    cycleView.imageURLStringsGroup = imageUrlsGroup;
    return cycleView;
}
+(instancetype)cycleScrollViewWithFrame:(CGRect)frame imageNamesGroup:(NSArray*)imageNameGroup cycleLoop:(BOOL)isCycleLoop{
    YJCycleScrollView * cycleView = [[YJCycleScrollView alloc]initWithFrame:frame];
    cycleView.isCycleLoop = isCycleLoop;
    cycleView.localizationImageNamesGroup = imageNameGroup;
    return cycleView;
}
- (void)adjustWhenControllerViewWillAppera
{
    NSInteger cellIndex = [self cellIndex];
    if (cellIndex < _totalPagesCount) {
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:cellIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}
//代码初始化
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initialization];
        [self setUpMainView];

    }
    return self;
}
//xib 初始化
- (void)awakeFromNib{
    [super awakeFromNib];
    [self initialization];
    [self setUpMainView];
}
-(void)dealloc{
    [self invilidTimer];
    _mainView.delegate = nil;
    _mainView.dataSource = nil;
}
//数据初始化
-(void)initialization{
    _isAutoScroll = YES;
    _isShowPageControl = YES;
    _pageControlAliment = PageContolAlimentCenter;
    _autoScrollTimeInterval = 5.0;
    _titleLableHeight = 36.0;
    _titleLabelTextAlignment = NSTextAlignmentRight;
}
-(void)setUpMainView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout = flowLayout;

    UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    mainView.backgroundColor = [UIColor clearColor];
    mainView.pagingEnabled = YES;
    mainView.showsHorizontalScrollIndicator = NO;
    mainView.showsVerticalScrollIndicator = NO;
    [mainView registerClass:[YJCycleScrollViewCell class] forCellWithReuseIdentifier:cellID];

    mainView.dataSource = self;
    mainView.delegate = self;
    mainView.scrollsToTop = NO;
    [self addSubview:mainView];
    _mainView = mainView;
}

//支持autolayout 及时调整Frame
-(void)layoutSubviews{
    [super layoutSubviews];
    //设置DataSource 数据源
    if (self.dataSource) {
        if ([self.dataSource respondsToSelector:@selector(cycleScrollViewImagesGroup)]) {
            self.imagePathsGroup = [self.dataSource cycleScrollViewImagesGroup];
        }
        if ([self.dataSource respondsToSelector:@selector(cycleScrollViewTitlesGroup)]) {
            self.titlesGroup = [self.dataSource cycleScrollViewTitlesGroup];
        }
        if ([self.dataSource respondsToSelector:@selector(cycleScrollViewTitleLableHeight)]) {
            self.titleLableHeight = [self.dataSource cycleScrollViewTitleLableHeight];
        }
    }
    //设置subviews 的frame
    self.delegate = self.delegate;
    _flowLayout.itemSize = self.frame.size;
    _mainView.frame = self.bounds;
    if (_mainView.contentOffset.x == 0 &&  _totalPagesCount) {
        // 初始化mainView位置
        int targetIndex = 0;
        if (self.isCycleLoop) {
            targetIndex = _totalPagesCount * 0.5;
        }else{
            targetIndex = 0;
        }
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    //pageControl
    if(!_isShowPageControl){
        self.pageControl.hidden = YES;
    }else{
        [self.pageControl sizeToFit];
        CGSize pageControlSize = self.pageControl.bounds.size;

        switch (self.pageControlAliment) {
            case PageContolAlimentLeft:
                _pageControl.frame = CGRectMake(10, self.bounds.size.height-pageControlSize.height, pageControlSize.width, pageControlSize.height);
                break;
            case PageContolAlimentRight:
                _pageControl.frame = CGRectMake(self.bounds.size.width - 10 - pageControlSize.width, self.bounds.size.height-pageControlSize.height, pageControlSize.width, pageControlSize.height);

                break;
            default:
                _pageControl.frame = CGRectMake((self.bounds.size.width - pageControlSize.width)/2.0, self.bounds.size.height-pageControlSize.height, pageControlSize.width, pageControlSize.height);

                break;
        }
    }
}
#pragma mark Timer
-(void)invilidTimer{
    [_timer invalidate];
    _timer = nil;
}
-(void)setUpTimer{
    [self invilidTimer]; //先释放之前的timer，保证只有一个timer
    _timer = [NSTimer scheduledTimerWithTimeInterval:_autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];

}
-(void)automaticScroll{
    if (_totalPagesCount==0) return;
    NSInteger cellIndex = [self cellIndex];
    cellIndex ++;
    [self scollToIndex:cellIndex];
}
-(void)scollToIndex:(NSInteger)index{
    if (index >= _totalPagesCount) {
        if (self.isCycleLoop) {
            index = _totalPagesCount * 0.5;
            [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        return;
    }
    [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}
#pragma mark pageControl
-(void)setUpPageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.hidesForSinglePage = YES;


        UIImage *nonSel = [YJUITools imageWithColor:RGBA(0, 0, 0, 0.2) size:CGSizeMake(7*kWidthRatio, 2*kWidthRatio)];
        UIImage *sel = [YJUITools imageWithColor:RGBA(255, 255, 255, 1) size:CGSizeMake(7*kWidthRatio, 2*kWidthRatio)];
        [_pageControl setValue:nonSel forKey:@"_pageImage"];
        [_pageControl setValue:sel forKey:@"_currentPageImage"];
        [self addSubview:_pageControl];
    }
    //config Pageconrol
    _pageControl.numberOfPages = self.imagePathsGroup.count;
    _pageControl.currentPage = [self pageIndexWithCellIndex:[self cellIndex]];
}
-(NSInteger)cellIndex{
    NSInteger index = 0;
    index = (_mainView.contentOffset.x + _flowLayout.itemSize.width * 0.5) / _flowLayout.itemSize.width;
    return index;
}
-(NSInteger)pageIndexWithCellIndex:(NSInteger)index{
    if(index){
        return index%self.imagePathsGroup.count;
    }
    return 0;
}
#pragma mark property
-(void)setIsCycleLoop:(BOOL)isCycleLoop{
    _isCycleLoop = isCycleLoop;
    if(self.imagePathsGroup.count){
        self.imagePathsGroup = _imagePathsGroup;
    }
}
-(void)setIsAutoScroll:(BOOL)isAutoScroll{
    _isAutoScroll = isAutoScroll;
    [self invilidTimer];
    if(_isAutoScroll){
        [self setUpTimer];
    }
}
-(void)setImagePathsGroup:(NSArray *)imagePathsGroup{
    _imagePathsGroup = imagePathsGroup;
    _totalPagesCount = _isCycleLoop?_imagePathsGroup.count*100:imagePathsGroup.count;
    //重置pagecontrol
    [self setUpPageControl];
    [_mainView reloadData];
}
-(void)setLocalizationImageNamesGroup:(NSArray *)localizationImageNamesGroup{
    _localizationImageNamesGroup = localizationImageNamesGroup;
    self.imagePathsGroup = [localizationImageNamesGroup copy];

}
-(void)setImageURLStringsGroup:(NSArray *)imageURLStringsGroup{
    _imageURLStringsGroup = imageURLStringsGroup;
    self.imagePathsGroup = [imageURLStringsGroup copy];
}
#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.totalPagesCount;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    YJCycleScrollViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    if (!cell.hasConfig) {
        cell.hasConfig = YES;
        cell.titleLabelHeight = self.titleLableHeight;
        cell.titleLabelTextColor = self.titleLabelTextColor;
        cell.titleLabelTextFont = self.titleLabelTextFont;
        cell.titleLabelTextAlignment = self.titleLabelTextAlignment;
        cell.imageView.contentMode = self.bannerImageViewContentMode;//图片占位模式
    }
    NSInteger currentIndex = [self pageIndexWithCellIndex:indexPath.item];
    NSString *imagePath = _imagePathsGroup[currentIndex];
    cell.imageView.layer.masksToBounds = YES;
    if ([imagePath isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage*)imagePath;
        cell.imageView.image = image;
    }else{
        if ([imagePath hasPrefix:@"http"]) {
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:self.placeholderImage options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(!error) {
                    cell.imageView.contentMode = UIViewContentModeScaleToFill;
                } else {
                    cell.imageView.contentMode = UIViewContentModeCenter;
                    cell.imageView.image = self.placeholderImage;
                }
            }];
            
        }else{
            cell.imageView.image = [UIImage imageNamed:imagePath];
        }
    }
    if (_isShowBannerTitle&& currentIndex < _titlesGroup.count) {
        cell.title = _titlesGroup[currentIndex];
    }
    return cell;
}
#pragma mark UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click index:%ld,currentIndex:%ld",indexPath.item,[self pageIndexWithCellIndex:[self cellIndex]]);
    if([self.delegate respondsToSelector:@selector(cycleScrollView:didSelectAtIndex:)]){
        [self.delegate cycleScrollView:self didSelectAtIndex:[self pageIndexWithCellIndex:[self cellIndex]]];
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.imagePathsGroup.count) return;
    //滚动切换 pagecontrol
    NSInteger index = [self pageIndexWithCellIndex:[self cellIndex]];
    _pageControl.currentPage = index;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.isAutoScroll) {
        [self invilidTimer];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.isAutoScroll) {
        [self setUpTimer];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:self.mainView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (!self.imagePathsGroup.count) return;
    //滚动切换 pagecontrol
    NSInteger index = [self pageIndexWithCellIndex:[self cellIndex]];
    _pageControl.currentPage = index;
    
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didScrollToIndex:)]) {
        [self.delegate cycleScrollView:self didScrollToIndex:index];
    }
}
@end

