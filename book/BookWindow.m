//
//  BookWindow.m
//  book
//
//  Created by ljc on 2018/10/12.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BookWindow.h"

#import "mobi.h"
#import "BookRead.h"
#import "Book-nav.h"
#import "BookDatabase.h"
#import "BookReadView.h"

//static int MAXBOOKWINDOW=1000;
@implementation BookWindow
{
    NSString * _bookFilePath;
    BookRead *_bookRead;
//    int _pagesInCurrentSpineCount;
//    int _currentPageInSpineIndex;
    int _splitPage;
    int _showMenu;
    NSTimeInterval keydownEventTimeInter;
    
    //WebView *webView;
    
    BookReadView *bookWebView;
    BookNav * rootBookNav;
    BookInfo * _bookInfo;
    bool _hasInitBookMenu;
    NSModalSession _session;
    int _pageColor;
    /** 总章数 */
    size_t _chapterCount;
    /** 当前第几章 */
    size_t _chapterIndex;
    /** 当前章节总页数 */
    int _pageCount;
    /** 当前章节当前第几页 */
    int _pageIndex;
    
}


- (void)selectBookViewMode:(NSUInteger)newMode
{
     NSLog(@"%zu",newMode);
}




-(instancetype)initWithBookFile:(NSString *)filePath
{
    self=[super initWithWindowNibName:@"BookWindow"];
    if(self){
        _bookFilePath=filePath;
         _chapterCount=0;
         _chapterIndex=0;
         _pageCount=0;
        _pageIndex=0;
        bookWebView=nil;
        _hasInitBookMenu=false;
        
        _splitPage=true;
        _showMenu=0;
        keydownEventTimeInter=0.0f;
//        _bookBackgroundColor= BOOK_BACKGROUND_0;
        _pageColor=0;
    
    }
   

    return self;
}

-(instancetype)initWithConfig:(BookInfo *)bookInfo  config:(NSDictionary *)config{
    self= [self initWithBookFile:[bookInfo bookSrc]];
    _bookInfo=bookInfo;
    NSInteger bookChapterIndex=0;
 
    if(config)
    {
        if([config objectForKey:@"chapterIndex"])
        {
             bookChapterIndex=[[NSString stringWithFormat:@"%@", [config objectForKey:@"chapterIndex"]] intValue];
             _chapterIndex=(size_t)bookChapterIndex;
        }
        if([config objectForKey:@"pageIndex"])
        {
            _pageIndex=[[NSString stringWithFormat:@"%@", [config objectForKey:@"pageIndex"]] intValue];
            
        }
        if([config objectForKey:@"showMenu"])
        {
            _showMenu=[[NSString stringWithFormat:@"%@", [config objectForKey:@"showMenu"]] intValue];
            
        }
        if([config objectForKey:@"splitPage"])
        {
            _splitPage=[[NSString stringWithFormat:@"%@", [config objectForKey:@"splitPage"]] intValue];
            
        }
        if([config objectForKey:@"pageColor"])
        {
            _pageColor=[[NSString stringWithFormat:@"%@", [config objectForKey:@"pageColor"]] intValue];
            
             [self loadPageColor];
        }
      
    }
   
   
    return self;
    
}



- (void)custonBookWindow {
    
    
//    NSArray *subviews = _mainWindow.contentView.superview.subviews;
//    for (NSView *view in subviews) {
//        if ([view isKindOfClass:NSClassFromString(@"NSTitlebarContainerView")]) {
//            [view removeFromSuperview];
//        }
//    }
    //设置为点击背景可以移动窗口
//        [_mainWindow setMovableByWindowBackground:YES];
        //titleBar和 contentView 融合到一起
        _mainWindow.styleMask = _mainWindow.styleMask | NSWindowStyleMaskFullSizeContentView;
//        _mainWindow.titlebarAppearsTransparent = YES;
    [_mainWindow setTitleVisibility:NSWindowTitleHidden];
    
//    [_mainToolbar setVisible:FALSE];
    [_bookTitleLabel setSelectable:FALSE];
    [_bookTitleLabel setEditable:FALSE];
    [_bookTitleLabel setEnabled:FALSE];
    
    
//    NSToolbar *toolBar=[[NSToolbar alloc] init];
//    [_mainWindow setToolbar:toolBar];
//    NSView *msTitleBar = [[NSView alloc]initWithFrame:NSMakeRect(0, _mainWindow.frame.size.height-50, _mainWindow.frame.size.width, 30)];
//    msTitleBar.wantsLayer = YES; //需要先设置这个，再设置颜色，否则颜色无效
//    msTitleBar.layer.backgroundColor = [NSColor redColor].CGColor;
//    [_mainWindow.contentView addSubview:msTitleBar];
    
    
    
//        [NSAnimationContext beginGrouping];
//        [[NSAnimationContext currentContext] setDuration:10.0];
//        [[_mainWindow animator] setAlphaValue:0.9];
//
//        [NSAnimationContext endGrouping];
}

