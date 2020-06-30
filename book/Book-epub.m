//
//  Book-epub.m
//  book
//
//  Created by ljc on 2018/11/12.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book-epub.h"
#import "epub.h"
#include <libxml/parser.h>
#include <libxml/tree.h>
//#include <libxml/parser.h>
//#include <libxml/tree.h>

@implementation BookEpub{
    NSString * _bookFilePath; 
    NSString *_title;
    NSString *_author;
    NSString *_bookId;
    EpubDoc *_epubDoc;
}
int TOPINDEX=0;
/** 根据书文件路径初始化 */
- (id) initWithPath:(NSString*)bookPath{
    if((self=[super init])){
        _bookFilePath=bookPath;
        const char * epubfilepath=[_bookFilePath UTF8String];
        _epubDoc=[[EpubDoc alloc]initWithPath:epubfilepath];
    }
    return self;
    
}
/** 总章节数 **/
-(size_t) chapterCount{
    return [[_epubDoc spine]count];
}
/** 书名 **/
-(NSString *) title{
    return [_epubDoc metadata:"title"];
}
/** 作者 **/
-(NSString *) author{
     return [_epubDoc metadata:"creator"];
}
/**  书籍ID */
-(NSString *) bookId{
     return [_epubDoc metadata:"identifier"];
}

