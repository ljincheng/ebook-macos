//
//  BookRead.h
//  mobi
//
//  Created by ljc on 2018/9/19.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef BookRead_h
#define BookRead_h


#import <Foundation/Foundation.h>
#import "Book-chapter.h"
#import "Book-nav.h"

@interface BookRead : NSObject

- (id) initWithPath:(NSString*)bookPath;

/** 获取章节 **/
-(BookChapter *) chapter:(size_t)index;
-(BookChapter *) resource:(NSString *) path;
-(BookNav *) bookNav;
/** 总章节数 **/
-(size_t) chapterCount;
/** 书名 **/
-(NSString *) title;
/** 作者 **/
-(NSString *) author;
/** 书籍ID */
-(NSString *) bookId;


 

@end

#endif /* BookRead_h */
