//
//  epub-archive.h
//  mobi
//
//  Created by ljc on 2018/11/10.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef epub_archive_h
#define epub_archive_h


#import <Foundation/Foundation.h>
#include <libxml/tree.h>

@interface EpubArchive : NSObject

-(id)initWithPath:(const char *)zipPath;

-( NSData *)readEntry:(const char *)filepath;
-(char *) rootFile;

-(NSMutableArray *) fillSpine:(NSData *) rootContent;

-(NSMutableDictionary *) fillResource:(NSData *) rootContent contentBase:(NSString *)basePath;

-(NSString *)contentMetadata:(NSData *) rootContent metadata:(const char *)mdata;

-(NSData *)replaceResources :(NSData *)content;

-(xmlNode *) elementByTag :(xmlNode *)node  tagname:(const char *)name;

-(char *) elementProp:(xmlNode *)node propname:(const char *)prop;

@end



#endif /* epub_archive_h */
