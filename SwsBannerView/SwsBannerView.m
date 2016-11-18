//
//  SwsBannerView.m
//
//  Created by sws on 6/6/6.
//  Copyright © 666年 sws. All rights reserved.
//

#import "SwsBannerView.h"

#define Width   self.bounds.size.width
#define Height  self.bounds.size.height

#define Defalut_Color [UIColor blackColor]
#define Current_Color [UIColor whiteColor]

#define TimeNum 2  // 间隔时间

#define Image_Of_Path(A)    [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]

#define Cache_Key @"bannerCache"

@interface SwsBannerView () <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *bannerModelArray;
@property (nonatomic, strong) NSMutableArray *threeModelArray;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSMutableArray *cacheModelArray;

@property (nonatomic, assign) BOOL isCache;
@property (nonatomic, assign) NSInteger cacheIndex;


@end

@implementation SwsBannerView

- (SwsBannerView *)initWithFrame:(CGRect)frame
                bannerModelArray:(NSMutableArray *)bannerModelArray
                        delegate:(id)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        
        _bannerModelArray = [bannerModelArray mutableCopy];
        _delegate = delegate;
        if (_bannerModelArray.count > 0) {
            
            _index = 0;
            
            [self loadCache];
            [self initUI];
            [self initDataSource];
            [self loadImageData];
        }
        
    }
    return self;
}

#pragma mark - LoadCache
- (void)loadCache {
 
    _cacheModelArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:Cache_Key]];
    _isCache = NO;
    
    for (int i = 0; i < _bannerModelArray.count; i ++) {
        
        BannerModel *cacheModel = _cacheModelArray[i];
        BannerModel *bannerModel = _bannerModelArray[i];
        
        if ([cacheModel.imageUrl isEqualToString: bannerModel.imageUrl]) {
            
            _isCache = YES;
        } else {
            
            _isCache = NO;
            break;
        }
    }
    
    if (_isCache) {
        
        _bannerModelArray = [_cacheModelArray mutableCopy];
    } else {
        
        _cacheModelArray = [NSMutableArray array];
        for (int i = 0; i < _bannerModelArray.count; i ++) {
            
            [_cacheModelArray addObject:[[BannerModel alloc] init]];
        }
    }
}

#pragma mark - 初始界面
- (void)initUI {
    
    // ScrollView
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, Width, Height)];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    [self addSubview:_scrollView];
    
    _scrollView.contentSize = CGSizeMake(3 * Width, Height);
    _scrollView.contentOffset = CGPointMake(Width, 0);

    // TitleLabel
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, Height - 25, Width - 100 - 30, 30)];
    _titleLabel.font = [UIFont systemFontOfSize:13];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_titleLabel];
    
    // PageControl
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(Width - 100, Height - 25, 100, 30)];
    _pageControl.currentPageIndicatorTintColor = Current_Color;
    _pageControl.pageIndicatorTintColor = Defalut_Color;
    _pageControl.userInteractionEnabled = NO;
    _pageControl.numberOfPages = _bannerModelArray.count;
    [self addSubview:_pageControl];
    
    BannerModel *firstModel = _bannerModelArray.firstObject;
    if (!firstModel.title) {
        
        _pageControl.frame = CGRectMake(0, Height - 25, Width, 30);
    }
    
    // LeftImageView
    _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Width, Height)];
    _leftImageView.contentMode = UIViewContentModeScaleAspectFill;
    _leftImageView.clipsToBounds = YES;
    [_scrollView addSubview:_leftImageView];
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, Width, Height)];
    [leftButton addTarget:self action:@selector(clickScrollView:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:leftButton];
    
    // CenterImageView
    _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(Width, 0, Width, Height)];
    _centerImageView.contentMode = UIViewContentModeScaleAspectFill;
    _centerImageView.clipsToBounds = YES;
    [_scrollView addSubview:_centerImageView];
    UIButton *centerButton = [[UIButton alloc] initWithFrame:CGRectMake(Width, 0, Width, Height)];
    [centerButton addTarget:self action:@selector(clickScrollView:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:centerButton];
    
    // RightImageVIew
    _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2 * Width, 0, Width, Height)];
    _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    _rightImageView.clipsToBounds = YES;
    [_scrollView addSubview:_rightImageView];
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(2 *Width, 0, Width, Height)];
    [rightButton addTarget:self action:@selector(clickScrollView:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:rightButton];
    
    // ThreeModelArray
    if (_bannerModelArray.count == 1) {
        
        _threeModelArray = [NSMutableArray arrayWithArray:_bannerModelArray];
        _scrollView.contentSize = CGSizeMake(Width, Height);
        _scrollView.contentOffset = CGPointMake(0, 0);
    } else if (_bannerModelArray.count == 2) {
        
        _threeModelArray = [NSMutableArray arrayWithArray:@[_bannerModelArray.lastObject,_bannerModelArray.firstObject,_bannerModelArray.lastObject]];
    } else {
        
        _threeModelArray = [NSMutableArray arrayWithArray:@[_bannerModelArray.lastObject,_bannerModelArray.firstObject,_bannerModelArray[1]]];
    }
    
    if (_bannerModelArray.count > 1) {
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:TimeNum
                                                  target:self selector:@selector(processTimer)
                                                userInfo:nil
                                                 repeats:HUGE_VAL];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        _timer.fireDate = [[NSDate date] dateByAddingTimeInterval:TimeNum];
    }
}

