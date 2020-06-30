//
//  book-mobi.h
//  mobi
//
//  Created by ljc on 2018/9/18.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//


#ifndef Book_mobi_h
#define Book_mobi_h

#import "Book-chapter.h"
#import "Book-nav.h"

#import <Foundation/Foundation.h>

@interface BookMobi : NSObject
/** 根据书文件路径初始化 */
- (id) initWithPath:(NSString*)bookPath;
/** 总章节数 **/
-(size_t) chapterCount;
/** 书名 **/
-(NSString *) title;
/** 作者 **/
-(NSString *) author;
/**  书籍ID */
-(NSString *) bookId;

/** 获取章节 **/
-(BookChapter *) chapter:(size_t)index;
-(BookChapter *) resource:(NSString *)url;

-(BookNav *) bookNav;

 

@end

#endif /* Book_mobi_h */
