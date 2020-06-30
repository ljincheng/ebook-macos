//
//  BookSearchField.h
//  mobi
//
//  Created by ljc on 2018/10/24.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef BookSearchField_h
#define BookSearchField_h
#import <Cocoa/Cocoa.h>
#import "BookDatabase.h"
#import "BookInfoTableView.h"

@interface BookSearchField:NSSearchField<NSSearchFieldDelegate,NSControlTextEditingDelegate>

-(void) searchConfig:(NSMutableArray *) data tableView:(BookInfoTableView *) view bookDatabase:(BookDatabase *) db;

@end


#endif /* BookSearchField_h */
