//
//  BookNavOutlineView.h
//  mobi
//
//  Created by ljc on 2018/10/20.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef BookNavOutlineView_h
#define BookNavOutlineView_h

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "BookInfoTableView.h"
#import "BookDatabase.h"
#import "Book-nav.h"

@interface BookNavOutlineView :NSOutlineView<NSOutlineViewDelegate,NSOutlineViewDataSource>


-(void)defaultConfig:(WKWebView *)webView bookNav:(BookNav *)nav;


@end

#endif /* BookNavOutlineView_h */
