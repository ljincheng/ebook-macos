//
//  epub-utils.m
//  epub
//
//  Created by ljc on 2018/11/23.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "epub-utils.h"
#include <libxml/parser.h>

@implementation EpubUtils

-(xmlNode *) elementByTag :(xmlNode *)node  tagname:(const char *)name
{
    xmlNode *cur_node = NULL;
    xmlNode *ret = NULL;
    
    for (cur_node = node; cur_node; cur_node = cur_node->next) {
        if (cur_node->type == XML_ELEMENT_NODE ) {
            if (!strcmp ((const char *) cur_node->name, name))
                return cur_node;
        }
        
        ret = [self elementByTag: cur_node->children tagname: name];
        if (ret)
            return ret;
    }
    return ret;
}


-(char *) elementProp:(xmlNode *)node propname:(const char *)prop
{
    xmlChar *p = NULL;
    char *ret = NULL;
    
    p = xmlGetProp (node, (const xmlChar *) prop);
    if (p) {
        ret = strdup ((char *) p);
        xmlFree (p);
    }
    
    return ret;
}

@end
