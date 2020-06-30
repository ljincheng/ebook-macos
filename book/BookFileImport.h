//
//  BookFileImport.h
//  mobi
//
//  Created by ljc on 2018/10/26.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef BookFileImport_h
#define BookFileImport_h

#import <Foundation/Foundation.h>

// The is the protocol that describes the responsibility of fetching the contents of a URL. Note that it returns a file handle via the reply block.
@protocol BookFileImport
- (void)importDirBook:(NSString *)path withReply:(void (^)( NSError *))reply;
@end

// This is a protocol that describes the responsibility of presenting progress information to the user. The Fetcher object below will report progress as it downloads things.
@protocol BookFileImportProgress
- (void)setProgress:(double)progress;
@end

// One of these objects is created per incoming connection. It stores the reply block and does its work asynchronously, calling back to the main process when it is finished downloading. It also calls back to the main process to do progress reporting, by taking advantage of the bi-directional nature of NSXPCConnection.
@interface BookFileImporter : NSObject <BookFileImport> {
    void (^replyBlock)(NSError *);
    NSString *dirPath;
}


@end

#endif /* BookFileImport_h */
