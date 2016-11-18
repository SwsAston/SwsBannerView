//
//  ViewController.m
//
//  Created by sws on 6/6/6.
//  Copyright © 666年 sws. All rights reserved.
//

#import "ViewController.h"
#import "SwsBannerView.h"
#import "BannerModel.h"

@interface ViewController () <SwsBannerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSMutableArray *bannerModelArray = [NSMutableArray array];
    
    NSArray *urlArray = @[@"http://pic10.nipic.com/20101103/5063545_000227976000_2.jpg",@"http://pic41.nipic.com/20140519/18505720_094832590165_2.jpg",@"http://d.hiphotos.bdimg.com/album/whcrop%3D657%2C370%3Bq%3D90/sign=2c994e578a82b9013df895711cfd9441/09fa513d269759eede0805bbb2fb43166d22df62.jpg",@"http://pic63.nipic.com/file/20150405/9448607_131532608000_2.jpg",@"http://img.taopic.com/uploads/allimg/111020/6462-11102012191612.jpg",@"http://pic27.nipic.com/20130311/1056319_114419500000_2.jpg"];
    
    for (int i = 0; i < 6; i ++) {
        
        BannerModel *model = [[BannerModel alloc] init];
        model.title = [NSString stringWithFormat:@"Title ---- %d", i];
        
        // 2选一
        model.imageName = [NSString stringWithFormat:@"%d.jpg",i];
//        model.imageUrl = urlArray[i];
        
        [bannerModelArray addObject:model];
    }
    
    SwsBannerView *bannerView = [[SwsBannerView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 375) bannerModelArray:bannerModelArray delegate:self];
    [self.view addSubview:bannerView];
}

#pragma mark - SwsBannerViewDelegate

- (void)returnSwsBannerViewIndex:(NSInteger)index bannerModel:(BannerModel *)bannerModel {
    
    NSLog(@"%ld,%@",index, bannerModel.title);
}

@end
