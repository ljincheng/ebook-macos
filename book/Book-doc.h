//
//  Book-doc.h
//  mobi
//
//  Created by ljc on 2018/9/18.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef Book_doc_h
#define Book_doc_h

#import <Foundation/Foundation.h>
#import "Book-chapter.h"
#import "Book-nav.h"

@interface BookDoc : NSObject

@property (nonatomic, copy) NSString * path;
@property (nonatomic, copy) NSString * bookId;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * author;
@property (nonatomic,copy) NSString *publisher;
@property (nonatomic) int type;
@property (nonatomic) int port;
@property (atomic) int chapterNum;
@property (atomic) int chapterIndex;
@property (nonatomic) void * entry;

@end
 
#endif /* Book_doc_h */
