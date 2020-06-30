//
//  Book-mark.h
//  mobi
//
//  Created by ljc on 2018/10/8.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef Book_mark_h
#define Book_mark_h
#import <Foundation/Foundation.h>

@interface BookMark : NSObject

@property (nonatomic, copy)    NSString *text;
@property (nonatomic, copy)    NSString *src;
@property (nonatomic)          int mark;
@property (nonatomic)    BookMark *parent;
@property (nonatomic)    NSMutableArray *children;
@property (assign)  BOOL    isSpecialGroup;
@property (assign)  BOOL    isDirectory;
@property (assign)  BOOL    cannotHide;


+ (BookMark *)rootItem;
- (NSInteger)numberOfChildren;            // Returns -1 for leaf nodes
- (BookMark *)childAtIndex:(NSInteger)n;    // Invalid to call on leaf nodes
-(void) parseDict:(NSDictionary *)dict;

 


@end
#endif /* Book_nav_h */

