//
//  BookMarkOutlineView.h
//  mobi
//
//  Created by ljc on 2018/10/20.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef BookMarkOutlineView_h
#define BookMarkOutlineView_h

#import <Cocoa/Cocoa.h>
#import "BookInfoTableView.h"
#import "BookDatabase.h"

@interface BookMarkOutlineView :NSOutlineView<NSOutlineViewDelegate,NSOutlineViewDataSource>


-(void)defaultConfig:(BookInfoTableView *)tableView bookDatabase:(BookDatabase *) db;


@end

#endif /* BookMarkOutlineView_h */
