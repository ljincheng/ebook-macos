//
//  BrowserWindowController.m
//  book
//
//  Created by ljc on 2019/11/29.
//  Copyright © 2019 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrowserWindowController.h"


@implementation BrowserWindowController
{
    
    NSString * _browserUrl;
//    BookInfo * _bookInfo;
//    WKWebView *mWebView;
    NSModalSession _session;
    NSTimeInterval keydownEventTimeInter;
}

- (id)init {
    self = [super initWithWindowNibName:@"BrowserWindow"];
    if(!self) return nil;
    NSLog(@"%s",__PRETTY_FUNCTION__);
    return self;
}

//- (void)loadWindow {
//    [super loadWindow];
//    [self.window setBackgroundColor:[NSColor colorWithDeviceWhite:0.73 alpha:1]];
//    NSLog(@"%s",__PRETTY_FUNCTION__);
//}

-(NSRect) defaultWindowFrame{
    NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
    return  NSMakeRect(60, 100, screenVisibleFrame.size.width-120, screenVisibleFrame.size.height-10);
}



-(instancetype)initWithURL:(NSString *)url
{
    self=[super initWithWindowNibName:@"BrowserWindow"];
    if(self){
        _browserUrl=url;
    }
    
    return self;
}
//-(instancetype)initWithInfo:(BookInfo *)bookInfo{
//    self=[super initWithWindowNibName:@"BrowserWindow"];
//    if(self){
//        _bookInfo=bookInfo;
//    }
//
//    return self;
//}

- (void)windowDidLoad   {
    [super windowDidLoad];
    keydownEventTimeInter=0.0f;
    _browserWindow.styleMask = _browserWindow.styleMask | NSWindowStyleMaskFullSizeContentView;
    [_browserWindow setTitleVisibility:NSWindowTitleHidden];
    NSRect frame =[self defaultWindowFrame ];
    [[_browserWindow animator] setFrame:frame display:FALSE];
    // _mainWindow.delegate=self;
    
    //启动模态窗口
    _session=[NSApp beginModalSessionForWindow:_browserWindow];
    if(_browserUrl)
    {
    [_browserWindow loadWithURL:_browserUrl];
    }
}


- (NSString *)windowNibName {
    return @"BrowserWindow";
}

- (void)windowDidResize:(NSNotification *)aNotification
{
#pragma unused (aNotification)
    // 调整NSWindow上NSView的frame
    //    [bookWebView setHidden:TRUE];
    //    if(_mainWindow.frame.size.width >= MAXBOOKWINDOW)
    //    {
    //        [bookWebView setHidden:FALSE];
    //    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
#pragma unused (application)
    return YES;
    
}
- (void)windowWillClose:(NSNotification *)notification
{
#pragma unused (notification)
//    NSWindow *window = notification.object;
    //    if(window == self.window) {
    // [NSApp terminate:self];
    // [[NSApplication sharedApplication] terminate:nil];  //或这句也行
    //    }
//    if(window == _mainWindow) {
//        
//        [NSApp endModalSession:_session];
//    }
    
}

//- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
//#pragma unused (webView)
//    [mWebView reload];
//}



@end
