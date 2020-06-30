//
//  epub-archive.m
//  epub
//
//  Created by ljc on 2018/11/10.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "epub-archive.h"
#import "archive.h"
#import "archive_entry.h"
#include <libxml/parser.h>
#include <libxml/tree.h>
#import "epub-resource.h"

@implementation EpubArchive
{
   // struct archive *epubArchive;
    //struct archive_entry *epubArchiveEntry;
     char *_path;
}

-(id)initWithPath:(const char *)zipPath{
    self=[super init];
    if(self)
    {
//     int r;
    _path=strdup( zipPath);
//   epubArchive = archive_read_new();
//    archive_read_support_format_zip(epubArchive);
//    r = archive_read_open_filename (epubArchive,zipPath, 10240);
    
//    if (r != ARCHIVE_OK) {
//        return FALSE;
//    }
    }
    return self;
}
-(struct archive *) archiveOpen{
    int r;
    struct archive * epubArchive;
    epubArchive= archive_read_new();
    archive_read_support_format_zip(epubArchive);
    r = archive_read_open_filename (epubArchive,_path, 10240);
    
        if (r != ARCHIVE_OK) {
            return nil;
        }
    return epubArchive;
}

-(void) archiveClose:(struct archive *)epubArchive{
    if (!epubArchive)
        return;
    
    archive_read_free (epubArchive);
    epubArchive = NULL;
}

-( NSData *)readEntry:(const char *)filepath
{
    //NSLog(@"readEntry:filepath=%s\n",filepath);
    struct archive_entry *entry;
    //char *buffer;
    NSData *data=NULL;
    unsigned char *buffer;
    //int64_t size;
    size_t size;
   // unsigned int size;
    struct archive *epubArchive;
    
     
    epubArchive=[self archiveOpen];
    if(epubArchive)
    {
        while (archive_read_next_header (epubArchive, &entry) == ARCHIVE_OK) {
          const char *pathname= archive_entry_pathname(entry);
           // NSLog(@"pathname=%s,filepath=%s",pathname,filepath);
            if (strcmp (filepath, pathname) == 0)
                break;
            archive_read_data_skip (epubArchive);
        }
        
        size = (size_t)archive_entry_size (entry);
        if(size>0)
        {
            buffer =calloc(1,size);// malloc ([[NSNumber numberWithLongLong:size] unsignedIntValue]);
        archive_read_data (epubArchive, buffer, size);
           // NSLog(@"filepath=%s,size=%zu,buffer=\n%s\n",filepath,size,buffer);
        data=[NSData dataWithBytes:buffer length:size];
            free(buffer);
            
        }
    }
    [self archiveClose:epubArchive];
    return data;
}

-(NSData *)replaceResources :(NSData *)content
{
    if(content==NULL)
    {
        return content;
    }
    xmlDoc *doc = NULL;
    xmlNode *root_element = NULL;
    unsigned char *buffer;
    const char *data;
    size_t bufsize;
    
    data = [content bytes];
    doc = xmlReadMemory (data, [[NSNumber numberWithUnsignedInteger:[content length]]intValue ], "", NULL, XML_PARSE_NOWARNING | XML_PARSE_NOERROR);
    root_element = xmlDocGetRootElement (doc);
    
    xmlDocDumpFormatMemory (doc, (xmlChar**)&buffer, (int*)&bufsize, 1);
    xmlFreeDoc (doc);
    return [NSData dataWithBytes:buffer length:bufsize];
}

