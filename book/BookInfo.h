//
//  BookInfo.h
//  mobi
//
//  Created by ljc on 2018/10/17.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef BookInfo_h
#define BookInfo_h

#import <Foundation/Foundation.h>
@interface BookInfo : NSObject

@property (nonatomic, copy)    NSString *bookId;
@property (nonatomic, copy)    NSString *bookTitle;
@property (nonatomic, copy)    NSString *bookAuthor;
@property (nonatomic, copy)    NSString *bookSrc;
@property (nonatomic, copy)    NSString *bookMark;
@property (nonatomic, copy)    NSString *bookOpenTime;
@property (nonatomic, copy)    NSString *bookCreateTime;
@property (nonatomic)    int    bookFlag;
// 网址
@property (nonatomic, copy)    NSString *webUrl;


@end

#endif /* BookInfo_h */