-(NSRect) defaultWindowFrame{
      NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
    return  NSMakeRect(60, 100, screenVisibleFrame.size.width-120, screenVisibleFrame.size.height-10);
}
 
- (void)windowDidLoad {
    [super windowDidLoad];
     [self custonBookWindow ];
    [ _mainSplitView.arrangedSubviews.firstObject setHidden:YES];
 
   
//    [NSAnimationContext beginGrouping];
//    [[NSAnimationContext currentContext] setDuration:0.6];
     NSRect frame =[self defaultWindowFrame ];
    [[_mainWindow animator] setFrame:frame display:FALSE];
    
//    [[_mainWindow animator] convertRectToScreen:frame];
   // [[[_mainWindow contentView]  animator] setFrameSize:NSMakeSize(1200, 700)];
//    [[_mainWindow animator] setAlphaValue:1.0f];
//    [NSAnimationContext endGrouping];
    
    self.mainSplitView.delegate=self;
    [self loadBookWebView];
    
    [self loadBookMenu];
    
    
 //   [self loadBookByFile:bookFilePath];
  
  
    [_mainToolbar setAllowsUserCustomization:NO];
    [_mainToolbar setAutosavesConfiguration:NO];
    [_mainToolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
    [_mainToolbar setSizeMode:NSToolbarSizeModeSmall];
   
    //  _mainWindow.delegate=self;
    //启动模态窗口
    _session=[NSApp beginModalSessionForWindow:_mainWindow];
    
//    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * _Nullable(NSEvent * _Nonnull aEvent) {
//        if(aEvent.window ==self.mainWindow)
//        {
//            
//            if(self->keydownEventTimeInter != aEvent.timestamp)
//            {
//                self->keydownEventTimeInter=aEvent.timestamp;
//                [self keyDown:aEvent];
//            }
//        }
//        return aEvent;
//    }];
//    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskFlagsChanged handler:^NSEvent * _Nullable(NSEvent * _Nonnull aEvent) {
//        [self flagsChanged:aEvent];
//        return aEvent;
//    }];
    [_mainWindow setBookWindow:self];
    
    //窗口大小变更时
    [[NSNotificationCenter defaultCenter] addObserver:_mainWindow
                                             selector:@selector(windowDidResize:)
                                                 name:NSWindowDidResizeNotification
                                               object:self];

   //[ _bookSegmentedContrl setAction:@selector(segmentAction:)];
    [_bookColorSegmentedContrl setAction:@selector(colorSegmentAction:)];
     [_bookColorSegmentedContrl setSelectedSegment:_pageColor];
    [_bookMenuSegmentedContrl setAction:@selector(menuSegmentAction:)];
   // [_bookSegmentedContrl setSelectedSegment:(_splitPage)];
//    if(_showMenu==1)
//    {
//        [_bookMenuSegmentedContrl setSelectedSegment:0];
//    }
//    if(_splitPage==1)
//    {
//        [_bookMenuSegmentedContrl setSelectedSegment:1];
//    }
    
    
    if(_showMenu==1)
    {
        
        [_bookMenuSegmentedContrl setSelected:true forSegment:0];
    }
    if(_splitPage==1)
    {
        [_bookMenuSegmentedContrl setSelected:true forSegment:1];
    }
    
  //  [_bookMenuToolbarItem setAction:@selector(menuToolbarItemAction:)];
//    NSImage *img=[NSImage imageNamed:@"NSListViewTemplate"];
//    [ img setResizingMode:NSImageResizingModeStretch];
//    _bookMenuToolbarItem.image=img;
 
   // [_bookMenuToolbarItem.image set setSize:NSMakeSize(10, 10)];
    
}

//-(void)menuToolbarItemAction:(id)sender
//{
//    #pragma unused(sender)
//
////    NSInteger selectedIndex=  [_bookMenuSegmentedContrl selectedSegment];
//    _showMenu=(_showMenu==0?1:0);
//    if(_showMenu==0)
//    {
//        [_mainSplitView setPosition:[_mainSplitView minPossiblePositionOfDividerAtIndex:0] ofDividerAtIndex:0];
//        //[_bookMenuToolbarItem setToolTip:@"显示目录"];
////        _showMenu=0;
//    }else{
////        [NSAnimationContext beginGrouping];
////        [[NSAnimationContext currentContext] setDuration:1.0f];
//        [_mainSplitView  setPosition:200 ofDividerAtIndex:0];
////        [NSAnimationContext endGrouping];
//          // [_bookMenuToolbarItem setToolTip:@"隐藏目录"];
//        _showMenu=1;
//    }
//
//}

//- (void)segmentAction:(id)sender
//{
//#pragma unused(sender)
//
//  NSInteger selectedIndex=  [_bookSegmentedContrl selectedSegment];
//
//        _splitPage=(int)selectedIndex;
//        [bookWebView setSplitPage:_splitPage];
//
////        [bookWebView reload];
//
//}
-(void) loadPageColor{
 
    [_bookColorSegmentedContrl setSelectedSegment:_pageColor];
    [bookWebView pageColorIndex:_pageColor];
    
}

-(void)colorSegmentAction:(id)sender
{
    #pragma unused(sender)
     NSInteger selectedIndex=  [_bookColorSegmentedContrl selectedSegment];
   // NSLog(@"%zu",selectedIndex);
    if(selectedIndex==0)
    {
        
        _pageColor=0;
    }else if(selectedIndex==1)
    {
        
        _pageColor=1;

    }else if(selectedIndex==2)
    {
        
        _pageColor=2;
    }
    else if(selectedIndex==3)
    {
        
        _pageColor=3;
    }
    [bookWebView  pageColorIndex:selectedIndex];
    
}

-(void) menuSegmentAction:(id)sender
{
      #pragma unused(sender)
//     NSInteger selectedIndex=  [_bookMenuSegmentedContrl selectedSegment];
   // _showMenu=( [_bookMenuSegmentedContrl isSelectedForSegment:0]?1:0);
    if([_bookMenuSegmentedContrl isSelectedForSegment:0])
    {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:1.0f];
        [_mainSplitView  setPosition:200 ofDividerAtIndex:0];
        [NSAnimationContext endGrouping];
        _showMenu=1;
        [_bookMenuSegmentedContrl setSelected:true forSegment:0];
        
    }else{
        [_mainSplitView setPosition:[_mainSplitView minPossiblePositionOfDividerAtIndex:0] ofDividerAtIndex:0];
        [_bookMenuSegmentedContrl setSelected:false forSegment:0];
        _showMenu=0;
    }
    if([_bookMenuSegmentedContrl isSelectedForSegment:1])
    {
        _splitPage=1;
        [bookWebView setSplitPage:_splitPage];
    }else{
        _splitPage=0;
        [bookWebView setSplitPage:_splitPage];
    }
    
    
}

