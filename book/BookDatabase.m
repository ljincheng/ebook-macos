//
//  BookDatabase.m
//  book
//
//  Created by ljc on 2018/10/17.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookDatabase.h"
#import <sqlite3.h> 
#import "BookRead.h"

static char * DATABASEFILE="book.db";

@implementation  BookDatabase{
    NSString *_databaseFile;
}

-(NSString *) databaseFile{
    if(_databaseFile)
    {
        return _databaseFile;
    }else{
        NSFileManager *fileManager =[NSFileManager defaultManager];
        NSString *dirPath=[NSString stringWithFormat:@"%@/.book",NSHomeDirectory()];
        if(![fileManager fileExistsAtPath:dirPath])
        {
            BOOL isCreate = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:nil];
            if (isCreate) {
                NSLog( @"主目录创建成功");
                
            } else {
                NSLog( @"主目录创建失败，请检查路径");
                
            }
            
        }
        _databaseFile=[NSString stringWithFormat:@"%@/.book/%s",NSHomeDirectory(),DATABASEFILE];
        if (![fileManager fileExistsAtPath:_databaseFile]) {
            BOOL isCreate = [fileManager createFileAtPath:_databaseFile contents:nil attributes:nil];
            if (isCreate) {
                NSLog(@"数据库创建成功");
                
            } else {
                NSLog(@"数据库创建失败");
                
            }
        }
       
        
    }
    return _databaseFile;
}

