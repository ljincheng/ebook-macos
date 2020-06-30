//
//  epub-doc.h
//  mobi
//
//  Created by ljc on 2018/11/11.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef epub_doc_h
#define epub_doc_h

#import <Foundation/Foundation.h>

 
@interface  EpubDoc : NSObject


-(id) initWithPath:(const char *) path;

-(NSMutableArray *) spine;
-(NSMutableDictionary *) resource;

-(NSData *) read:(NSString *)href;

-(NSString *) metadata:(const char *)metadata;

-(NSString *) contentBase;


@end
#endif /* epub_doc_h */