-(void) splitPageViewsegmentAction{
    
   // int selectSplitPage=[_bookMenuSegmentedContrl isSelectedForSegment:1]?1:0;
    if(_splitPage==1)
    {
        //_splitPage=1;
       // [bookWebView setSplitPage:_splitPage];
        [_bookMenuSegmentedContrl setSelected:true forSegment:1];
    }else{
//        _splitPage=0;
        [_bookMenuSegmentedContrl setSelected:false forSegment:1];
    }
    
     [bookWebView setSplitPage:_splitPage];
    
   
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


- (BOOL)canBecomeKeyWindow {
    
    return YES;
}

- (BOOL)canBecomeMainWindow {
    
    return YES;
}


-(void) loadBookWebView{
    
    if(!bookWebView && _bookFilePath!=nil)
    {
        if(!_bookRead)
        {
            _bookRead=[[BookRead alloc] initWithPath:_bookFilePath];
            //开始初始化webView
            NSRect maxRect=_mainSplitView.arrangedSubviews.lastObject.frame;
            NSRect webViewRect=CGRectMake(0,0,maxRect.size.width,maxRect.size.height);
            
//            WKWebViewConfiguration *bookWebViewConfig=[[WKWebViewConfiguration alloc] init];
//            [bookWebViewConfig setURLSchemeHandler:self forURLScheme:@"ebook"];
//            [[bookWebViewConfig preferences] setMinimumFontSize: 10.00];
//            if(_showMenu)
//            {
//                NSRect endRect=[self defaultWindowFrame ];
//                webViewRect=CGRectMake(0,0,endRect.size.width-200,endRect.size.height);
//            }else{
//                NSRect endRect=[self defaultWindowFrame ];
//                webViewRect=CGRectMake(0,0,endRect.size.width,endRect.size.height);
//            }
            bookWebView=[[BookReadView alloc]initWithFrame:webViewRect];
            [bookWebView loadBookRead:_bookRead pageIndex:_pageIndex chapterIndex:_chapterIndex pageColor:_pageColor splitPage:_splitPage];
            [bookWebView bookToolBar:_mainWindow toolbar: _mainToolbar];
            
            [_mainSplitView.arrangedSubviews.lastObject addSubview:bookWebView];
//            [_mainWindow makeFirstResponder:bookWebView];//注册第一个事件响应View
            
            //默认加载第一章
            
            //[[_mainWindow setTitle:[_bookRead title]];
             _bookTitleLabel.stringValue=[NSString stringWithFormat:@"%@ - %@",[_bookRead title],[_bookRead author]];
            
           
            if(_showMenu==0)
            {
                
                 [_mainSplitView setPosition:0 ofDividerAtIndex:0];
            }
             [_mainSplitView setHidden:FALSE];
        }
    }
    _pageCount=1;
   
    
}

-(void) loadBookMenu{
    
    if(!_hasInitBookMenu )
    {
        _hasInitBookMenu=true;
        if(_bookRead)
        {
            rootBookNav=[_bookRead bookNav];
        }
        [self.menuOutlineView defaultConfig:bookWebView bookNav:rootBookNav];
//        self.menuOutlineView.dataSource=self;
//        self.menuOutlineView.delegate=self;
       
    // [self.window.contentView setAutoresizesSubviews:TRUE ];
    
    //=====toolbar
    //self.window.styleMask = self.window.styleMask | NSWindowStyleMaskFullSizeContentView;
    //  self.window.titlebarAppearsTransparent=YES;
    //    self.window.titleVisibility = NSWindowTitleHidden;
    
//        [_menuOutlineView sizeLastColumnToFit];
//        [_menuOutlineView setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    
    // Expand all the root items; disable the expansion animation that normally happens
    
//        [NSAnimationContext beginGrouping];
//        [[NSAnimationContext currentContext] setDuration:2.0f];
//        [_menuOutlineView expandItem:nil expandChildren:YES];
    //    [[self.mainView animator]  addSubview:bookWebView];
//        [NSAnimationContext endGrouping];
        if(_showMenu==0)
        {
            [_mainSplitView setPosition:0 ofDividerAtIndex:0];
           // [_mainSplitView.arrangedSubviews.firstObject setHidden:TRUE];
            
        }else{
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:1.0f];
            [_mainSplitView  setPosition:200 ofDividerAtIndex:0];
            [NSAnimationContext endGrouping];
            
        }
    }
    
}