-(int) exitTable:(NSString *) tableName database:(sqlite3 *)db{
    
    sqlite3_stmt *prepared_statement;
    
    if(sqlite3_prepare_v2(db, "SELECT COUNT(type) FROM sqlite_master WHERE type='table' and name=?", -1, &prepared_statement, NULL) != SQLITE_OK)
    {
        NSLog(@"数据库表是否存在获取失败:%s",sqlite3_errmsg(db));
        return FALSE;
    }
    if (sqlite3_bind_text (prepared_statement,  1, [tableName UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
        NSLog(@"数据库表是否存在设置参数失败:%s",sqlite3_errmsg(db));
        sqlite3_finalize(prepared_statement);
        return FALSE;
    }
    int error_code = sqlite3_step (prepared_statement);
    if (error_code != SQLITE_OK && error_code != SQLITE_ROW && error_code != SQLITE_DONE) {
        NSLog(@"数据库表是否存在设置参数失败:%s",sqlite3_errmsg(db));
        sqlite3_finalize(prepared_statement);
        return FALSE;
    }
    int exitTbl= sqlite3_column_int(prepared_statement,0);
    sqlite3_finalize(prepared_statement);
    return exitTbl;
}

//-(void) tableInit:(sqlite3 *)db{
//
//    if(![self exitTable:@"book_info" database:db])
//    {
//        char* errmsg;
//        int  nResult = sqlite3_exec(db,"create table book_info (id integer primary key autoincrement,title varchar(200),author varchar(100),src varchar(200))",NULL,NULL,&errmsg);
//        if (nResult != SQLITE_OK)
//        {
//            sqlite3_close(db);
//            NSLog(@"创建表失败:%s",errmsg);
//            sqlite3_free(errmsg);
//        }
//    }
//}

-(sqlite3 *) database{
    
    sqlite3 *db;
    int nResult = sqlite3_open([[self databaseFile] UTF8String],&db);
    if (nResult != SQLITE_OK)
    {
        NSLog(@"打开数据库失败:%s",sqlite3_errmsg(db));
        return nil;
    }
    return db;
}
-(int) databaseCheck{
    sqlite3 *db=[self database];
    if(db)
    {
        if(![self exitTable:@"book_info" database:db])
        {
            char* errmsg;
            int  nResult = sqlite3_exec(db,"create table book_info (id varchar(200) PRIMARY KEY,title varchar(200),author varchar(100),src varchar(200),openTime datetime,flag int,mark text,createTime datetime)",NULL,NULL,&errmsg);
            if (nResult != SQLITE_OK)
            {
                sqlite3_close(db);
                NSLog(@"创建表失败:%s",errmsg);
                sqlite3_free(errmsg);
                return FALSE;
            }
        }
        if(![self exitTable:@"book_param" database:db])
        {
            char* errmsg;
            int  nResult = sqlite3_exec(db,"create table book_param (id varchar(200) PRIMARY KEY,title varchar(200),data text)",NULL,NULL,&errmsg);
            if (nResult != SQLITE_OK)
            {
                sqlite3_close(db);
                NSLog(@"创建表失败:%s",errmsg);
                sqlite3_free(errmsg);
                return FALSE;
            }
        }
         sqlite3_close(db);
        return TRUE;
    }
    return FALSE;
}

-(NSString *) queryParam:(NSString *) paramId{
    NSString *paraData;
    sqlite3 *db=[self database];
    if(db)
    {
    char **dbResult = NULL;
    char* errmsg;
    int nRow, nColumn;
    int index;
    int i;
    //  int j;
    int nResult = sqlite3_get_table(db, [[NSString stringWithFormat:@"select data from book_param where id='%@'",paramId] UTF8String], &dbResult, &nRow,&nColumn, &errmsg);
    if (nResult == SQLITE_OK)
    {
        index = nColumn;
        printf("find %d record\n", nRow);
        
        for (i = 0; i < nRow; i++)
        {
            //BookInfo *bookInfo=[[BookInfo alloc]init];
            //                    [bookInfo setBookId:[NSString stringWithUTF8String:dbResult[index]]];
            //                    [bookInfo setBookTitle:[NSString stringWithUTF8String:dbResult[index+1]]];
            //                    [bookInfo setBookAuthor:[NSString stringWithUTF8String:dbResult[index+2]]];
            //                    [bookInfo setBookSrc:[NSString stringWithUTF8String:dbResult[index+3]]];
            //                    [bookInfo setBookOpenTime:[NSString stringWithUTF8String:dbResult[index+4]]];
            char * dataValue=dbResult[index];
          
            if(dataValue)
            {
                 paraData=[NSString stringWithUTF8String:dataValue];
                
            }
            index=index+1;
        }
    }
    }
    return paraData;
}

/** 根据标记获取书籍 **/
-(NSMutableArray *) queryBookList:(int)flag{
    NSMutableArray * bookArray = [NSMutableArray new];
    sqlite3 *db=[self database];
    if(db)
    {
        if(flag==-1)//全部
        {
            char **dbResult = NULL;
            char* errmsg;
            int nRow, nColumn;
            int index;
            int i;
            //  int j;
            int nResult = sqlite3_get_table(db, "select id,title,author,src,openTime,flag,mark,createTime from book_info order by title,openTime", &dbResult, &nRow,&nColumn, &errmsg);
            if (nResult == SQLITE_OK)
            {
                index = nColumn;
                printf("find %d record\n", nRow);
                
                for (i = 0; i < nRow; i++)
                {
                    BookInfo *bookInfo=[[BookInfo alloc]init];
                    //                    [bookInfo setBookId:[NSString stringWithUTF8String:dbResult[index]]];
                    //                    [bookInfo setBookTitle:[NSString stringWithUTF8String:dbResult[index+1]]];
                    //                    [bookInfo setBookAuthor:[NSString stringWithUTF8String:dbResult[index+2]]];
                    //                    [bookInfo setBookSrc:[NSString stringWithUTF8String:dbResult[index+3]]];
                    //                    [bookInfo setBookOpenTime:[NSString stringWithUTF8String:dbResult[index+4]]];
                    char * titleValue=dbResult[index+1];
                    char * authorValue=dbResult[index+2];
                    char * srcValue=dbResult[index+3];
                    char * openTimeValue=dbResult[index+4];
                    char * flagValue=dbResult[index+5];
                    char * markValue=dbResult[index+6];
                    char * createTime=dbResult[index+7];
                    if(srcValue)
                    {
                        [bookInfo setBookSrc:[NSString stringWithUTF8String:srcValue]];
                        if(titleValue)
                        {
                            [bookInfo setBookTitle:[NSString stringWithUTF8String:titleValue]];
                        }
                        if(authorValue)
                        {
                            [bookInfo setBookAuthor:[NSString stringWithUTF8String:authorValue]];
                        }
                        if(openTimeValue)
                        {
                            [bookInfo setBookOpenTime:[NSString stringWithUTF8String:openTimeValue]];
                        }
                        if(flagValue!=NULL )
                        {
                            [bookInfo setBookFlag:[[NSString stringWithUTF8String:flagValue]intValue] ];
                        }
                        if(markValue!=NULL)
                        {
                            [bookInfo setBookMark:[NSString stringWithUTF8String:markValue]];
                        }
                        if(createTime!=NULL)
                        {
                            [bookInfo setBookCreateTime:[NSString stringWithUTF8String:createTime]];
                        }
                        
                        [bookArray addObject:bookInfo];
                    }
                    index=index+8;
                }
            }
        }else if(flag== -2){//最近阅读
            char **dbResult = NULL;
            char* errmsg;
            int nRow, nColumn;
            int index;
            int i;
            //  int j;
            int nResult = sqlite3_get_table(db, "select id,title,author,src,openTime,flag,mark,createTime from book_info where openTime>date('now','-7 day') order by openTime desc", &dbResult, &nRow,&nColumn, &errmsg);
            if (nResult == SQLITE_OK)
            {
                index = nColumn;
                printf("find %d record\n", nRow);
                
                for (i = 0; i < nRow; i++)
                {
                    BookInfo *bookInfo=[[BookInfo alloc]init];
                    //                    [bookInfo setBookId:[NSString stringWithUTF8String:dbResult[index]]];
                    //                    [bookInfo setBookTitle:[NSString stringWithUTF8String:dbResult[index+1]]];
                    //                    [bookInfo setBookAuthor:[NSString stringWithUTF8String:dbResult[index+2]]];
                    //                    [bookInfo setBookSrc:[NSString stringWithUTF8String:dbResult[index+3]]];
                    //                    [bookInfo setBookOpenTime:[NSString stringWithUTF8String:dbResult[index+4]]];
                    char * titleValue=dbResult[index+1];
                    char * authorValue=dbResult[index+2];
                    char * srcValue=dbResult[index+3];
                    char * openTimeValue=dbResult[index+4];
                    char * flagValue=dbResult[index+5];
                    char * markValue=dbResult[index+6];
                    char * createTime=dbResult[index+7];
                    if(srcValue)
                    {
                        [bookInfo setBookSrc:[NSString stringWithUTF8String:srcValue]];
                        if(titleValue)
                        {
                            [bookInfo setBookTitle:[NSString stringWithUTF8String:titleValue]];
                        }
                        if(authorValue)
                        {
                            [bookInfo setBookAuthor:[NSString stringWithUTF8String:authorValue]];
                        }
                        if(openTimeValue)
                        {
                            [bookInfo setBookOpenTime:[NSString stringWithUTF8String:openTimeValue]];
                        }
                        if(flagValue!=NULL )
                        {
                            [bookInfo setBookFlag:[[NSString stringWithUTF8String:flagValue]intValue] ];
                        }
                        if(markValue!=NULL)
                        {
                            [bookInfo setBookMark:[NSString stringWithUTF8String:markValue]];
                        }
                        if(createTime!=NULL)
                        {
                            [bookInfo setBookCreateTime:[NSString stringWithUTF8String:createTime]];
                        }
                        
                        [bookArray addObject:bookInfo];
                    }
                    index=index+8;
                }
            }
        }else{
            char **dbResult = NULL;
            char* errmsg;
            int nRow, nColumn;
            int index;
            int i;
            //  int j;
            int nResult = sqlite3_get_table(db, [[NSString stringWithFormat: @"select id,title,author,src,openTime,flag,mark,createTime from book_info where flag=%d order by title,openTime",flag] UTF8String], &dbResult, &nRow,&nColumn, &errmsg);
            if (nResult == SQLITE_OK)
            {
                index = nColumn;
                printf("find %d record\n", nRow);
                
                for (i = 0; i < nRow; i++)
                {
                    BookInfo *bookInfo=[[BookInfo alloc]init];
                    //                    [bookInfo setBookId:[NSString stringWithUTF8String:dbResult[index]]];
                    //                    [bookInfo setBookTitle:[NSString stringWithUTF8String:dbResult[index+1]]];
                    //                    [bookInfo setBookAuthor:[NSString stringWithUTF8String:dbResult[index+2]]];
                    //                    [bookInfo setBookSrc:[NSString stringWithUTF8String:dbResult[index+3]]];
                    //                    [bookInfo setBookOpenTime:[NSString stringWithUTF8String:dbResult[index+4]]];
                    char * titleValue=dbResult[index+1];
                    char * authorValue=dbResult[index+2];
                    char * srcValue=dbResult[index+3];
                    char * openTimeValue=dbResult[index+4];
                    char * flagValue=dbResult[index+5];
                    char * markValue=dbResult[index+6];
                     char * createTime=dbResult[index+7];
                    if(srcValue)
                    {
                        [bookInfo setBookSrc:[NSString stringWithUTF8String:srcValue]];
                        if(titleValue)
                        {
                            [bookInfo setBookTitle:[NSString stringWithUTF8String:titleValue]];
                        }
                        if(authorValue)
                        {
                            [bookInfo setBookAuthor:[NSString stringWithUTF8String:authorValue]];
                        }
                        if(openTimeValue)
                        {
                            [bookInfo setBookOpenTime:[NSString stringWithUTF8String:openTimeValue]];
                        }
                        if(flagValue!=NULL )
                        {
                            [bookInfo setBookFlag:[[NSString stringWithUTF8String:flagValue]intValue] ];
                        }
                        if(markValue!=NULL)
                        {
                            [bookInfo setBookMark:[NSString stringWithUTF8String:markValue]];
                        }
                        if(createTime!=NULL)
                        {
                            [bookInfo setBookCreateTime:[NSString stringWithUTF8String:createTime]];
                        }
                        [bookArray addObject:bookInfo];
                    }
                    index=index+8;
                }
            }
        }
        sqlite3_close(db);
    }
    return bookArray;
}


/** 根据标识获取资讯 **/
-(NSMutableArray *)queryNewsList:(int)flag{
    NSMutableArray * bookArray = [NSMutableArray new];
    sqlite3 *db=[self database];
    if(db)
    {
        if(flag==-12)//全部
        {
            char **dbResult = NULL;
            char* errmsg;
            int nRow, nColumn;
            int index;
            int i;
            //  int j;
            int nResult = sqlite3_get_table(db, "select id,title,sitename as author,link as src,createdate as openTime,status as flag,sitename as mark,createdate as createTime  from site_info_discover order by id desc", &dbResult, &nRow,&nColumn, &errmsg);
            if (nResult == SQLITE_OK)
            {
                index = nColumn;
                printf("find %d record\n", nRow);
                
                for (i = 0; i < nRow; i++)
                {
                    BookInfo *bookInfo=[[BookInfo alloc]init];
                    //                    [bookInfo setBookId:[NSString stringWithUTF8String:dbResult[index]]];
                    //                    [bookInfo setBookTitle:[NSString stringWithUTF8String:dbResult[index+1]]];
                    //                    [bookInfo setBookAuthor:[NSString stringWithUTF8String:dbResult[index+2]]];
                    //                    [bookInfo setBookSrc:[NSString stringWithUTF8String:dbResult[index+3]]];
                    //                    [bookInfo setBookOpenTime:[NSString stringWithUTF8String:dbResult[index+4]]];
                    char * titleValue=dbResult[index+1];
                    char * authorValue=dbResult[index+2];
                    char * srcValue=dbResult[index+3];
                    char * openTimeValue=dbResult[index+4];
                    char * flagValue=dbResult[index+5];
                    char * markValue=dbResult[index+6];
                    char * createTime=dbResult[index+7];
                    if(srcValue)
                    {
                        [bookInfo setBookSrc:[NSString stringWithUTF8String:srcValue]];
                        [bookInfo setWebUrl:[NSString stringWithUTF8String:srcValue]];
                        if(titleValue)
                        {
                            [bookInfo setBookTitle:[NSString stringWithUTF8String:titleValue]];
                        }
                        if(authorValue)
                        {
                            [bookInfo setBookAuthor:[NSString stringWithUTF8String:authorValue]];
                        }
                        if(openTimeValue)
                        {
                            [bookInfo setBookOpenTime:[NSString stringWithUTF8String:openTimeValue]];
                        }
                        if(flagValue!=NULL )
                        {
                            [bookInfo setBookFlag:[[NSString stringWithUTF8String:flagValue]intValue] ];
                        }
                        if(markValue!=NULL)
                        {
                            [bookInfo setBookMark:[NSString stringWithUTF8String:markValue]];
                        }
                        if(createTime!=NULL)
                        {
                            [bookInfo setBookCreateTime:[NSString stringWithUTF8String:createTime]];
                        }
                        [bookArray addObject:bookInfo];
                    }
                    index=index+8;
                }
            }
        }else if(flag== -13){//收藏站点
            char **dbResult = NULL;
            char* errmsg;
            int nRow, nColumn;
            int index;
            int i;
            //  int j;
            int nResult = sqlite3_get_table(db, "select id,sitename as title,sitename as author,link as src,'' as openTime,status as flag,remark as mark,'' as  createTime from site_info_url order by id desc", &dbResult, &nRow,&nColumn, &errmsg);
            if (nResult == SQLITE_OK)
            {
                index = nColumn;
                printf("find %d record\n", nRow);
                
                for (i = 0; i < nRow; i++)
                {
                    BookInfo *bookInfo=[[BookInfo alloc]init];
                    //                    [bookInfo setBookId:[NSString stringWithUTF8String:dbResult[index]]];
                    //                    [bookInfo setBookTitle:[NSString stringWithUTF8String:dbResult[index+1]]];
                    //                    [bookInfo setBookAuthor:[NSString stringWithUTF8String:dbResult[index+2]]];
                    //                    [bookInfo setBookSrc:[NSString stringWithUTF8String:dbResult[index+3]]];
                    //                    [bookInfo setBookOpenTime:[NSString stringWithUTF8String:dbResult[index+4]]];
                    char * titleValue=dbResult[index+1];
                    char * authorValue=dbResult[index+2];
                    char * srcValue=dbResult[index+3];
                    char * openTimeValue=dbResult[index+4];
                    char * flagValue=dbResult[index+5];
                    char * markValue=dbResult[index+6];
                    char * createTime=dbResult[index+7];
                    if(srcValue)
                    {
                        [bookInfo setBookSrc:[NSString stringWithUTF8String:srcValue]];
                        [bookInfo setWebUrl:[NSString stringWithUTF8String:srcValue]];
                        if(titleValue)
                        {
                            [bookInfo setBookTitle:[NSString stringWithUTF8String:titleValue]];
                        }
                        if(authorValue)
                        {
                            [bookInfo setBookAuthor:[NSString stringWithUTF8String:authorValue]];
                        }
                        if(openTimeValue)
                        {
                            [bookInfo setBookOpenTime:[NSString stringWithUTF8String:openTimeValue]];
                        }
                        if(flagValue!=NULL )
                        {
                            [bookInfo setBookFlag:[[NSString stringWithUTF8String:flagValue]intValue] ];
                        }
                        if(markValue!=NULL)
                        {
                            [bookInfo setBookMark:[NSString stringWithUTF8String:markValue]];
                        }
                        if(createTime!=NULL)
                        {
                            [bookInfo setBookCreateTime:[NSString stringWithUTF8String:createTime]];
                        }
                        
                        [bookArray addObject:bookInfo];
                    }
                    index=index+8;
                }
            }
        }else{
            char **dbResult = NULL;
            char* errmsg;
            int nRow, nColumn;
            int index;
            int i;
            //  int j;
            int nResult = sqlite3_get_table(db, [[NSString stringWithFormat: @"select id,title,sitename as author,link as src,createdate as openTime,status as flag,sitename as mark,createdate as createTime  from site_info_discover where createdate>date('now','-%d day') order by id desc",1] UTF8String], &dbResult, &nRow,&nColumn, &errmsg);
            if (nResult == SQLITE_OK)
            {
                index = nColumn;
                printf("find %d record\n", nRow);
                
                for (i = 0; i < nRow; i++)
                {
                    BookInfo *bookInfo=[[BookInfo alloc]init];
                    //                    [bookInfo setBookId:[NSString stringWithUTF8String:dbResult[index]]];
                    //                    [bookInfo setBookTitle:[NSString stringWithUTF8String:dbResult[index+1]]];
                    //                    [bookInfo setBookAuthor:[NSString stringWithUTF8String:dbResult[index+2]]];
                    //                    [bookInfo setBookSrc:[NSString stringWithUTF8String:dbResult[index+3]]];
                    //                    [bookInfo setBookOpenTime:[NSString stringWithUTF8String:dbResult[index+4]]];
                    char * titleValue=dbResult[index+1];
                    char * authorValue=dbResult[index+2];
                    char * srcValue=dbResult[index+3];
                    char * openTimeValue=dbResult[index+4];
                    char * flagValue=dbResult[index+5];
                    char * markValue=dbResult[index+6];
                    char * createTime=dbResult[index+7];
                    if(srcValue)
                    {
                        [bookInfo setBookSrc:[NSString stringWithUTF8String:srcValue]];
                         [bookInfo setWebUrl:[NSString stringWithUTF8String:srcValue]];
                        if(titleValue)
                        {
                            [bookInfo setBookTitle:[NSString stringWithUTF8String:titleValue]];
                        }
                        if(authorValue)
                        {
                            [bookInfo setBookAuthor:[NSString stringWithUTF8String:authorValue]];
                        }
                        if(openTimeValue)
                        {
                            [bookInfo setBookOpenTime:[NSString stringWithUTF8String:openTimeValue]];
                        }
                        if(flagValue!=NULL )
                        {
                            [bookInfo setBookFlag:[[NSString stringWithUTF8String:flagValue]intValue] ];
                        }
                        if(markValue!=NULL)
                        {
                            [bookInfo setBookMark:[NSString stringWithUTF8String:markValue]];
                        }
                        if(createTime!=NULL)
                        {
                            [bookInfo setBookCreateTime:[NSString stringWithUTF8String:createTime]];
                        }
                        [bookArray addObject:bookInfo];
                    }
                    index=index+8;
                }
            }
        }
        sqlite3_close(db);
    }
    return bookArray;
}

-(NSMutableArray *) queryKey:(NSString *) keyStr{
    NSMutableArray * bookArray = [NSMutableArray new];
    sqlite3 *db=[self database];
    if(db)
    {
        sqlite3_stmt *prepared_statement;
        const char * keyChar=[[NSString stringWithFormat:@"%%%@%%",keyStr] UTF8String];
        if(sqlite3_prepare_v2(db, "select id,title,author,src,openTime,flag,mark,createTime from book_info where title like ? or author like ? ", -1, &prepared_statement, NULL) != SQLITE_OK)
        {
            NSLog(@"数据查询失败:%s",sqlite3_errmsg(db));
        }
        if (sqlite3_bind_text (prepared_statement,  1, keyChar, -1, SQLITE_TRANSIENT) != SQLITE_OK) {
            NSLog(@"数据查询失败:%s",sqlite3_errmsg(db));
            sqlite3_finalize(prepared_statement);
            
        }
        if (sqlite3_bind_text (prepared_statement,  2, keyChar, -1, SQLITE_TRANSIENT) != SQLITE_OK) {
            NSLog(@"数据查询失败:%s",sqlite3_errmsg(db));
        }
//        int error_code = sqlite3_step (prepared_statement);
//        if (error_code != SQLITE_OK && error_code != SQLITE_ROW && error_code != SQLITE_DONE) {
//            NSLog(@"数据库表是否存在设置参数失败:%s",sqlite3_errmsg(db));
//
//        }
        while(sqlite3_step(prepared_statement)==SQLITE_ROW)
        {
           const char * idValue=(const char*)sqlite3_column_text(prepared_statement, 0);
           const char * titleValue=(const char*)sqlite3_column_text(prepared_statement, 1);
           const char * authorValue=(const char*)sqlite3_column_text(prepared_statement, 2);
           const char * srcValue=(const char*)sqlite3_column_text(prepared_statement, 3);
           const char * openTimeValue=(const char*)sqlite3_column_text(prepared_statement, 4);
           const char * flagValue=(const char*)sqlite3_column_text(prepared_statement, 5);
           const char * markValue=(const char*)sqlite3_column_text(prepared_statement, 6);
           const char * createTime=(const char*)sqlite3_column_text(prepared_statement, 7);
            if(srcValue)
            {
                BookInfo *bookInfo=[[BookInfo alloc]init];
                [bookInfo setBookId:[NSString stringWithUTF8String:idValue]];
                [bookInfo setBookSrc:[NSString stringWithUTF8String:srcValue]];
                if(titleValue)
                {
                    [bookInfo setBookTitle:[NSString stringWithUTF8String:titleValue]];
                }
                if(authorValue)
                {
                    [bookInfo setBookAuthor:[NSString stringWithUTF8String:authorValue]];
                }
                if(openTimeValue)
                {
                    [bookInfo setBookOpenTime:[NSString stringWithUTF8String:openTimeValue]];
                }
                if(flagValue!=NULL )
                {
                    [bookInfo setBookFlag:[[NSString stringWithUTF8String:flagValue]intValue] ];
                }
                if(markValue!=NULL)
                {
                    [bookInfo setBookMark:[NSString stringWithUTF8String:markValue]];
                }
                if(createTime!=NULL)
                {
                    [bookInfo setBookCreateTime:[NSString stringWithUTF8String:createTime]];
                }
                [bookArray addObject:bookInfo];
            }
        }
       // int exitTbl= sqlite3_column_int(prepared_statement,0);
       // NSLog(@"保存bookID=%@结果:%d",bookId,exitTbl);
        sqlite3_finalize(prepared_statement);
        sqlite3_close(db);
    }
    return bookArray;
    
}


-(void) importBook:(NSString *) fullPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir, valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
    if (valid && isDir) {
        NSArray *array = [fileManager contentsOfDirectoryAtPath:fullPath error:NULL];
        
        if (array) {   // This is unexpected
            sqlite3 *db=[self database];
            if(db)
            {
                char* errmsg;
                NSUInteger cnt, numChildren = [array count];
                for (cnt = 0; cnt < numChildren; cnt++) {
                    NSString * filePath=[array objectAtIndex:cnt];
                    NSString *bookFilePath=[fullPath stringByAppendingPathComponent:filePath];
                    
                    BookRead * bookRead=[[BookRead alloc]initWithPath:bookFilePath];
                    
                    NSLog(@"找到%@",bookFilePath);
                    NSString *title=[bookRead title];
                    NSString *author=[bookRead author];
                    NSString *bookId=[bookRead bookId];
                    
                    if(bookId)
                    {
                        NSString *sql=[NSString stringWithFormat:@"insert into book_info(id,title,author,src,createTime) values('%@','%@','%@','%@',datetime('now') )",bookId,title,author,bookFilePath];
                        NSLog(@"sql:%@",sql);
                        int nResult = sqlite3_exec(db, [sql UTF8String],NULL, NULL, &errmsg);
                        
                        if (nResult != SQLITE_OK)
                        {
                            NSLog(@"表插入数据失败:%s",errmsg);
                        }
                    }
                    
                    
                }
                sqlite3_close(db);
            }
        }
    }else{
        if([[fullPath pathExtension] isEqualToString:@"azw3"] || [[fullPath pathExtension] isEqualToString:@"mobi"]|| [[fullPath pathExtension] isEqualToString:@"epub"])
        {
            sqlite3 *db=[self database];
            if(db)
            {
                char* errmsg;
                
                    BookRead * bookRead=[[BookRead alloc]initWithPath:fullPath];
                    NSString *title=[bookRead title];
                    NSString *author=[bookRead author];
                    NSString *bookId=[bookRead bookId];
                    
                    if(bookId)
                    {
                        NSString *sql=[NSString stringWithFormat:@"insert into book_info(id,title,author,src,createTime) values('%@','%@','%@','%@',datetime('now') )",bookId,title,author,fullPath];
                        NSLog(@"sql:%@",sql);
                        int nResult = sqlite3_exec(db, [sql UTF8String],NULL, NULL, &errmsg);
                        
                        if (nResult != SQLITE_OK)
                        {
                            NSLog(@"表插入数据失败:%s",errmsg);
                        }
                    }
                    
                    
            
                sqlite3_close(db);
            }
            
        }
        
    }
}

-(void) saveBook:(NSString *)bookId mark:(NSString *)mark{
    
    sqlite3 *db=[self database];
    if(db)
    {
        sqlite3_stmt *prepared_statement;
        
        if(sqlite3_prepare_v2(db, "update book_info set mark=?,openTime=datetime('now') where id=?", -1, &prepared_statement, NULL) != SQLITE_OK)
        {
            NSLog(@"数据库表是否存在获取失败:%s",sqlite3_errmsg(db)); 
        }
        if (sqlite3_bind_text (prepared_statement,  1, [mark UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
            NSLog(@"数据库表是否存在设置参数失败:%s",sqlite3_errmsg(db));
            sqlite3_finalize(prepared_statement);
            
        }
        if (sqlite3_bind_text (prepared_statement,  2, [bookId UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
            NSLog(@"数据库表是否存在设置参数失败:%s",sqlite3_errmsg(db));
        }
        int error_code = sqlite3_step (prepared_statement);
        if (error_code != SQLITE_OK && error_code != SQLITE_ROW && error_code != SQLITE_DONE) {
            NSLog(@"数据库表是否存在设置参数失败:%s",sqlite3_errmsg(db));
           
        }
        int exitTbl= sqlite3_column_int(prepared_statement,0);
        NSLog(@"保存bookID=%@结果:%d",bookId,exitTbl);
        sqlite3_finalize(prepared_statement);
        sqlite3_close(db);
    }
}



@end
