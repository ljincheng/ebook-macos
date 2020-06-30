//
//  BrowserWindow.m
//  book
//
//  Created by ljc on 2019/11/27.
//  Copyright © 2019 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrowserWindow.h"


@implementation BrowserWindow
{
    
    NSString * _browserUrl;
    BookInfo * _bookInfo;
    WKWebView *mWebView;
    NSModalSession _session;
    NSTimeInterval keydownEventTimeInter;
}

//- (id)init {
//    self = [super initWithWindowNibName:@"BrowserWindow"];
//    if(!self) return nil;
//    NSLog(@"%s",__PRETTY_FUNCTION__);
//    return self;
//}
//
//- (void)loadWindow {
//    [super loadWindow];
//    [self.window setBackgroundColor:[NSColor colorWithDeviceWhite:0.73 alpha:1]];
//    NSLog(@"%s",__PRETTY_FUNCTION__);
//}

-(NSRect) defaultWindowFrame{
    NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
    return  NSMakeRect(60, 100, screenVisibleFrame.size.width-120, screenVisibleFrame.size.height-10);
}



-(void)loadWithURL:(NSString *)url
{
     _browserUrl=url;
    if(mWebView==nil)
    {
        [self windowDidLoads];
    }else{
        NSURL *weburl = [NSURL URLWithString:url];
        NSURLRequest *request = [NSURLRequest requestWithURL:weburl];
        [mWebView loadRequest:request];
    }
    
    
}

-(void) addWewView:(WKWebView *)webview{
    mWebView=webview;
    [self setContentView:mWebView];
    [self makeFirstResponder:webview];
}

- (void) windowDidLoads {
   
    NSRect frame =[self defaultWindowFrame ];

    
    WKWebViewConfiguration *bookWebViewConfig=[[WKWebViewConfiguration alloc] init];
    
    [[bookWebViewConfig preferences] setMinimumFontSize: 10.00];
    //    bookWebView=[[BookReadView alloc]initWithFrame:webViewRect configuration:bookWebViewConfig]  ;
    mWebView=[[WKWebView alloc] initWithFrame:frame configuration:bookWebViewConfig];
//    mWebView.navigationDelegate=self;
//    mWebView=[[WKWebView alloc]initWithFrame:frame];
    
    
    if(_browserUrl)
    {
        NSURL *url = [NSURL URLWithString:_browserUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [mWebView loadRequest:request];
        
//         [mWebView loadHTMLString:@"<body>HELLO</body>" baseURL:url];
    }else{
        NSString *path = @"https://www.baidu.com";
        NSURL *url = [NSURL URLWithString:path];
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
       // [mWebView loadRequest:request];
        [mWebView loadHTMLString:@"<body>HELLO</body>" baseURL:url];
        
    }
//    [mWebView setAutoresizesSubviews:TRUE ];
//    [mWebView setAutoresizingMask:NSViewMaxXMargin|NSViewWidthSizable|NSViewMaxYMargin|NSViewHeightSizable];
    //[self setAlphaValue:0.6];
    [self setContentView:mWebView];
//    [_mainWindow makeFirstResponder:[self contentViewController]];
    
    [self makeFirstResponder:mWebView];//注册为第一个事件响应View
    //[mWebView setNextResponder:[self setNextResponder:<#(NSResponder * _Nullable)#>]];
 
    
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    NSString  *characters = [theEvent charactersIgnoringModifiers];
    NSLog(@"=== 快捷键：%@",characters);
    if ([characters isEqual:@"l"]) {
        //        [self performClick:self];
        return YES;
    }
    if ([characters isEqual:@"r"]) {
        //        [self performClick:self];
        if(mWebView!=nil)
        {
        [mWebView reload];
        }
        return NO;
    }
    return NO;
}

-(void) keyDown:(NSEvent *)event{
    [super keyDown:event];
    NSLog(@"===browserWindow event keyDown=== %@",event);
    [self showResponderInfo];
}

-(void) showResponderInfo{
    NSResponder *responder=self.nextResponder;
    int index=0;
    while (responder) {
        NSLog(@"%d responder -%@",index,responder);
        index++;
        responder=responder.nextResponder;
        
    }
    
}

//- (NSString *)windowNibName {
//    return @"BrowserWindow";
//}
//
//- (void)windowDidResize:(NSNotification *)aNotification
//{
//#pragma unused (aNotification)
//    // 调整NSWindow上NSView的frame
//    //    [bookWebView setHidden:TRUE];
//    //    if(_mainWindow.frame.size.width >= MAXBOOKWINDOW)
//    //    {
//    //        [bookWebView setHidden:FALSE];
//    //    }
//}
//
//- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
//#pragma unused (application)
//    return YES;
//
//}
//- (void)windowWillClose:(NSNotification *)notification
//{
//#pragma unused (notification)
//   // NSWindow *window = notification.object;
//    //    if(window == self.window) {
//    // [NSApp terminate:self];
//    // [[NSApplication sharedApplication] terminate:nil];  //或这句也行
//    //    }
//
//
//}
//
//- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
//    #pragma unused (webView)
//    [mWebView reload];
//}
//


@end