#pragma makr - 初始数据
- (void)initDataSource {
    
    if (_isCache) {
        
        _bannerModelArray = [_cacheModelArray mutableCopy];
    }
    
    if (_index == 0) {
        
        if (_threeModelArray.count != 1) {
            
            _threeModelArray = [NSMutableArray arrayWithArray:@[_bannerModelArray.lastObject, _bannerModelArray.firstObject, _bannerModelArray[_index + 1]]];

        }
    } else if (_index == _bannerModelArray.count - 1) {
        
        _threeModelArray = [NSMutableArray arrayWithArray:@[_bannerModelArray[_bannerModelArray.count - 2], _bannerModelArray.lastObject, _bannerModelArray.firstObject]];
        
    } else {
        
        _threeModelArray = [NSMutableArray arrayWithArray:@[_bannerModelArray[_index - 1], _bannerModelArray[_index], _bannerModelArray[_index + 1]]];
    }
}

#pragma mark - 读取
- (void)loadImageData {
    
    for (int i = 0; i < _threeModelArray.count; i ++) {
        
        BannerModel *model = _threeModelArray[i];
        
        // Image
        if (model.image) {
            
            switch (i) {
                case 0:
                    
                    _leftImageView.image = model.image;
                    break;
                case 1:
                    
                    _centerImageView.image = model.image;
                    break;
                case 2:
                    
                    _rightImageView.image = model.image;
                    break;
                default:
                    break;
            }
            
        } else if (model.imageUrl) { // Url
            
            switch (i) {
                case 0:
                    
//                    [_leftImageView sd_setImageWithURL:[NSURL URLWithString:model.url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                        
//                    }];
                    _leftImageView.image = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.imageUrl]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    break;
                case 1:
                    
//                    [_centerImageView sd_setImageWithURL:[NSURL URLWithString:model.url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                        
//                    }];
                    _centerImageView.image = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.imageUrl]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    break;
                case 2:
                    
//                    [_rightImageView sd_setImageWithURL:[NSURL URLWithString:model.url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                        
//                    }];
                      _rightImageView.image = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.imageUrl]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    break;
                default:
                    break;
            }

        }
        
        if (model.title && i == 1) { // Title
            
            _titleLabel.text = model.title;
        }
        if (model.imageName) { // ImageName
            
            switch (i) {
                case 0:
                    
                    _leftImageView.image = Image_Of_Path(model.imageName);
                    break;
                case 1:
                    
                    _centerImageView.image = Image_Of_Path(model.imageName);
                    break;
                case 2:
                    
                    _rightImageView.image = Image_Of_Path(model.imageName);
                    break;
                default:
                    break;
            }

        }
    }
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_threeModelArray.count == 1) {
        
        return;
    }
    
    CGFloat xOff = scrollView.contentOffset.x / Width;
    if (xOff == 0) {   //向右滑动
        
        if (_index == 0) {
            
            _index = _bannerModelArray.count - 1;
        } else {
            
            _index = _index - 1;
        }
        
        [self initDataSource];
        
        if (_centerImageView.image) {
            
            _rightImageView.image = _centerImageView.image;
        }
        if (_leftImageView.image) {
            
            _centerImageView.image = _leftImageView.image;
        }
        
        BannerModel *titleModel = _threeModelArray[1];
        if (titleModel.title) {
            
            _titleLabel.text = titleModel.title;
        }
        
        BannerModel *model = _threeModelArray.firstObject;
        if (model.image) {
            
            _leftImageView.image = model.image;
        } else if (model.imageName) {
            
            _leftImageView.image = Image_Of_Path(model.imageName);
        } else if (model.imageUrl) {
            
            _leftImageView.image = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.imageUrl]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            BannerModel *cacheModel = [[BannerModel alloc] init];
            cacheModel.imageUrl = model.imageUrl;
            cacheModel.image = _leftImageView.image;
            
            
            if (_index == 0) {
                
                _cacheIndex = _bannerModelArray.count - 1;
            } else {
                
                _cacheIndex = _index - 1;
            }

            [_cacheModelArray replaceObjectAtIndex:_cacheIndex withObject:cacheModel];
            
            BOOL isFinish = YES;
            for (BannerModel *BM in _cacheModelArray) {
                
                if (!BM.imageUrl) {
                    
                    isFinish = NO;
                    break;
                }
            }
            
            if (isFinish) {
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_cacheModelArray] forKey:Cache_Key];
                [[NSUserDefaults standardUserDefaults] synchronize];
                _isCache = YES;
            }
        }
    } else if (xOff == 2) {   //向左滑动
        
        if (_index == _bannerModelArray.count - 1) {
            
            _index = 0;
        } else {
            
            _index = _index + 1;
        }
        
        [self initDataSource];
        
        if (_centerImageView.image) {
            
            _leftImageView.image = _centerImageView.image;
        }
        if (_rightImageView.image) {
            
            _centerImageView.image = _rightImageView.image;
        }
        
        
        BannerModel *titleModel = _threeModelArray[1];
        if (titleModel.title) {
            
            _titleLabel.text = titleModel.title;
        }
        
        BannerModel *model = _threeModelArray.lastObject;
        if (model.image) {
            
            _rightImageView.image = model.image;
        } else if (model.imageName) {
            
            _rightImageView.image = Image_Of_Path(model.imageName);
        } else if (model.imageUrl) {
            
            _rightImageView.image = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.imageUrl]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            BannerModel *cacheModel = [[BannerModel alloc] init];
            cacheModel.imageUrl = model.imageUrl;
            cacheModel.image = _rightImageView.image;
            
            if (_index == _cacheModelArray.count - 1) {
                
                _cacheIndex = 0;
            } else {
                
                _cacheIndex = _index + 1;
            }
            [_cacheModelArray replaceObjectAtIndex:_cacheIndex withObject:cacheModel];
            
            BOOL isFinish = YES;
            for (BannerModel *BM in _cacheModelArray) {
                
                if (!BM.imageUrl) {
                    
                    isFinish = NO;
                    break;
                }
            }
            
            if (isFinish) {
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_cacheModelArray] forKey:Cache_Key];
                [[NSUserDefaults standardUserDefaults] synchronize];
                _isCache = YES;
            }
        }
    } else {
    
        return;
    }
    
    scrollView.contentOffset = CGPointMake(Width, 0);
    _pageControl.currentPage = _index;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (_timer) {
        
        [self pauseTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (_timer) {
        
        [self startTimer];
    }
}

#pragma mark - Timer
- (void)processTimer {

    [_scrollView setContentOffset:CGPointMake(2 * Width, 0) animated:YES];
}

- (void)startTimer {
    
    _timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:TimeNum];
}

- (void)pauseTimer {
    
    _timer.fireDate = [NSDate distantFuture];
}

- (void)invalidateTimer {
    
    [_timer invalidate];
}

#pragma mark - ClickScrollView
- (void)clickScrollView:(UIButton *)sendeer {
    
    if ([_delegate respondsToSelector:@selector(returnSwsBannerViewIndex:bannerModel:)]) {
        
        [_delegate returnSwsBannerViewIndex:_index bannerModel:_bannerModelArray[_index]];
    }
}

@end
