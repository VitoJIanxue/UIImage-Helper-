//
//  UIImage+Helper.m
//  UIImage+Helper
//
//  Created by Vito on 2018/1/18.
//  Copyright © 2018年 inspur. All rights reserved.
//

#import "UIImage+Helper.h"

#define UETagImageHeight 24

@implementation UIImage (Helper)

+ (UIImage *)grayImageWithImage:(UIImage *)originalImage
{
    CGSize size = originalImage.size;
    CGRect rect = CGRectMake(0.0f, 0.0f, originalImage.size.width,
                             originalImage.size.height);
    // Create a mono/gray color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, size.width,
                                                 size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    // Draw the image into the grayscale context
    CGContextDrawImage(context, rect, [originalImage CGImage]);
    CGImageRef grayscale = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    // Recover the image
    UIImage *img = [UIImage imageWithCGImage:grayscale];
    CFRelease(grayscale);
    return img;
}

- (UIImage *)imageByScalingToSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor < heightFactor) {
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    // this is actually the interesting part:
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    return newImage ;
}

+ (instancetype)blurImageWithImage:(UIImage *)originalImage
{
    CGSize oriSize = originalImage.size;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [[CIImage alloc] initWithImage:originalImage];
    
    // create gaussian blur filter
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    //    CIFilter *filter = [CIFilter filterWithName:kCICategoryBlur];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    //    [filter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputRadius"];
    [filter setValue:@(10.0) forKey:kCIInputRadiusKey];
    // blur image
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // 切掉四周白边
    CGFloat scale = originalImage.scale;
    //    CGFloat padding = 30 * scale;
    //    CGRect extentRect = [result extent];
    //    CGImageRef cgImage = [context createCGImage:result fromRect:CGRectMake(0, 0, extentRect.size.width + 2 * extentRect.origin.x, extentRect.size.height + 2 * extentRect.origin.y)];
    CGImageRef cgImage = [context createCGImage:result fromRect:CGRectMake(0, 0, oriSize.width * scale , oriSize.height * scale)];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    //    image = [image imageByScalingToSize:oriSize];
    
    CGImageRelease(cgImage);
    
    return image;
}

+ (instancetype)blurImageWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    
    return [self blurImageWithImage:image];
}

+ (instancetype)blurImageWithColor:(UIColor *)fillColor
{
    //    UIImage *image = [[UIImage alloc] initWithCIImage:[[CIImage imageWithColor:color.CIColor] imageByCroppingToRect:[UIScreen mainScreen].bounds]];
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    UIImage *image = [self imageWithColor:fillColor size:size];
    
    return [self blurImageWithImage:image];
}

+ (instancetype)imageWithColor:(UIColor *)color size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size , NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (instancetype)tagImageWithBackgroundImageNamed:(NSString *)imageName text:(NSString *)text
{
    return [self tagImageWithBackgroundImageNamed:imageName text:text textColor:[UIColor whiteColor]];
}

+ (instancetype)tagImageWithBackgroundImageNamed:(NSString *)imageName text:(NSString *)text textColor:(UIColor *)textColor
{
    CGFloat imageHeight = UETagImageHeight;
    
    if (!text) {
        text = @"";
    }
    
    //    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    //    para.paragraphSpacingBefore = 5;
    NSDictionary *textAttr = @{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: textColor/*, NSParagraphStyleAttributeName: para*/};
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:text attributes:textAttr];
    
    CGFloat textWidth = [attrText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, imageHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
    
    CGFloat imageWidth = textWidth + 30;
    
    CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect imageRect = (CGRect){{0, 0}, imageSize};
    
    //    CGContextDrawImage(context, imageRect, <#CGImageRef image#>)
    
    UIImage *originalImage = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 30, 1, 1/[UIScreen mainScreen].scale) resizingMode:UIImageResizingModeStretch];
    
    [originalImage drawInRect:imageRect];
    
    [attrText drawInRect:CGRectMake(20, 4, textWidth, imageHeight - 4)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (instancetype)tagImageWithText:(NSString *)text textColor:(UIColor *)textColor
{
    CGFloat height = UETagImageHeight;
    
    if (!text) {
        text = @"";
    }
    
    //    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    //    para.paragraphSpacingBefore = 5;
    NSDictionary *textAttr = @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:14], NSForegroundColorAttributeName: textColor/*, NSParagraphStyleAttributeName: para*/};
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:text attributes:textAttr];
    
    CGFloat textWidth = [attrText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
    
    CGFloat width = textWidth + 10;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0);
    
    [attrText drawInRect:CGRectMake(5, 4, textWidth, height - 4)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (instancetype)tagImageWithBlueText:(NSString *)text
{
    return [self tagImageWithText:text textColor:[UIColor blueColor]];
}

+ (instancetype)imageWithViewShot:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //    [view.layer renderInContext:ctx];
    
    for (CALayer *subLayer in view.layer.sublayers) {
        if (![subLayer isMemberOfClass:[CALayer class]]) {
            [subLayer renderInContext:ctx];
        }
    }
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return viewImage;
}

+ (UIImage *)QRImageWithString:(NSString *)str side:(CGFloat)side
{
    NSData *stringData = [str dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CIImage *img = qrFilter.outputImage;
    
    
    CGRect extent = CGRectIntegral(img.extent);
    CGFloat scale = MIN(side/CGRectGetWidth(extent), side/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:img fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

+ (UIImage *)downArrowImageWithSide:(CGFloat)side
{
    return [self downArrowImageWithSide:side color:[UIColor whiteColor]];
}

+ (UIImage *)downArrowImageWithSide:(CGFloat)side color:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(side, side), NO, 0);
    
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.alignment = NSTextAlignmentCenter;
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"<" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:side], NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: para}];
    [str drawInRect:CGRectMake(0.0, 0.0, side, side)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    image = [UIImage imageWithCGImage:image.CGImage scale:0 orientation:UIImageOrientationLeft];
    return image;
}

+ (UIImage *)upArrowImageWithSide:(CGFloat)side
{
    return [self upArrowImageWithSide:side color:[UIColor whiteColor]];
}

+ (UIImage *)upArrowImageWithSide:(CGFloat)side color:(UIColor *)color
{
    UIImage *image = [self downArrowImageWithSide:side color:color];
    
    image = [UIImage imageWithCGImage:image.CGImage scale:0 orientation:UIImageOrientationLeftMirrored];
    return image;
}


- (UIImage *)imageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)hollowCircleImageWithRadius:(CGFloat)radius color:(UIColor *)color
{
    CGFloat width = radius * 2.0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1.0/[UIScreen mainScreen].scale);
    CGContextAddEllipseInRect(context, CGRectMake(0.0, 0.0, width, width));
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)squareImageWithArcLineWithImageWidth:(CGFloat)width lineWidth:(CGFloat)lineWidth startRadian:(CGFloat)startRadian endRadian:(CGFloat)endRadian lineColor:(UIColor *)lineColor
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, width);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextAddArc(context, width * 0.5, width * 0.5, width * 0.5, startRadian, endRadian, 0);
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
