//
//  WebView+ToFile.m
//  WebViewToFile
//
//  Created by zhuochenming on 15-6-10.
//  Copyright (c) 2015 zhuochenming. All rights reserved.
//

#import "WebView+ToFile.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (ToFile)

- (UIImage *)convertToImage {
    if (![self isKindOfClass:[UIWebView class]] && ![self isKindOfClass:[WKWebView class]]) {
        NSAssert(NO, @"请用UIWebView或者WKWebView调用");
        return nil;
    } else if ([self isKindOfClass:[UIWebView class]]) {
        UIWebView *webView = (UIWebView *)self;
        return [self getImageWithScrollView:webView.scrollView];
    } else if ([self isKindOfClass:[WKWebView class]]) {
        WKWebView *webView = (WKWebView *)self;
        return [self getImageWithScrollView:webView.scrollView];
    } else {
        return nil;
    }
}

- (UIImage *)getImageWithScrollView:(UIScrollView *)scrollView {
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize contentSize = scrollView.contentSize;
    CGFloat contentHeight = contentSize.height;
    
    CGPoint offset = scrollView.contentOffset;
    
    [scrollView setContentOffset:CGPointMake(0, 0)];
    
    NSMutableArray *imageArray = [NSMutableArray array];
    while (contentHeight > 0) {
        UIGraphicsBeginImageContextWithOptions(boundsSize, NO, 0.0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [imageArray addObject:image];
        
        CGFloat offsetY = scrollView.contentOffset.y;
        [scrollView setContentOffset:CGPointMake(0, offsetY + boundsHeight)];
        contentHeight -= boundsHeight;
    }
    
    [scrollView setContentOffset:offset];
    CGSize imageSize = CGSizeMake(contentSize.width * scale, contentSize.height * scale);
    UIGraphicsBeginImageContext(imageSize);
    [imageArray enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        [image drawInRect:CGRectMake(0, scale * boundsHeight * idx, scale * boundsWidth, scale * boundsHeight)];
    }];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fullImage;
}

- (NSData *)convertToPDFData {
    UIViewPrintFormatter *formater = [self viewPrintFormatter];
    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    [render addPrintFormatter:formater startingAtPageAtIndex:0];
    
    CGRect page;
    page.origin.x = 0;
    page.origin.y = 0;
    
    CGRect rect = [UIScreen mainScreen].bounds;
    page.size.width = CGRectGetWidth(rect);
    page.size.height = CGRectGetHeight(rect);
    
    CGRect printable = CGRectInset(page, 50, 50);
    [render setValue:[NSValue valueWithCGRect:page] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printable] forKey:@"printableRect"];
    
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
    
    for (NSInteger i = 0; i < [render numberOfPages]; i++) {
        UIGraphicsBeginPDFPage();
        CGRect bounds = UIGraphicsGetPDFContextBounds();
        [render drawPageAtIndex:i inRect:bounds];
    }
    UIGraphicsEndPDFContext();
    return pdfData;
}

@end