-(NSMutableDictionary *) fillResource:(NSData *) rootContent contentBase:(NSString *)basePath{
    NSMutableDictionary *result=[[NSMutableDictionary alloc] initWithCapacity:0];
    
    xmlDoc *xdoc = NULL;
    xmlNode *root_element = NULL;
    xmlNode *item = NULL;
    xmlNode *mnode=NULL;
    //  gchar *id;
    const char *data;
    // gsize size;
    // GList *spine = NULL;
    data =[rootContent  bytes];
    xdoc = xmlRecoverMemory(data,[[NSNumber numberWithUnsignedInteger:[rootContent length]]intValue ]);
    root_element = xmlDocGetRootElement(xdoc);
    
    
    //manifest 值：
    mnode =  [self elementByTag:root_element tagname: "manifest"];
    
    item = mnode->children;
    while (item) {
        if (item->type != XML_ELEMENT_NODE) {
            item = item->next;
            continue;
        }
        NSString *resid=[NSString stringWithUTF8String:[self elementProp:item propname:"id"]];
        char *hrefprop=[self elementProp:item propname:"href"];
        NSString *href=[NSString stringWithFormat:@"%@%s" ,basePath,hrefprop];
        free(hrefprop);
        NSString *mime=[NSString stringWithUTF8String:[self elementProp:item propname:"media-type"]];
        
        EpubResource *epubRes=[[EpubResource alloc]init];
        [epubRes setResId:resid];
        [epubRes setHref:href];
        [epubRes setMime:mime];
        [result setObject:epubRes forKey:resid];
        item = item->next;
    }
    
    
    xmlFreeDoc(xdoc);
    return result;
    
}
-(NSMutableArray *) fillSpine:(NSData *) rootContent{
    NSMutableArray *spine=[[NSMutableArray alloc] initWithCapacity:0];;
    
    xmlDoc *xdoc = NULL;
    xmlNode *root_element = NULL;
    xmlNode *snode = NULL;
    xmlNode *item = NULL;
  //  gchar *id;
    const char *data;
   // gsize size;
   // GList *spine = NULL;
    data =[rootContent  bytes];
    xdoc = xmlRecoverMemory(data,[[NSNumber numberWithUnsignedInteger:[rootContent length]]intValue ]);
    root_element = xmlDocGetRootElement(xdoc);
    
    //spine 值：
    snode = [self elementByTag:root_element tagname: "spine"];
    
    item = snode->children;
    while (item) {
        if (item->type != XML_ELEMENT_NODE) {
            item = item->next;
            continue;
        }
        
        NSString *resid=[NSString stringWithUTF8String:[self elementProp:item propname:"idref"]];
        [spine addObject:resid];
        
        item = item->next;
    }
    
    xmlFreeDoc(xdoc);
    return spine;
    
}

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

-(char *) rootFile{
    xmlDoc *doc = NULL;
    xmlNode *root_element = NULL;
    xmlNode *root_node = NULL;
    char *buffer;
    char *root_file = NULL;
    struct archive_entry *entry;
    int64_t size;
     struct archive *epubArchive;
    
    epubArchive=[self archiveOpen];
    if(epubArchive)
    {
        while (archive_read_next_header (epubArchive, &entry) == ARCHIVE_OK) {
            if (strcmp ("META-INF/container.xml", archive_entry_pathname (entry)) == 0)
                break;
            archive_read_data_skip (epubArchive);
        }
        
        size = archive_entry_size (entry);
        if(size>0)
        {
            buffer = malloc ((size_t)size);
            archive_read_data (epubArchive, buffer, (size_t)size);
        
        doc = xmlRecoverMemory (buffer, [[NSNumber numberWithLongLong:size] intValue]);
        root_element = xmlDocGetRootElement (doc);
        root_node = [self elementByTag:root_element tagname: "rootfile"];
        root_file = [self elementProp: root_node propname:"full-path"];
        
        xmlFreeDoc (doc);
        free (buffer);
            [self archiveClose:epubArchive];
        return root_file;
        }
    }
    [self archiveClose:epubArchive];
    return NULL;
}

-(NSString *)contentMetadata:(NSData *) rootContent metadata:(const char *)mdata
{
    NSString *ret;
    xmlDoc *xdoc = NULL;
    xmlNode *root_element = NULL;
    xmlNode *mnode = NULL;
    xmlNode *mdata_node = NULL;
    
    xmlChar *text;
    const char *data;
 
    
    // gsize size;
    // GList *spine = NULL;
    data =[rootContent  bytes];
    xdoc = xmlRecoverMemory(data,[[NSNumber numberWithUnsignedInteger:[rootContent length]]intValue ]);
    root_element = xmlDocGetRootElement(xdoc);
    
     mnode = [self elementByTag:root_element tagname: "metadata"];
   // mnode = gepub_utils_get_element_by_tag(root_element, "metadata");
    mdata_node = [self elementByTag:mnode tagname: mdata]; //gepub_utils_get_element_by_tag(mnode, mdata);
    
    text = xmlNodeGetContent(mdata_node);
    ret=[NSString stringWithUTF8String:(const char*)text];
   // ret = g_strdup((const char*)text);
    
    xmlFree(text);
    
    xmlFreeDoc(xdoc);
    
    return ret;
}

//-(void) dealloc{

//    if(epubArchive!=NULL)
//    {
//        archive_read_free (epubArchive);
//        epubArchive=NULL;
//    }
//}
@end
