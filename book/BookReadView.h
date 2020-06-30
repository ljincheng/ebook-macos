//
//  BookReadView.h
//  mobi
//
//  Created by ljc on 2018/10/23.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef BookReadView_h
#define BookReadView_h

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "BookToolbar.h"
#import "BookRead.h"

@interface BookReadView : WKWebView<WKNavigationDelegate,WKURLSchemeHandler>{
    int _splitPage;
}

-(id)initWithFrame:(NSRect) frame ;

@property(atomic,assign) bool paginating;
//@property(atomic,assign) bool splitPage;
@property(atomic,assign) int pageCount;
@property(atomic,assign) int pageIndex;
@property(atomic,assign) size_t chapterIndex;
@property(atomic,assign) size_t chapterCount;
@property (nonatomic, strong) NSGestureRecognizer *leftSwipeGestureRecognizer;

-(void) bookToolBar:(NSWindow *) bookWindow toolbar:(BookToolbar *)toolbar;
-(void) loadBookRead:(BookRead *)book pageIndex:(int) pageindex chapterIndex:(size_t) chaptedindex pageColor:(NSInteger) colorindex splitPage:(int) splitpage;

- (void) gotoPageInCurrentSpine:(int)index;
- (void) gotoNextSpine;
- (void) gotoPrevSpine;
- (void) gotoNextPage;
- (void) gotoPrevPage;

-(void)pageColorIndex:(NSInteger ) index;

-(void)setSplitPage:(int )index;
-(int)splitPage;

@end



#endif /* BookReadView_h */
