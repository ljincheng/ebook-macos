//
//  epub-utils.h
//  mobi
//
//  Created by ljc on 2018/11/23.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#ifndef epub_utils_h
#define epub_utils_h


#import <Foundation/Foundation.h>
#include <libxml/tree.h>

@interface  EpubUtils : NSObject

-(xmlNode *) elementByTag :(xmlNode *)node  tagname:(const char *)name;

-(char *) elementProp:(xmlNode *)node propname:(const char *)prop;

@end
#endif /* epub_utils_h */
