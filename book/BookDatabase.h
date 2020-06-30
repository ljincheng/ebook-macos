//
//  BookDatabase.h
//  mobi
//
//  Created by ljc on 2018/10/17.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef BookDatabase_h
#define BookDatabase_h

#import <Foundation/Foundation.h>
#import "BookInfo.h"

@interface BookDatabase : NSObject

-(int) databaseCheck;
/** 根据标记获取书籍 **/
-(NSMutableArray *)queryBookList:(int)flag;

-(NSMutableArray *)queryNewsList:(int)flag;

-(NSMutableArray *) queryKey:(NSString *) keyStr;

-(void) importBook:(NSString *) fullPath;

-(NSString *) queryParam:(NSString *) paramId;

-(void) saveBook:(NSString *)bookId mark:(NSString *)mark;

@end


#endif /* BookDatabase_h */
