//
//  BookReadView.m
//  book
//
//  Created by ljc on 2018/10/23.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/NSResponder.h>
#import "BookReadView.h"



#define  SHEET @"var mySheet = document.styleSheets[0];"
#define  ADDCSSRULE @"function addCSSRule(selector, newRule) {if (mySheet.addRule) {mySheet.addRule(selector, newRule);} else {ruleIndex = mySheet.cssRules.length;mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);}}"

//#define BOOK_BACKGROUND_0 @"document.body.style.background='#fff';  document.body.style.color='';";
//#define BOOK_BACKGROUND_1 @"document.body.style.background='#fffaf2'; document.body.style.color='#282828';";
//#define BOOK_BACKGROUND_2 @"document.body.style.background='#1f1e1f'; document.body.style.color='#b6b6b6'; ";



static NSString *BOOK_BACKGROUND_0=@"document.body.style.background='#fff';  document.body.style.color='';";
static NSString *BOOK_BACKGROUND_1=@"document.body.style.background='#fffaf2';  document.body.style.color='#282828';";
static NSString *BOOK_BACKGROUND_2=@"document.body.style.background='#f3f3f3';  document.body.style.color='#282828';";
static NSString *BOOK_BACKGROUND_3=@"document.body.style.background='#1f1e1f';  document.body.style.color='#b6b6b6';";
@implementation BookReadView{
    BookToolbar *_bookToolbar;
    NSWindow *_bookWindow;
    NSString * _bookBackgroundColor;
    NSInteger _pageColor;
    int _currentGoLR;//1向前，-1向后
    bool _hasHistoryPageIndex;
    BookRead * _bookRead;
    int _scrollWhellGoLR;
}

-(bool) hasHistoryPageIndex{
    return _hasHistoryPageIndex;
}
-(void) setHasHistoryPageIndex:(bool) hasHistory
{
    _hasHistoryPageIndex=hasHistory;
}
//{
//    NSString * _bookFilePath;
//    BookRead *_bookRead;
//    //    int _pagesInCurrentSpineCount;
//    //    int _currentPageInSpineIndex;
//    int _currentGoLR;//1向前，-1向后
//    int _splitPage;
//    int _showMenu;
//    NSTimeInterval keydownEventTimeInter;
//
//    //WebView *webView;
//
//    BookReadView *bookWebView;
//    BookNav * rootBookNav;
//    BookInfo * _bookInfo;
//    bool _hasInitBookMenu;
//    NSModalSession _session;
//    NSString * _bookBackgroundColor;
//    int _pageColor;
//
//}

