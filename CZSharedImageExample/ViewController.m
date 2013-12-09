//
//  ViewController.m
//  CZSharedImage
//
//  Created by Mark Smith on 12/6/13.
//  Copyright (c) 2013 Camazotz Limited. All rights reserved.
//

#import <mach/mach.h>
#import "CZSharedImage.h"
#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, readwrite, nonatomic) IBOutlet UITableView *actionsTable;

@property (strong, readwrite, nonatomic) IBOutlet UILabel *memoryLabel;
@property (strong, readwrite, nonatomic) IBOutlet UIView *imagesView;
@property (strong, readwrite, nonatomic) NSTimer *timer;
@end

#define DataBlockSize 1000000
#define DataBufferLength 10000

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.actionsTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

- (void)timerFired {
  [self updateMemoryLabel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
  
  cell.textLabel.text = @[
                          @"Empty",
                          @"UIImage#imageWithContentsOfFile",
                          @"UIImage#imageWithData",
                          @"CZSharedImage#imageWithContentsOfFile",
                          @"CZSharedImage#imageWithData"
                          ][indexPath.row];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *path = [self imagePath];
  
  switch (indexPath.row) {
    case 0: {
      [self clearImages];
      break;
    }
    case 1: {
      [self fillImagesUsingBlock:^{ return [UIImage imageWithContentsOfFile:path]; }];
      break;
    }
    case 2: {
      [self fillImagesUsingBlock:^{ return [UIImage imageWithData:[NSData dataWithContentsOfFile:path]]; }];
      break;
    }
    case 3: {
      [self fillImagesUsingBlock:^{ return [CZSharedImage imageWithContentsOfFile:path]; }];
      break;
    }
    case 4: {
      [self fillImagesUsingBlock:^{ return [CZSharedImage imageWithData:[NSData dataWithContentsOfFile:path]]; }];
      break;
    }
    default: {
      break;
    }
  }

  [self updateMemoryLabel];
}

- (void)fillImagesUsingBlock:(UIImage *(^)())block {
  [self clearImages];
  
  for (int row = 0; row < 10; ++row) {
    for (int col = 0; col < 10; ++col) {
      UIImageView *imageView = [[UIImageView alloc] initWithImage:block()];
      
      imageView.frame = CGRectMake((col * 28), (row * 28), 28, 28);
      [self.imagesView addSubview:imageView];
    }
  }
}

- (void)clearImages {
  while (self.imagesView.subviews.count > 0) {
    [[self.imagesView.subviews firstObject] removeFromSuperview];
  }
}

- (void)updateMemoryLabel {
  struct task_basic_info info;
  mach_msg_type_number_t size = TASK_BASIC_INFO_COUNT;
  task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
  
  self.memoryLabel.text = [NSString stringWithFormat:@"%uM", (info.resident_size / 1000000)];
}

- (NSString *)imagePath {
  return [NSBundle.mainBundle.bundlePath stringByAppendingString:@"/500x500.jpg"];
}

@end
