//
//  CZSharedImageTests.m
//  CZSharedImageTests
//
//  Created by Mark Smith on 12/6/13.
//  Copyright (c) 2013 Camazotz Limited. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CZSharedImage.h"

@interface CZSharedImageTests : XCTestCase
@end

@implementation CZSharedImageTests

- (void)testUIImageMethods {
  UIImage *image = [CZSharedImage imageWithContentsOfFile:[self imagePath]];
  XCTAssertNotEqual(image, [UIImage imageWithContentsOfFile:[self imagePath]]);

  NSData *data = [NSData dataWithContentsOfFile:[self imagePath]];
  image = [UIImage imageWithData:data];
  XCTAssertNotEqual(image, [UIImage imageWithData:data]);
}

- (void)testImageWithContentsOfFile {
  UIImage *image = [CZSharedImage imageWithContentsOfFile:[self imagePath]];
  
  XCTAssertNotNil(image);
  XCTAssertEqual(image, [CZSharedImage imageWithContentsOfFile:[self imagePath]]);
}

- (void)testImageWithData {
  NSData *data = [NSData dataWithContentsOfFile:[self imagePath]];
  UIImage *image = [CZSharedImage imageWithData:data];
  
  XCTAssertNotNil(image);
  XCTAssertEqual(image, [CZSharedImage imageWithData:data]);
}

- (void)testImageWithDataScale {
  NSData *data = [NSData dataWithContentsOfFile:[self imagePath]];
  UIImage *image = [CZSharedImage imageWithData:data scale:2];
  
  XCTAssertNotNil(image);
  XCTAssertEqual(image, [CZSharedImage imageWithData:data scale:2]);
  XCTAssertNotEqual(image, [CZSharedImage imageWithData:data scale:1]);
}

- (void)testSetImageForKey {
  NSURL *url = [NSURL fileURLWithPath:[self imagePath]];
  NSString *path = [url absoluteString];
  NSData *data = [NSData dataWithContentsOfURL:url];
  UIImage *image = [UIImage imageWithData:data];

  XCTAssertNotNil(image);
  XCTAssertNil([CZSharedImage imageForPath:path]);
  [CZSharedImage setImage:image forPath:path];
  XCTAssertEqual(image, [CZSharedImage imageForPath:path]);
}

- (NSString *)imagePath {
  return [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:@"500x500.jpg"];
}

@end