-(id)initWithFrame:(NSRect) frame{
    WKWebViewConfiguration *bookWebViewConfig=[[WKWebViewConfiguration alloc] init];
    [bookWebViewConfig setURLSchemeHandler:self forURLScheme:@"ebook"];
    [[bookWebViewConfig preferences] setMinimumFontSize: 10.00];
//    bookWebView=[[BookReadView alloc]initWithFrame:webViewRect configuration:bookWebViewConfig]  ;
    self=[super initWithFrame:frame configuration:bookWebViewConfig];
    if(self)
    {
        
        _chapterCount=0;
        _chapterIndex=0;
        _pageCount=0;
        _pageIndex=0;
        _currentGoLR=1;//1向前，-1向后
        _bookBackgroundColor= BOOK_BACKGROUND_0;
        _pageColor=0;
        _bookRead=nil;
        _splitPage=1;
        _hasHistoryPageIndex=false;
        
        [self setNavigationDelegate:self];
        [self setAutoresizesSubviews:TRUE ];
        [self setAutoresizingMask:NSViewMaxXMargin|NSViewWidthSizable|NSViewMaxYMargin|NSViewHeightSizable];
        //[self setAlphaValue:0.6];
        //设置左右滑动手势
        self.leftSwipeGestureRecognizer = [[NSPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        //self.rightSwipeGestureRecognizer = [[NSPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
        
        self.leftSwipeGestureRecognizer.delaysKeyEvents =YES;
        //self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        
        [self addGestureRecognizer:_leftSwipeGestureRecognizer];
      
    }
    return self;
}
-(void) loadBookRead:(BookRead *)book pageIndex:(int) pageindex chapterIndex:(size_t) chaptedindex pageColor:(NSInteger) colorindex splitPage:(int) splitpage{
    
    _chapterIndex=chaptedindex;
    _pageIndex=pageindex;
    _hasHistoryPageIndex=true;
    [self pageColorIndex:colorindex];
    _bookRead=book;
    _splitPage=splitpage;
    _chapterCount=[_bookRead chapterCount];
    if(_chapterIndex>_chapterCount)
    {
        _chapterIndex=0;
    }
    NSURL *url=[NSURL URLWithString:@"ebook://"];
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}
-(void) bookToolBar:(NSWindow *) bookWindow toolbar:(BookToolbar *)toolbar{
    _bookToolbar=toolbar;
    _bookWindow=bookWindow;
}


-(void) setCurrentGoLR:(int )lr{
    _currentGoLR=lr;
}
-(int) currentGoLR{
    return _currentGoLR;
}


//请求之前，决定是否要跳转:用户点击网页上的链接，需要打开新页面时，将先调用这个方法。
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
#pragma unused (webView,decisionHandler,navigationAction)
    NSLog(@"日志：decidePolicyForNavigationAction,1");
    // NSLog(@"标题:%@\n",[webView title]);
    
    //WKNavigationActionPolicy Cancel = WKNavigationActionPolicyCancel;// 取消导航
    
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    NSLog(@"scheme=%@,url=%@",scheme,[URL absoluteString]);
    /*
     if (![scheme isEqualToString:@"ebook"] ) {
     // [self handleCustomAction:URL];
     decisionHandler(WKNavigationActionPolicyCancel);
     return;
     }
     */
    WKNavigationActionPolicy Allow = WKNavigationActionPolicyAllow;//    允许导航
    NSLog(@"加载请求通过，scheme=%@,url=%@",scheme,[URL absoluteString]);
    decisionHandler(Allow);
    
    
    
}

//接收到相应数据后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
#pragma unused (webView,decisionHandler,navigationResponse)
    WKNavigationResponsePolicy responsePolicy = WKNavigationResponsePolicyAllow;
    //NSLog(@"333333");
    decisionHandler(responsePolicy);
}

//页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
#pragma unused (webView,navigation)
    
    [self setPaginating:NO];
}

// 主机地址被重定向时调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
#pragma unused (webView,navigation)
    
    [self setPaginating:YES];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
#pragma unused (webView,navigation,error)
    NSLog(@"页面加载失败时调用");
    
    [self setPaginating:YES];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
#pragma unused (webView,navigation)
    [webView evaluateJavaScript:@"document.body.style.color= '#000000';" completionHandler:nil];
    NSLog(@"当内容开始返回时调用");
    
}

