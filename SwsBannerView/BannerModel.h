//
//  BannerModel.h
//
//  Created by sws on 6/6/6.
//  Copyright © 666年 sws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BannerModel : NSObject

// 可以不选
@property (nonatomic, copy)   NSString *title;

// 三者只能选一
@property (nonatomic, copy)   NSString *imageUrl;
@property (nonatomic, copy)   NSString *imageName;
@property (nonatomic, strong) UIImage  *image;

@end
