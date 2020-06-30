//
//  BookInfoTableView.h
//  mobi
//
//  Created by ljc on 2018/10/19.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef BookInfoTableView_h
#define BookInfoTableView_h
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface BookInfoTableView:NSTableView<NSTableViewDelegate, NSTableViewDataSource>


-(void)defaultConfig;
-(void)loadBookInfo:(NSMutableArray *) data;


@end

#endif /* BookInfoTableView_h */
