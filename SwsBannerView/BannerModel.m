//
//  BannerModel.m
//
//  Created by sws on 6/6/6.
//  Copyright © 666年 sws. All rights reserved.
//

#import "BannerModel.h"

@implementation BannerModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.imageUrl forKey:@"imageUrl"];
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.imageName forKey:@"imageName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]) {
        
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
        self.image = [aDecoder decodeObjectForKey:@"image"];
        self.imageName = [aDecoder decodeObjectForKey:@"imageName"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
    BannerModel* newModel = [[BannerModel allocWithZone:zone]init];
    newModel.title = self.title;
    newModel.imageName = self.imageName;
    newModel.imageUrl = self.imageUrl;
    newModel.image = self.image;
    
    return newModel;
}
@end
