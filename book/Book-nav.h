//
//  Book_nav.h
//  mobi
//
//  Created by ljc on 2018/9/30.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef Book_nav_h
#define Book_nav_h

#import <Foundation/Foundation.h>

typedef struct _BookNavPoint  BookNavPoint;
struct _BookNavPoint
{
    char    *text;
    char       * pointId;
    char        *playOrder;
    char       *src;
    Boolean    hasNext;
    Boolean    hasChildren;
    BookNavPoint *children;
    BookNavPoint *next;
};

@interface BookNav : NSObject

@property (nonatomic, copy)    NSString *text;
@property (nonatomic, copy)    NSString *src;
@property (nonatomic)    int level;
@property (nonatomic)    BookNav *parent;
@property (nonatomic)    NSMutableArray *children;


+ (BookNav *)rootItem;
- (NSInteger)numberOfChildren;            // Returns -1 for leaf nodes
- (BookNav *)childAtIndex:(NSInteger)n;    // Invalid to call on leaf nodes
-(void) parseDict:(NSDictionary *)dict;

+(BookNav *) loadBookNavPoint:(BookNavPoint *) bookNavPoint;

+(void) freeBookNavPoint:(BookNavPoint *) bookNavPoint;
@end
#endif /* Book_nav_h */
