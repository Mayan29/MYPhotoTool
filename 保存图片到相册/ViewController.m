//
//  ViewController.m
//  保存图片到相册
//
//  Created by mayan on 2016/12/28.
//  Copyright © 2016年 mayan. All rights reserved.
//

#import "ViewController.h"
#import "MYPhotoTool.h"

@interface ViewController ()

@end

@implementation ViewController


// 点击任意处保存照片
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UIImage *img = [UIImage imageNamed:@"myPic"];
    
    [MYPhotoTool saveToCollectionWithImage:img completion:^(BOOL success) {
        
        if (success) {
            NSLog(@"保存成功");
        }
    }];
}


@end
