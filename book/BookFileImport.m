//
//  BookFileImport.m
//  book
//
//  Created by ljc on 2018/10/26.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import "BookFileImport.h"
#import "BookDatabase.h"

@implementation BookFileImporter

- (void)importDirBook:(NSString *)path withReply:(void (^)( NSError *))reply {
   
    // We'll call back this reply block later. If this were a manual retain/release application, it is required to use 'copy' on this block to make sure it sticks around long enough for us to call it. This is compiled with ARC though, so the compiler will take care of it for us when we do this assignment.
    replyBlock = reply;
    dirPath=path;
    
    BookDatabase * bookDatabase=[[BookDatabase alloc]init];
    [bookDatabase importBook:path];
    reply(nil);
    
}


@end
