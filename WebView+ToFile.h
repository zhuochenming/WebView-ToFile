//
//  WebView+ToFile.h
//  WebViewToFile
//
//  Created by zhuochenming on 15-6-10.
//  Copyright (c) 2015 zhuochenming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface UIWebView (ToFile)

- (UIImage *)convertToImage;

- (NSData *)convertToPDFData;

@end

@interface WKWebView (ToFile)

- (UIImage *)convertToImage;

- (NSData *)convertToPDFData;

@end