- (NSString *)windowNibName {
    return @"BookWindow";
}



#pragma mark NSSplitView delegate/datasource methods
- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
#pragma unused (oldSize)
//    CGFloat oldWidth = splitView.arrangedSubviews.firstObject.frame.size.width;
    [splitView adjustSubviews];
//    [splitView setPosition:oldWidth ofDividerAtIndex:0];
    if(_showMenu==0)
    {
        [splitView setPosition:0.0f ofDividerAtIndex:0];
    }else{
        [splitView setPosition:200.0f ofDividerAtIndex:0];
    }
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
#pragma unused (splitView,dividerIndex,proposedMinimumPosition)
    return 0;
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    
    NSString  *characters = [theEvent charactersIgnoringModifiers];
    NSLog(@"=== 快捷键：%@",characters);
    if ([characters isEqual:@"k"]) { //
         [bookWebView gotoPrevSpine];
        return YES;
    }
    if ([characters isEqual:@"j"]) {
       [bookWebView gotoNextSpine];
        return YES;
    }
    if ([characters isEqual:@"1"]) {
      
        if([_bookMenuSegmentedContrl isSelectedForSegment:0])
        {
            [_bookMenuSegmentedContrl setSelected:false forSegment:0];
        }else{
            [_bookMenuSegmentedContrl setSelected:true forSegment:0];
        }
        [self menuSegmentAction:nil];
        
        return YES;
    }
    if ([characters isEqual:@"2"]) {
        
        if([_bookMenuSegmentedContrl isSelectedForSegment:1])
        {
            [_bookMenuSegmentedContrl setSelected:false forSegment:1];
        }else{
            [_bookMenuSegmentedContrl setSelected:true forSegment:1];
        }
        [self menuSegmentAction:nil];
        
        return YES;
    }
    if([characters isEqual:@"3"])
    {
        [_bookColorSegmentedContrl setSelectedSegment:0];
        [self colorSegmentAction:nil];
        return YES;
    }
    if([characters isEqual:@"4"])
    {
        [_bookColorSegmentedContrl setSelectedSegment:1];
        [self colorSegmentAction:nil];
          return YES;
    }
    if([characters isEqual:@"5"])
    {
        [_bookColorSegmentedContrl setSelectedSegment:2];
        [self colorSegmentAction:nil];
          return YES;
    }
    if([characters isEqual:@"6"])
    {
        [_bookColorSegmentedContrl setSelectedSegment:3];
        [self colorSegmentAction:nil];
          return YES;
    }
    [super performKeyEquivalent:theEvent];
    return YES;
}


