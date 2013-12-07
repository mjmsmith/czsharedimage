//
//  CZSharedImage.h
//  CZSharedImage
//
//  Created by Mark Smith on 12/6/13.
//  Copyright (c) 2013 Camazotz Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZSharedImage : UIImage

+ (UIImage *)imageWithContentsOfFile:(NSString *)path;
+ (UIImage *)imageWithData:(NSData *)data;
+ (UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale;

+ (UIImage *)imageForPath:(NSString *)path;
+ (UIImage *)setImage:(UIImage *)image forPath:(NSString *)path;

+ (NSString *)md5StringForData:(NSData *)data;

@end
