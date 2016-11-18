//
//  SwsBannerView.h
//
//  Created by sws on 6/6/6.
//  Copyright © 666年 sws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BannerModel.h"

@protocol SwsBannerViewDelegate <NSObject>

@optional

/** 返回下标, Model */
- (void)returnSwsBannerViewIndex:(NSInteger)index bannerModel:(BannerModel *)bannerModel;

@end

@interface SwsBannerView : UIView

@property (nonatomic, weak) id <SwsBannerViewDelegate> delegate;

/** SwsBannerView */
- (SwsBannerView *)initWithFrame:(CGRect)frame
                      bannerModelArray:(NSMutableArray *)bannerModelArray
                        delegate:(id)delegate;
@end