/** 获取章节 **/
-(BookChapter *) chapter:(size_t)index{
  
    NSMutableArray *spine=[_epubDoc spine];
      if(index < [spine count])
      {
        NSMutableDictionary *res=[_epubDoc resource];
        NSString *resid=  [spine objectAtIndex:index];
        EpubResource *epubRes=  [res objectForKey:resid];
          NSData *htmlData=[_epubDoc read:[epubRes href]];
          if(htmlData)
          {
            //  NSString *htm=    [[NSString alloc] initWithData:htmlData  encoding:NSUTF8StringEncoding];
//        NSLog(@"resid=%@,mine=%@,href=%@\n",resid,[epubRes mime],[epubRes href]);
       // NSLog(@"index=%zu,data=%@\n",index,htm);
         BookChapter *bookChapter=[[BookChapter alloc] init];
          [bookChapter setUrl:[epubRes href]];
          [bookChapter setMime:[epubRes mime]];
          [bookChapter setData:htmlData];
          return bookChapter;
          }
      }
    return NULL;
}
-(BookChapter *) resource:(NSString *)url{
    NSString *filePath;
    NSString *contentBase=[_epubDoc contentBase];
    
    if(contentBase!=nil && [contentBase length]>0)
    {
        filePath=[NSString stringWithFormat:@"%@%@",contentBase,url];
    }else{
        filePath=url;
    }
     NSMutableDictionary *res=[_epubDoc resource];
    NSEnumerator * enumeratorValue = [res objectEnumerator];
    BookChapter *bookChapter=NULL;
    //快速枚举遍历所有Value的值
    for (EpubResource *epubRes in enumeratorValue) {
        if([[epubRes href] isEqualToString:filePath])
        {
           bookChapter= [[BookChapter alloc] init];
            [bookChapter setMime:[epubRes mime]];
            break;
        }
       // NSLog(@"遍历Value的值: %@",object);
    }
    if(bookChapter)
    {
     [bookChapter setData:  [_epubDoc read:filePath]];
    }
    return bookChapter;
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

-(void) loop_child_navpoint:(const char *)basePath item:(xmlNode *)item navpoint:(BookNavPoint  *)parentNavPoint
{
    
    xmlNode *labelText = NULL;
    xmlNode * contentNode = NULL;
    xmlChar *text = NULL;
    xmlChar *src = NULL;
    char *pointId = NULL;
    char *playOrder = NULL;
    BookNavPoint   *nextNavPoint = NULL;
    int index=0;
    while (item) {
        if (item->type != XML_ELEMENT_NODE) {
            item = item->next;
            continue;
        }
        
        if (!strcmp((const char*)item->name, "navPoint")) {
            labelText =[self elementByTag:item tagname: "text"];
            text = xmlNodeGetContent(labelText);
            contentNode =[self elementByTag:item tagname: "content"];  // gepub_utils_get_element_by_tag(item, "content");
            src = xmlGetProp(contentNode, BAD_CAST("src"));
            pointId = [self elementProp:item propname:"id"];//gepub_utils_get_prop(item, "id");
            playOrder =[self elementProp:item propname:"playOrder"]; //gepub_utils_get_prop(item, "playOrder");
            // g_printf("标题：%s(id:%s,playOrder:%s,src:%s)\n", g_strdup ((const char *) text),id,playOrder,g_strdup ((const char *) src));
            BookNavPoint     *navPoint = malloc(sizeof(BookNavPoint));
            if(pointId!=NULL)
            {
            navPoint->pointId = strdup(pointId);
            }else{
                navPoint->pointId = NULL;
            }
            if(playOrder!=NULL)
            {
            navPoint->playOrder = strdup(playOrder);
            }else{
                navPoint->playOrder =NULL;
            }
            if(src !=NULL)
                navPoint->src =strdup(( char*)src);
            else
                navPoint->src=NULL;
             if(text !=NULL)
            navPoint->text = strdup(( char*)text);
            else
                navPoint->text = NULL;
                
            navPoint->hasNext=FALSE;
            navPoint->hasChildren=FALSE;
            if (index ==0) {
                nextNavPoint = navPoint;
                if(parentNavPoint==NULL)
                {
                    parentNavPoint=nextNavPoint;
                }else{
                    parentNavPoint->children = nextNavPoint;
                    parentNavPoint->hasChildren=TRUE;
                    // g_printf("0父：%s子标题:%s\n",parentNavPoint->text,parentNavPoint->children->text);
                }
            }else    {
                nextNavPoint->next = navPoint;
                nextNavPoint->hasNext=TRUE;
                //  g_printf("父：%s子标题:%s\n",nextNavPoint->text,nextNavPoint->next->text);
                nextNavPoint=nextNavPoint->next ;
                
                TOPINDEX++;
            }
            index++;
            if(item->children)
            {
               // loop_child_navpoint(basePath,item->children, navPoint);
                [self loop_child_navpoint:basePath item:item->children navpoint:navPoint];
            }
        }
        item = item->next;
    }
    
}

-(BookNav *) bookNav{
    if(_epubDoc==nil)
    {
        return nil;
    }
    xmlDoc *xdoc = NULL;
    xmlNode *root_element = NULL;
    xmlNode *mnode = NULL;
    xmlNode *item = NULL;
    NSData *ncxData;
    BookNav * rootNav;
    BookNavPoint   *rootNavPoint = NULL;
    NSMutableDictionary *res=   [_epubDoc resource];
    NSEnumerator * enumeratorValue = [res objectEnumerator];
    //快速枚举遍历所有Value的值
    for (EpubResource *epubRes in enumeratorValue) {
        if([[epubRes mime] isEqualToString:@"application/x-dtbncx+xml"])
        {
            ncxData=[_epubDoc read:[epubRes href]];
            break;
        }
        // NSLog(@"遍历Value的值: %@",object);
    }
    
    if(ncxData!=nil)
    {
        NSLog(@"ncx length=%ld\n",[ncxData length]);
         xdoc = xmlRecoverMemory([ncxData bytes], [[NSNumber numberWithUnsignedInteger:[ncxData length]]intValue ]);
        root_element = xmlDocGetRootElement(xdoc);
        mnode = [self elementByTag:root_element tagname: "navMap"];
        
        if(mnode==NULL)
        {
            xmlFreeDoc(xdoc);
            return  NULL;
        }
        item = mnode->children;
       // g_printf("获取ncx文件6\n");
        rootNavPoint = malloc(sizeof(BookNavPoint));
        rootNavPoint->pointId = strdup("1");
        rootNavPoint->playOrder =strdup("1");
        rootNavPoint->src =strdup("");
        rootNavPoint->text = strdup("目录");
        rootNavPoint->hasNext=FALSE;
        rootNavPoint->hasChildren=FALSE;
        
         [self loop_child_navpoint:NULL item:item navpoint:rootNavPoint];
        //loop_child_navpoint(doc->content_base,item, rootNavPoint);
        //g_printf("准备打印：%s标题\n",rootNavPoint->text);
        //gepub_navPoint_print(rootNavPoint);
        //g_free(rootNavPoint);
        //g_printf("END\n");
        xmlFreeDoc(xdoc);
    }
    if(rootNavPoint->hasChildren)
    {
        rootNav=[BookNav loadBookNavPoint:rootNavPoint->children];
       // [BookNav freeBookNavPoint:rootNavPoint];
    }else{
        rootNav=nil;
    }
    
    return rootNav;
    
   
//    const char *data;
//    BookNavPoint   *rootNavPoint = NULL;
//
//    xdoc = xmlRecoverMemory([ncxData bytes], [ncxData length]);
//    root_element = xmlDocGetRootElement(xdoc);
//    xmlFreeDoc(xdoc);
//
//    return nil;
}

/*
-(void)dealloc{
    [_epubDoc dealloc];
}
 */
@end
