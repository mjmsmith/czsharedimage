//
//  CZSharedImage.m
//  CZSharedImage
//
//  Created by Mark Smith on 12/6/13.
//  Copyright (c) 2013 Camazotz Limited. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "CZSharedImage.h"

NSMapTable *imageMapTable;


@implementation CZSharedImage

#pragma mark Class initializer

+ (void)initialize {
  if (self == [CZSharedImage class]) {
    imageMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
  }
}

#pragma mark Static methods

+ (UIImage *)imageWithContentsOfFile:(NSString *)path {
  UIImage *image = [imageMapTable objectForKey:path];
  
  if (image != nil) {
    return image;
  }
  
  if ((image = [[self alloc] initWithContentsOfFile:path]) != nil) {
    [imageMapTable setObject:image forKey:path];
  }
  
  return image;
}

+ (UIImage *)imageWithData:(NSData *)data {
  NSString *path = [CZSharedImage md5StringForData:data];
  UIImage *image = [imageMapTable objectForKey:path];
  
  if (image != nil) {
    return image;
  }
  
  if ((image = [[self alloc] initWithData:data]) != nil) {
    [imageMapTable setObject:image forKey:path];
  }
  
  return image;
}

+ (UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale {
  NSString *path = [NSString stringWithFormat:@"%@:%f", [CZSharedImage md5StringForData:data], scale];
  UIImage *image = [imageMapTable objectForKey:path];

  if (image != nil) {
    return image;
  }

  if ((image = [[self alloc] initWithData:data scale:scale]) != nil) {
    [imageMapTable setObject:image forKey:path];
  }
  
  return image;
}

+ (UIImage *)imageForPath:(NSString *)path {
  return [imageMapTable objectForKey:path];
}

+ (UIImage *)setImage:(UIImage *)image forPath:(NSString *)path {
  if (image == nil || path.length == 0) {
    return nil;
  }
  
  [imageMapTable setObject:image forKey:path];
  
  return image;
}

#pragma mark Private

+ (NSString *)md5StringForData:(NSData *)data {
  uint8_t *bytes = (uint8_t *)data.bytes;
  uint8_t digest[CC_MD5_DIGEST_LENGTH];
  
  CC_MD5(bytes, (uint)data.length, digest);

  NSMutableString *str = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];

  for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
    [str appendFormat:@"%02X", bytes[i]];
  }
  
  return str;
}

@end