//重置分页模式下的页数和当前第几页
-(void) resetSplitWebPageIndexAndCount{
    CGFloat webpagewidth=self.frame.size.width;
    if(![self hasHistoryPageIndex])
    {
        if([self currentGoLR] <0)
        {
             [self setCurrentGoLR:1];
            [self evaluateJavaScript: [NSString stringWithFormat:@"pageScrollLast(%f)",webpagewidth] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                if(!error)
                {
                    NSNumberFormatter *formatter=[[NSNumberFormatter alloc]init];
                    int pageIndex=  [[formatter numberFromString:[NSString stringWithFormat:@"%@",response] ]intValue];
                    NSLog(@"pageIndex:pageIndex=%d,webpagewidth=%f",pageIndex,webpagewidth);
                    [self setPageIndex:pageIndex];
                    [self setCurrentGoLR:1];
                }else{
                    NSLog(@"pageIndex:error=%@",error);
                }
            }];
        }else{
            [self evaluateJavaScript: [NSString stringWithFormat:@"pageIndex(%f)",webpagewidth] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                if(!error)
                {
                    NSNumberFormatter *formatter=[[NSNumberFormatter alloc]init];
                    int pageIndex=  [[formatter numberFromString:[NSString stringWithFormat:@"%@",response] ]intValue];
                    NSLog(@"pageIndex:pageIndex=%d,webpagewidth=%f",pageIndex,webpagewidth);
                    [self setPageIndex:pageIndex];
                    [self setCurrentGoLR:1];
                }else{
                    NSLog(@"pageIndex:error=%@",error);
                }
            }];
        }
    }
    
    [self  evaluateJavaScript:@"document.body.scrollWidth" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if(!error){
            NSNumberFormatter *formatter=[[NSNumberFormatter alloc]init];
            float totalWidth=  [[formatter numberFromString:[NSString stringWithFormat:@"%@",response] ]floatValue];
            int webpagecount=(int)ceil(totalWidth/webpagewidth);
            NSLog(@"pageCount: totalWidth=%f,width=%f,page=%d",totalWidth,webpagewidth,webpagecount);
            [self setPageCount:webpagecount];
            if([self hasHistoryPageIndex])
            {
                [self gotoPageInCurrentSpine:[self pageIndex]];
                [self setHasHistoryPageIndex:false];
            }
        }else{
            NSLog(@"pageCount:error=%@",error);
        }
     
    }] ;
}
-(void) resetPageWebPageIndexAndCount{
     [self setCurrentGoLR:1];
    CGFloat webpagewidth=self.frame.size.height;
    [self evaluateJavaScript: [NSString stringWithFormat:@"pageIndex(%f)",webpagewidth] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if(!error)
        {
            NSNumberFormatter *formatter=[[NSNumberFormatter alloc]init];
            int pageIndex=  [[formatter numberFromString:[NSString stringWithFormat:@"%@",response] ]intValue];
            NSLog(@"pageIndex:pageIndex=%d,webpagewidth=%f",pageIndex,webpagewidth);
            [self setPageIndex:pageIndex];
            [self setCurrentGoLR:1];
        }
    }];
    
    [self  evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if(!error){
            NSNumberFormatter *formatter=[[NSNumberFormatter alloc]init];
            float totalWidth=  [[formatter numberFromString:[NSString stringWithFormat:@"%@",response] ]floatValue];
            int webpagecount=(int)ceil(totalWidth/webpagewidth);
            NSLog(@"pageCount: totalWidth=%f,width=%f,page=%d",totalWidth,webpagewidth,webpagecount);
            [self setPageCount:webpagecount];
            if([self hasHistoryPageIndex])
            {
                [self gotoPageInCurrentSpine:[self pageIndex]];
                [self setHasHistoryPageIndex:false];
            }
        }
        
    }] ;
}
-(void) changeSplitPageWebView{
    if(_splitPage==0)//切分
    {
        // [webView  evaluateJavaScript:@"" completionHandler:nil];
        [self resetSplitWebPageIndexAndCount];
    }else{
        [self resetPageWebPageIndexAndCount];
    }
    
}
// 页面加载完毕时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
#pragma unused (webView,navigation)
    

    if(_splitPage)
    {

        NSString *insertRule1 =@"addCSSRule('html', 'font-size:16px; margin:0px; padding: 30px; ')" ;
        NSString *insertRule2 = @"addCSSRule('p', 'text-align: justify;')";
        NSString *insertRule3 = @"addCSSRule('img', 'width:auto; max-width:100%; max-height:100%; border:none;')";

        NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', ' font-weight:normal; padding:0px; margin:0px %dpx;')",60];
        [webView  evaluateJavaScript:SHEET completionHandler:nil];
        [webView  evaluateJavaScript:ADDCSSRULE completionHandler:nil];
        [webView  evaluateJavaScript:insertRule1 completionHandler:nil];
        [webView  evaluateJavaScript:insertRule2 completionHandler:nil];
        [webView  evaluateJavaScript:insertRule3 completionHandler:nil];
        [webView  evaluateJavaScript:setTextSizeRule completionHandler:nil];
        if(_bookBackgroundColor)
        {
            [webView  evaluateJavaScript:_bookBackgroundColor completionHandler:nil];
        }
      [self evaluateJavaScript:@" function pageJumpPos(yOffset){ window.scroll(0,yOffset); } " completionHandler:nil];
        NSString* pageScrollFunc = [NSString stringWithFormat:@" function pageScroll(yOffset){ window.scroll(0,yOffset); } "];
        [self evaluateJavaScript: pageScrollFunc completionHandler:nil];
        NSString* pageIndexFunc = [NSString stringWithFormat:@" function pageIndex(h){return (Math.ceil(document.body.scrollTop/h));} "];
        [self evaluateJavaScript: pageIndexFunc completionHandler:nil];
        NSString* pageScrollLastFunc = [NSString stringWithFormat:@" function pageScrollLast(h){ window.scroll((document.body.scrollHeight-h),0);return (Math.ceil(document.body.scrollTop/h));} "];
        [self evaluateJavaScript: pageScrollLastFunc completionHandler:nil];
        [self resetPageWebPageIndexAndCount];

    }else
    {
        CGFloat webpagesize=self.frame.size.width-30;
        NSString *insertRule1 = [NSString stringWithFormat:@"addCSSRule('html', 'font-size:16px; margin-top:0px; margin-bottom:0px; padding-top:0px; padding-left:0px; padding-right:30px; padding-bottom:0px; height: %fpx; -webkit-column-gap:30px;  -webkit-column-width:%fpx; column-width:%fpx;  column-rule:0px outset #ff0000;')", self.frame.size.height-60,webpagesize,webpagesize];
        NSString *insertRule2 = @"addCSSRule('p', 'text-align: justify;')";
        NSString *insertRule3 = @"addCSSRule('img', 'width:auto; max-width:100%; max-height:100%; border:none;')";
        
        NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', 'font-weight:normal; margin:0px; padding-top:0px; padding-left:%dpx; padding-right:%dpx')", 30,30];
       
        [webView evaluateJavaScript:@"if (!document.querySelector('#gepubwrap'))document.body.innerHTML = '<div id=\"gepubwrap\">' + document.body.innerHTML + '</div>'; document.querySelector('#gepubwrap').style.marginLeft = '60px';document.querySelector('#gepubwrap').style.marginRight = '60px';document.querySelector('#gepubwrap').style.border = '0px solid black';" completionHandler:nil];
        [webView  evaluateJavaScript:SHEET completionHandler:nil];
        [webView  evaluateJavaScript:ADDCSSRULE completionHandler:nil];
        [webView  evaluateJavaScript:insertRule1 completionHandler:nil];
        [webView  evaluateJavaScript:insertRule2 completionHandler:nil];
        [webView  evaluateJavaScript:insertRule3 completionHandler:nil];
        [webView  evaluateJavaScript:setTextSizeRule completionHandler:nil];
        
        if(_bookBackgroundColor)
        {
            [webView  evaluateJavaScript:_bookBackgroundColor completionHandler:nil];
        }
       // NSString* pageScrollFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scroll(xOffset,0); } "];
        [self evaluateJavaScript:@" function pageJumpPos(xOffset){ window.scroll(xOffset,0); } " completionHandler:nil];
        [self evaluateJavaScript: @"function movePow(y0,y1){var x=window._MYMOVETOTIME_X;var lon=y1-y0;if(x<=100){var pos= Math.pow(x/100,1.9);var apos=parseFloat(pos).toFixed(2);apos=apos*lon;window.scroll(apos+y0,0);x=(x+5);}window._MYMOVETOTIME_X=x;if(window._MYMOVETOTIME_X>=110){window.clearInterval(window.__MYMOVETOTIME);}}" completionHandler:nil];
        [self evaluateJavaScript:@"function pageScroll(y1){window.clearInterval(window.__MYMOVETOTIME);window._MYMOVETOTIME_X=10;var y0=document.body.scrollLeft;window.__MYMOVETOTIME=window.setInterval(\"movePow(\"+y0+\",\"+y1+\")\",10);}" completionHandler:nil];
         NSString* pageIndexFunc = [NSString stringWithFormat:@" function pageIndex(w){return (Math.ceil(document.body.scrollLeft/w));} "];
        [self evaluateJavaScript: pageIndexFunc completionHandler:nil];
        NSString* pageScrollLastFunc = [NSString stringWithFormat:@" function pageScrollLast(w){ if(document.body.scrollWidth>w){window.scroll((document.body.scrollWidth-w),0);}return (Math.ceil(document.body.scrollLeft/w));} "];
        [self evaluateJavaScript: pageScrollLastFunc completionHandler:nil];
        [self resetSplitWebPageIndexAndCount];
        
    }
   
