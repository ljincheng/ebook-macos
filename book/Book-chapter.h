//
//  Book-chapter.h
//  mobi
//
//  Created by ljc on 2018/9/21.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef Book_chapter_h
#define Book_chapter_h

#import <Foundation/Foundation.h>

@interface BookChapter : NSObject
@property (nonatomic, copy) NSString * mime;
@property (nonatomic, copy) NSString * url;
//@property (nonatomic, copy) NSString * html;
@property (nonatomic,copy) NSData * data;
@property (nonatomic) int spineIndex;
@end

#endif /* Book_chapter_h */
