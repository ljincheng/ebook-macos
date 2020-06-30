//
//  epub-doc.m
//  epub
//
//  Created by ljc on 2018/11/11.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "epub-doc.h"
#import "epub-archive.h"
#import "epub-resource.h"




@implementation EpubDoc{
    EpubArchive * _epubArchive;
    char * _rootfile;
    NSMutableDictionary *_resource;
    NSMutableArray *_spine;
    NSString * _contentBase;
    NSData *_content;
}



-(id) initWithPath:(const char *) path{
    self=[super init];
    if(self)
    {
        _epubArchive=[[EpubArchive alloc]initWithPath:path];
        _rootfile= [_epubArchive rootFile];
      //  NSLog(@"rootFile=%s\n",_rootfile);
        _content=[_epubArchive readEntry:_rootfile];
      //  NSLog(@"rootFile content=%@\n",_content);
      
        //计算基础目录
        unsigned long len = strlen(_rootfile);
        unsigned long i=0;
        char *basePath=strdup("");
        for (i = 0; i < len; i++) {
            if (_rootfile[i] == '/') {
                free(basePath);
                basePath = strndup(_rootfile, i + 1);
                break;
            }
        }
        _contentBase=[NSString stringWithUTF8String:basePath];
       _spine= [_epubArchive fillSpine:_content];
        _resource=[_epubArchive fillResource:_content contentBase:_contentBase];
    }
    return self;
}

-(NSMutableArray *) spine{
    return _spine;
}
-(NSMutableDictionary *) resource{
    return _resource;
}

-(NSData *) read:(NSString *)href{
    const char *fullpath=[href UTF8String];
    NSData *data= [_epubArchive readEntry:fullpath];
    return data;
}


-(NSString *) metadata:(const char *)metadata{
    NSString * meta=[_epubArchive contentMetadata:_content metadata:metadata];
    return meta;
}
-(void) dealloc{
    
    free(_rootfile);
    
}
-(NSString *) contentBase{
    return _contentBase;
}



@end