//    [self setSplitPage:_splitPage];
    [self setPaginating:YES];
    NSLog(@"页面加载完毕时调用");
    
    
}


//跳转失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
#pragma unused (webView,navigation,error)
    NSLog(@"跳转失败时调用，%@,%@\n",[error localizedDescription],[error userInfo]);
    
    [self setPaginating:YES];
}


- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask
{
#pragma unused (webView,urlSchemeTask)
    //  NSLog(@"startURLSchemeTask调用");
    NSURLRequest *request=[urlSchemeTask request];
    NSURL *URL =[request URL];
    NSString *scheme = [URL scheme];
    NSString *resPath=[URL absoluteString] ;
    NSString *relativePath=[URL relativePath];
    NSLog(@"[urlscheme]relativePath=%@,resPath=%@,scheme=%@",relativePath,resPath,scheme);
    BookChapter * bookChapter=nil;
    if([resPath isEqualToString:@"ebook://"])
    {
        //NSLog(@"html ebook:scheme=%@,url=%@,resPath=%@\n ",scheme,[URL absoluteString],resPath);
        //        bookChapter= [bookRead jumpChapter:bookDoc chapterIndex:(size_t)[bookDoc chapterIndex]];
        if(_bookRead)
        {
            bookChapter=[_bookRead chapter:_chapterIndex];
        }
        
    }else
    {
        if(relativePath!=nil && [relativePath hasPrefix:@"/"]){
            NSString *book_resPath=[relativePath substringFromIndex:1];
            if(_bookRead)
            {
                bookChapter=[_bookRead resource:book_resPath];
            }
        }else{
        NSString *book_resPath=[resPath substringFromIndex:8]; 
        if(_bookRead)
        {
            bookChapter=[_bookRead resource:book_resPath];
        }
        }
    }
    
    if(bookChapter!=nil && [bookChapter data] !=nil)
    {
        NSData *cssData=[bookChapter data];
        //NSData *cssData= [@"<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?><html><body>hello</body></html>" dataUsingEncoding:NSUTF8StringEncoding];
        // NSLog(@"cssData:%s",[cssData bytes]);
        NSNumber *number=[[NSNumber alloc] initWithUnsignedInteger:cssData.length];
        NSInteger cssDataLen=[number integerValue];
        NSLog(@"mine=%@,length=%ld\n",[bookChapter mime],cssDataLen);
        NSURL *reqUrl=[NSURL URLWithString:@"ebook://"];
        NSURLResponse * resp= [[NSURLResponse alloc] initWithURL:reqUrl MIMEType:[bookChapter mime] expectedContentLength:cssDataLen textEncodingName:nil];
        [urlSchemeTask didReceiveResponse:resp];
        [urlSchemeTask didReceiveData:cssData];
        [urlSchemeTask didFinish];
        
    }else{
        self.paginating=true;
    }
}
/*
//URLDeleteHander start
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask
{
#pragma unused (webView,urlSchemeTask)
    //  NSLog(@"startURLSchemeTask调用");
    NSURLRequest *request=[urlSchemeTask request];
    NSURL *URL =[request URL];
    NSString *scheme = [URL scheme];
    NSString *resPath=[URL absoluteString] ;
    NSString *relativePath=[URL relativePath];
     NSLog(@"[urlscheme]relativePath=%@,resPath=%@,scheme=%@",relativePath,resPath,scheme);
    BookChapter * bookChapter=nil;
    if([resPath isEqualToString:@"ebook://"])
    {
        //NSLog(@"html ebook:scheme=%@,url=%@,resPath=%@\n ",scheme,[URL absoluteString],resPath);
        //        bookChapter= [bookRead jumpChapter:bookDoc chapterIndex:(size_t)[bookDoc chapterIndex]];
        if(_bookRead)
        {
            bookChapter=[_bookRead chapter:_chapterIndex];
        }
        
    }else if( relativePath!=nil && ([relativePath hasPrefix:@"/resource"] ||  [relativePath hasPrefix:@"/flow"]))
    {
        NSString *book_resPath=[relativePath substringFromIndex:1];
        //        bookChapter= [bookRead readResource:bookDoc resPath:book_resPath];
        if(_bookRead)
        {
            bookChapter=[_bookRead resource:book_resPath];
        }
        
    }else  if( [resPath hasPrefix:@"ebook://flow"]  )
    {
        // NSLog(@"flow ebook://flow,resPath=%@,relativePath=%@",resPath,relativePath);
        // NSString *book_resPath=[resPath substringFromIndex:28];
        NSString *book_resPath=[resPath substringFromIndex:8];
         NSLog(@"resPath=%@,book_resPath=%@",resPath,book_resPath);
        //        bookChapter= [bookRead readResource:bookDoc resPath:book_resPath];
        if(_bookRead)
        {
            bookChapter=[_bookRead resource:book_resPath];
        }
        
    }else if([resPath hasPrefix:@"ebook://resource"]  ){
        //NSLog(@"resource ebook://resource,resPath=%@",resPath);
        //NSLog(@"startURLSchemeTask 找不到处理方式:scheme=%@,url=%@,path=%@\n ",scheme,[URL absoluteString],[URL relativePath]);
        NSString *book_resPath=[resPath substringFromIndex:8];
         NSLog(@"resPath=%@,book_resPath=%@",resPath,book_resPath);
        //        bookChapter= [bookRead readResource:bookDoc resPath:book_resPath];
        if(_bookRead)
        {
            bookChapter=[_bookRead resource:book_resPath];
        }
        
    }else if([resPath hasPrefix:@"ebook://part"] ){
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        
        size_t part_id= [[formatter numberFromString:[resPath substringWithRange:NSMakeRange(12,5)]] unsignedLongValue];
        if(part_id < _chapterCount)
        {
            _chapterIndex=part_id;
//            _currentGoLR=1;
            //            [bookDoc setChapterIndex:part_id];
        }
        //        bookChapter= [bookRead jumpChapter:bookDoc chapterIndex:(size_t)part_id];
        if(_bookRead)
        {
            bookChapter=[_bookRead chapter:_chapterIndex];
        }
    } else{
        // NSLog(@"找不到加载内容,resPath=%@",resPath);
        //        bookChapter= [bookRead jumpChapter:bookDoc chapterIndex:(size_t)[bookDoc chapterIndex]];
        if(_bookRead)
        {
            bookChapter=[_bookRead chapter:_chapterIndex];
        }
    }
    
    if(bookChapter!=nil && [bookChapter data] !=nil)
    {
       NSData *cssData=[bookChapter data];
         //NSData *cssData= [@"<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?><html><body>hello</body></html>" dataUsingEncoding:NSUTF8StringEncoding];
       // NSLog(@"cssData:%s",[cssData bytes]);
        NSNumber *number=[[NSNumber alloc] initWithUnsignedInteger:cssData.length];
        NSInteger cssDataLen=[number integerValue];
          NSLog(@"mine=%@,length=%ld\n",[bookChapter mime],cssDataLen);
        NSURL *reqUrl=[NSURL URLWithString:@"ebook://"];
        NSURLResponse * resp= [[NSURLResponse alloc] initWithURL:reqUrl MIMEType:[bookChapter mime] expectedContentLength:cssDataLen textEncodingName:nil];
        [urlSchemeTask didReceiveResponse:resp];
        [urlSchemeTask didReceiveData:cssData];
        [urlSchemeTask didFinish];
        
    }else{
        self.paginating=true;
    }
}
 */

- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask
{
#pragma unused (webView,urlSchemeTask)
    NSLog(@"stopURLSchemeTask调用");
    
    urlSchemeTask = nil;
}




- (void) gotoPageInCurrentSpine:(int)index{
    //不分页条件下，上一个章节最后一页
    if(index == -1){
        index = _pageCount-1;
        _pageIndex = index;
    }
    
    if(index>=_pageCount){
        index = _pageCount - 1;
       _pageIndex = _pageCount - 1;
    }
    
    double pageOffset = index * self.bounds.size.width;
    
   // NSString* goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scroll(xOffset,0); } "];
    if(_hasHistoryPageIndex)
    {
         NSString* goTo =[NSString stringWithFormat:@"pageJumpPos(%f)", pageOffset];
        [self evaluateJavaScript:goTo completionHandler:nil];
        
    }else{
    NSString* goTo =[NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
    
//    [self evaluateJavaScript: goToOffsetFunc completionHandler:nil];
    [self evaluateJavaScript:goTo completionHandler:nil];
    }
    
}

- (void) gotoNextSpine {
    if([self paginating])
    {
        _currentGoLR=1;
        if(_splitPage==0  &&  (_pageIndex+1)< _pageCount){
            _pageIndex+=1;
            [self gotoPageInCurrentSpine:self.pageIndex];
        }else{
//            self.pageIndex=0;
            [self gotoNextPage];

        }
    }
    
}

- (void) gotoPrevSpine {
    if([self paginating])
    {
        if(_splitPage==0 && _pageIndex>=1 ){
            _pageIndex-=1;
            [self gotoPageInCurrentSpine:_pageIndex];
            
        }else{
            _currentGoLR=-1;
            [self gotoPrevPage];
        }
    }
    
}
- (void) gotoNextPage {
    if(_chapterIndex+1 < _chapterCount)
    {
        _chapterIndex+=1;
        NSURL *url=[NSURL URLWithString:@"ebook://"];
        [self loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
    
}

- (void) gotoPrevPage {
    if(_chapterIndex>0)
    {
        _chapterIndex-=1;
        NSURL *url=[NSURL URLWithString:@"ebook://"];
        [self loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
}

-(void) pageColorIndex:(NSInteger ) index{
        _pageColor=index;
        if(_pageColor==0)
        {
            _bookBackgroundColor=BOOK_BACKGROUND_0;
        }else if(_pageColor==1)
        {
            _bookBackgroundColor=BOOK_BACKGROUND_1;
    
        }else if(_pageColor==2)
        {
            _bookBackgroundColor=BOOK_BACKGROUND_2;
        }
        else if(_pageColor==3)
        {
            _bookBackgroundColor=BOOK_BACKGROUND_3;
        }
    [self  evaluateJavaScript:_bookBackgroundColor completionHandler:nil];
}

-(void)setSplitPage:(int)index{
     [self changeSplitPageWebView];
    _splitPage=index;
    _hasHistoryPageIndex=true;
    [self reload];
 
}
-(int)splitPage{
    return _splitPage;
}

- (BOOL)webView:(WebView *)webView shouldInsertText:(NSString *)text replacingDOMRange:(DOMRange *)range givenAction:(WebViewInsertAction)action
{
    #pragma unused (webView,action,range,text)
    //if ([self shiftKeyIsDown]) {
        NSString *string = [NSString stringWithFormat:@"Big-%@", text];
        [webView replaceSelectionWithText:string];
        DOMRange *ranges = [webView selectedDOMRange];
        [ranges collapse:NO];
        [webView setSelectedDOMRange:ranges affinity:NSSelectionAffinityUpstream];
        return NO;
    //}
//    return YES;
}
/*
- (void)mouseDragged:(NSEvent *)event{
    
     #pragma unused (event)
    NSLog(@"mouseDragged:%@",event);
}*/


- (void)scrollWheel:(NSEvent *)event{
#pragma unused (event)
   // NSLog(@"scrollWheel:%@",event);
//     NSLog(@"scrollingDeltaX=%f,scrollingDeltaY=%f,event=%@",event.scrollingDeltaX,event.scrollingDeltaY,event);
//    if(event.phase == NSEventPhaseChanged)
//    {
//        if(event.scrollingDeltaX>50)
//        {
//            _scrollWhellGoLR=1;
//        }else if(event.scrollingDeltaX<-50)
//        {
//            _scrollWhellGoLR=-1;
//        }
//    }
//    if(event.phase==NSEventPhaseEnded)
//    {
//        if(_scrollWhellGoLR==1)
//        {
//             if(_splitPage==0)
//             {
//              [self gotoNextSpine];
//             }else{
//                  [self gotoNextPage];
//             }
//        }else if(_scrollWhellGoLR==-1)
//        {
//            if(_splitPage==0)
//            {
//                [self gotoPrevSpine];
//            }else{
//                 [self gotoPrevPage];
//            }
//        }
//        _scrollWhellGoLR=0;
//    }
 
     [super scrollWheel:event];
//    else if(NSEventPhaseEnded==event.momentumPhase)
//    {
//        if(_currentGoLR>0)
//        {
//        [self gotoNextSpine];
//        }else{
//            [self gotoPrevSpine];
//        }
//    }
}

- (void)handlePanGesture:(NSPanGestureRecognizer *)gestureRecognizer {
    NSPoint delta = [gestureRecognizer translationInView:self];
    NSPoint endPoint = [gestureRecognizer locationInView:self];
    NSPoint startPoint = NSMakePoint(endPoint.x - delta.x, endPoint.y - delta.y);
    
//    NSEventModifierFlags flags = [NSApp currentEvent].modifierFlags;
    if (gestureRecognizer.state == NSGestureRecognizerStateBegan) {
        
    }else if (gestureRecognizer.state == NSGestureRecognizerStateEnded) {
        double absX= fabs(delta.x);
        double absY=fabs(delta.y);
        if(absX>absY)//水平拖动
        {
            if(delta.x<0)//向左拖动
            {
                if(_splitPage==0)
                 {
                     [self gotoNextSpine];
                 }else{
                      [self gotoNextPage];
                 }
            }else{//向右拖动
                if(_splitPage==0)
                {
                    [self gotoPrevSpine];
                }else{
                     [self gotoPrevPage];
                }
            }
        }else{//垂直拖动
        }
        NSLog(@"delta=(%f,%f),endPoint=(%f,%f),startPoint=(%f,%f)",delta.x,delta.y,endPoint.x,endPoint.y,startPoint.x,startPoint.y);
    }
}
@end