-(void)keyDown:(NSEvent *)event{
    //NSLog(@"key:%hu",event.keyCode);
    
    switch (event.keyCode) {
        case 123:
        case 40:
        {
            [bookWebView gotoPrevSpine];
            return;
        }
            break;
        case 124:
        case 38:
        case 49:
        {
            [bookWebView gotoNextSpine];
            return;
        }
            
            break;
        case 18:
        {
            
//            if(_showMenu>0)
//            {
//               // [_mainSplitView setPosition:0 ofDividerAtIndex:0];
//
//                _showMenu=0;
//            }else{
////                [NSAnimationContext beginGrouping];
////                [[NSAnimationContext currentContext] setDuration:1.0f];
////                [_mainSplitView  setPosition:200 ofDividerAtIndex:0];
////                [NSAnimationContext endGrouping];
//                _showMenu=1;
//            }
            if([_bookMenuSegmentedContrl isSelectedForSegment:0])
            {
                [_bookMenuSegmentedContrl setSelected:false forSegment:0];
            }else{
                [_bookMenuSegmentedContrl setSelected:true forSegment:0];
            }
            [self menuSegmentAction:nil];
              return;
            
        }
            break;
        case 19:
        {
            if([_bookMenuSegmentedContrl isSelectedForSegment:1])
            {
                [_bookMenuSegmentedContrl setSelected:false forSegment:1];
            }else{
                [_bookMenuSegmentedContrl setSelected:true forSegment:1];
            }
             [self menuSegmentAction:nil];
            //_splitPage=(_splitPage==1)?0:1;
//            [bookWebView setSplitPage:_splitPage];
//            if(_splitPage==1)
//            {
//                [_bookMenuSegmentedContrl setSelected:true forSegment:1];
//
//            }else{
//                 [_bookMenuSegmentedContrl setSelected:false forSegment:1];
//            }
            
            //[self splitPageViewsegmentAction];
            return;
        }
            break;
        case 20:{
            [_bookColorSegmentedContrl setSelectedSegment:0];
            [self colorSegmentAction:nil];
            return;
        }break;
        case 21:{
            [_bookColorSegmentedContrl setSelectedSegment:1];
            [self colorSegmentAction:nil];
            return;
        }break;
        case 23:{
            [_bookColorSegmentedContrl setSelectedSegment:2];
            [self colorSegmentAction:nil];
            return;
        }break;
        case 22:{
           [_bookColorSegmentedContrl setSelectedSegment:3];
            [self colorSegmentAction:nil];
            return;
        } break;
            
        default:
            break;
    }
    [super keyDown:event];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
    #pragma unused (application)
    return YES;
    
}
- (void)windowWillClose:(NSNotification *)notification
{
    #pragma unused (notification)
    NSWindow *window = notification.object;
//    if(window == self.window) {
       // [NSApp terminate:self];
        // [[NSApplication sharedApplication] terminate:nil];  //或这句也行
//    }
    if(window == _mainWindow) {
//        NSLog(@"关闭阅读;bookId=%@,chapterIndex=%zu,pageIndex=%d",[_bookRead bookId],[self chapterIndex],[self pageIndex]);
        NSString *mark=[NSString stringWithFormat:@"{\"chapterIndex\":%zu,\"pageIndex\":%d,\"showMenu\":%d,\"splitPage\":%d,\"pageColor\":%d}",[bookWebView chapterIndex],[bookWebView pageIndex],_showMenu,_splitPage,_pageColor];
        NSLog(@"关闭阅读;%@",mark);
        BookDatabase *bookDatabase=[[BookDatabase alloc]init];
        [bookDatabase saveBook:[_bookRead bookId] mark:mark];
        if(_bookInfo)
        {
            [_bookInfo setBookMark:mark];
        }
        [NSApp endModalSession:_session];
    }
}
 

-(void) dealloc{
    
//    [bookRead destoryBook:bookDoc];
   // NSLog(@"关闭阅读;bookId=%@,chapterIndex=%zu,pageIndex=%d",[_bookRead bookId],[self chapterIndex],[self pageIndex]);
    _bookRead=nil;
    //[super dealloc];
}

@end
