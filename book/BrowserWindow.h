//
//  BrowserWindow.h
//  mobi
//
//  Created by ljc on 2019/11/27.
//  Copyright © 2019 Bartek Fabiszewski. All rights reserved.
//

#ifndef BrowserWindow_h
#define BrowserWindow_h

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "BookReadWindow.h"
#import "BookInfo.h"

@interface BrowserWindow:NSWindow
//@property (strong) IBOutlet BookReadWindow *mainWindow;

-(void)loadWithURL:(NSString *)url;

-(void) addWewView:(WKWebView *)webview;

@end

#endif /* BrowserWindow_h */
