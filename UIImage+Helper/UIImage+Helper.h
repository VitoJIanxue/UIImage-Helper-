//
//  UIImage+Helper.h
//  UIImage+Helper
//
//  Created by Vito on 2018/1/18.
//  Copyright © 2018年 inspur. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper)

// 文字颜色为灰色
+ (UIImage *)grayImageWithImage:(UIImage *)originalImage;

// 模糊图片
+ (instancetype)blurImageWithImageName:(NSString *)imageName;

// 绘制color颜色图片
+ (instancetype)imageWithColor:(UIColor *)color size:(CGSize)size;

// 文字颜色为白色
+ (instancetype)tagImageWithBackgroundImageNamed:(NSString *)imageName text:(NSString *)text;

// 可设置文字颜色
+ (instancetype)tagImageWithBackgroundImageNamed:(NSString *)imageName text:(NSString *)text textColor:(UIColor *)textColor;

// 文字转为图片
+ (instancetype)tagImageWithText:(NSString *)text textColor:(UIColor *)textColor;

// 文字转为图片(blue)
+ (instancetype)tagImageWithBlueText:(NSString *)text;

// 比例显示图片
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;

// 截图
+ (instancetype)imageWithViewShot:(UIView *)view;

// 生成二维码
+ (UIImage *)QRImageWithString:(NSString *)str side:(CGFloat)side;

// 向下箭头, 其实是小于号, 白色
+ (UIImage *)downArrowImageWithSide:(CGFloat)side;

+ (UIImage *)downArrowImageWithSide:(CGFloat)side color:(UIColor *)color;

// 向上箭头
+ (UIImage *)upArrowImageWithSide:(CGFloat)side;

+ (UIImage *)upArrowImageWithSide:(CGFloat)side color:(UIColor *)color;

//改变图片颜色
- (UIImage *)imageWithColor:(UIColor *)color;

// 空心圆
+ (UIImage *)hollowCircleImageWithRadius:(CGFloat)radius color:(UIColor *)color;


// 弧
+ (UIImage *)squareImageWithArcLineWithImageWidth:(CGFloat)width lineWidth:(CGFloat)lineWidth startRadian:(CGFloat)startRadian endRadian:(CGFloat)endRadian lineColor:(UIColor *)lineColor;

@end
