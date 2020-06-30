//
//  book-mobi.m
//  book
//
//  Created by ljc on 2018/9/18.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import "Book-mobi.h"
#import "mobi.h"
#import "index.h"
#include "parse_rawml.h"

@implementation BookMobi{
    NSString * _bookFilePath;
    MOBIData * _data;
    MOBIRawml * _rawml;
    BookNav * _bookNav;
    NSString *_title;
    NSString *_author;
    NSString *_bookId;
}

 

- (id) initWithPath:(NSString*)bookPath{
    if((self=[super init])){
        _rawml=NULL;
        _data=NULL;
        _bookNav=NULL;
        _title=nil;
        _author=nil;
        _bookFilePath=bookPath;
        _data = mobi_init();
        FILE *file=fopen([_bookFilePath UTF8String],"rb");
        if (file == NULL) {
            mobi_free(_data);
            _data=NULL;
            return self;
        }
        
        MOBI_RET mobi_ret = mobi_load_file(_data, file);
        fclose(file);
        if (mobi_ret != MOBI_SUCCESS) {
            mobi_free(_data);
            _data=NULL;
            return self;
        }
        
    }
    return self;
}
-(MOBIRawml *) mobiRawml{
    if(_rawml!=NULL)
    {
        return _rawml;
    }else if(_data!=NULL){
          _rawml = mobi_init_rawml(_data);
        if(_rawml!=NULL)
        {
            MOBI_RET mobi_ret = mobi_parse_rawml(_rawml, _data);
            if (mobi_ret != MOBI_SUCCESS) {
                mobi_free_rawml(_rawml);
                _rawml=NULL;
            }
        }
    }
    return _rawml;
}

-(size_t) chapterCount{
     size_t chapterNum = 0;
    MOBIRawml *rawml=[self mobiRawml];
    if(rawml!=NULL && rawml->markup != NULL)
    {
        if(rawml->skel==NULL)
        {
            chapterNum=1;
        }else{
            chapterNum=rawml->skel->entries_count;
        }
    }
    return chapterNum;
}

-(NSString *) title{
    if(_title)
    {
        return _title;
    }
    if(_data)
    {
        char * bookTitle=mobi_meta_get_title(_data);
        if(bookTitle!=NULL)
        {
            _title= [NSString stringWithUTF8String:bookTitle];
        }
    }
    return _title;
   
}

-(NSString *) author{
    if(_author)
    {
        return _author;
    }
    if(_data)
    {
        char * bookAuthor=mobi_meta_get_author(_data);
        if(bookAuthor!=NULL)
        {
            _author= [NSString stringWithUTF8String:bookAuthor];
        }
    }
    return _author;
}

-(NSString *) bookId{
    if(_bookId)
    {
        return _bookId;
    }
    if(_data)
    {
        char *bookasin=mobi_meta_get_asin(_data);
        if(bookasin!=NULL)
        {
             _bookId=[NSString stringWithUTF8String:bookasin];
        }else if(_data->mh->uid)
        {
            _bookId=[NSString stringWithFormat:@"%u" ,*_data->mh->uid];
        }else{
           
            char * mybookId=mobi_meta_get_isbn(_data);
            if(mybookId!=NULL)
            {
                _bookId=[NSString stringWithUTF8String:mybookId];
            }
        }
    }
    return _bookId;
}

-(BookChapter *) chapter:(size_t)index{
   
    if(_data==NULL)
    {
        return nil;
    }
   
    MOBIRawml *rawml=[self mobiRawml];
    size_t chapterNum=[self chapterCount];
    
    if(rawml!=NULL && index>=0 && index < chapterNum)
    {
        MOBIPart *curr = mobi_get_part_by_uid(rawml, index);
        if (curr != NULL && curr->size > 0) {
            BookChapter *bookChapter=[[BookChapter alloc] init];
            MOBIFileMeta file_meta = mobi_get_filemeta_by_type(curr->type);
            [bookChapter setMime:[NSString stringWithUTF8String:file_meta.mime_type]];
            [bookChapter setData:[NSData dataWithBytes:curr->data length:curr->size]];
            [bookChapter setSpineIndex:(int)index];
            return bookChapter;
        }
    }
    return nil;
}

-(BookChapter *) resource:(NSString *)url{
    if(_data==NULL)
    {
        return nil;
    }
    
    MOBIRawml *rawml=[self mobiRawml];
    if(!url || rawml==NULL)
    {
        return  nil;
    }
    if( [url hasPrefix:@"resource"])
    {
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        NSString * strInt=[url substringWithRange:NSMakeRange(8,5)];
        unsigned long part_id= [[formatter numberFromString:strInt] unsignedLongValue];
        NSLog(@"resource strInt=%@, part_id=%ld",strInt,part_id);
        MOBIPart *curr = mobi_get_resource_by_uid(rawml, part_id);
        
        if (curr != NULL && curr->size > 0) {
            BookChapter *bookChapter=[[BookChapter alloc] init];
            
            MOBIFileMeta file_meta = mobi_get_filemeta_by_type(curr->type);
            [bookChapter setMime:[NSString stringWithUTF8String:file_meta.mime_type]];
            [bookChapter setData:[NSData dataWithBytes:curr->data length:curr->size]];
            [bookChapter setSpineIndex:(int)index];
            return bookChapter;
        }else{
            return nil;
        }
    }
    if([url hasPrefix:@"flow"])
    {
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        unsigned long part_id= [[formatter numberFromString:[url substringWithRange:NSMakeRange(4,5)]] unsignedLongValue];
        NSLog(@"flow part_id=%ld",part_id);
        MOBIPart *curr = mobi_get_flow_by_uid(rawml, part_id);
        if (curr != NULL && curr->size > 0) {
            BookChapter *bookChapter=[[BookChapter alloc] init];
            MOBIFileMeta file_meta = mobi_get_filemeta_by_type(curr->type);
            [bookChapter setMime:[NSString stringWithUTF8String:file_meta.mime_type]];
            [bookChapter setData:[NSData dataWithBytes:curr->data length:curr->size]];
            [bookChapter setSpineIndex:(int)index];
            return bookChapter;
        }else{
            return nil;
        }
    }
    if([url hasPrefix:@"part"])
    {
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        
        unsigned long part_id= [[formatter numberFromString:[url substringWithRange:NSMakeRange(4,5)]] unsignedLongValue];
        MOBIPart *curr = mobi_get_part_by_uid(rawml, part_id);
        if (curr != NULL && curr->size > 0) {
            BookChapter *bookChapter=[[BookChapter alloc] init];
            MOBIFileMeta file_meta = mobi_get_filemeta_by_type(curr->type);
            [bookChapter setMime:[NSString stringWithUTF8String:file_meta.mime_type]];
            [bookChapter setData:[NSData dataWithBytes:curr->data length:curr->size]];
            [bookChapter setSpineIndex:(int)index];
            return bookChapter;
        }
    }
    return nil;
}


BookNavPoint * book_nav_get_last(BookNavPoint * nav)
{
    if (nav == NULL) {
        return nav;
    }else{
        if (nav->hasNext) {
            return book_nav_get_last(nav->next);
        }else{
            return nav;
        }
    }
}

void book_nav_add_child(BookNavPoint * parentNav, BookNavPoint * childNav)
{
    if (parentNav != NULL && parentNav != childNav) {
        if (parentNav->hasChildren) {
            BookNavPoint * lastNav = book_nav_get_last(parentNav->children);
            lastNav->hasNext = TRUE;
            lastNav->next = childNav;
        }else{
            parentNav->hasChildren = TRUE;
            parentNav->children = childNav;
        }
    }
}


-(BookNav *) bookNav{
    if(_bookNav!=NULL)
    {
        return _bookNav;
    }
    if(_data==NULL)
    {
        return nil;
    }
    
    MOBIRawml *rawml=[self mobiRawml];
    if(rawml==NULL)
    {
        return  nil;
    }
    if(!(rawml->ncx))
    {
        return nil;
    }
    const size_t count = rawml->ncx->entries_count;
    size_t i = 0;
    if (count < 1) {
        return nil;
    }
    MOBI_RET ret;
    BookNavPoint *ncx = malloc(count * sizeof(BookNavPoint));
    while (i < count) {
        const MOBIIndexEntry *ncx_entry = &rawml->ncx->entries[i];
        const char *label = ncx_entry->label;
        const size_t labelId = strtoul(label, NULL, 16);
        uint32_t cncx_offset;
        ret = mobi_get_indxentry_tagvalue(&cncx_offset, ncx_entry, INDX_TAG_NCX_TEXT_CNCX);
        const MOBIPdbRecord *cncx_record = rawml->ncx->cncx_record;
        char *text = mobi_get_cncx_string_utf8(cncx_record, cncx_offset, rawml->ncx->encoding);
        char *target = malloc(MOBI_ATTRNAME_MAXSIZE + 1);
        if (mobi_is_rawml_kf8(rawml)) {
            uint32_t posfid;
            ret = mobi_get_indxentry_tagvalue(&posfid, ncx_entry, INDX_TAG_NCX_POSFID);
            
            uint32_t posoff;
            ret = mobi_get_indxentry_tagvalue(&posoff, ncx_entry, INDX_TAG_NCX_POSOFF);
            
            uint32_t filenumber;
            char targetid[MOBI_ATTRNAME_MAXSIZE + 1];
            ret = mobi_get_id_by_posoff(&filenumber, targetid, rawml, posfid, posoff);
            if (posoff) {
                snprintf(target, MOBI_ATTRNAME_MAXSIZE + 1, "part%05u.html#%s", filenumber, targetid);
            } else {
                snprintf(target, MOBI_ATTRNAME_MAXSIZE + 1, "part%05u.html", filenumber);
            }
        } else {
            uint32_t filepos;
            ret = mobi_get_indxentry_tagvalue(&filepos, ncx_entry, INDX_TAG_NCX_FILEPOS);
            
            snprintf(target, MOBI_ATTRNAME_MAXSIZE + 1, "part00000.html#%010u", filepos);
        }
        uint32_t level;
        ret = mobi_get_indxentry_tagvalue(&level, ncx_entry, INDX_TAG_NCX_LEVEL);
        uint32_t parent = MOBI_NOTSET;
        ret = mobi_get_indxentry_tagvalue(&parent, ncx_entry, INDX_TAG_NCX_PARENT);
        uint32_t first_child = MOBI_NOTSET;
        ret = mobi_get_indxentry_tagvalue(&first_child, ncx_entry, INDX_TAG_NCX_CHILD_START);
        uint32_t last_child = MOBI_NOTSET;
        ret = mobi_get_indxentry_tagvalue(&last_child, ncx_entry, INDX_TAG_NCX_CHILD_END);
        
        char str_int[11 ];
        snprintf(str_int, 11, "%zu", labelId);
        
        ncx[i] = (BookNavPoint) {text, str_int, str_int, target, FALSE, FALSE, NULL, NULL };
        if (level == 0) {
            if (i > 0) {
                BookNavPoint *lastNav = book_nav_get_last(&ncx[0]);
                lastNav->hasNext = TRUE;
                lastNav->next = &ncx[i];
            }
        }else if (level > 0) {
            book_nav_add_child(&ncx[parent], &ncx[i]);
        }
        i++;
    }
    BookNav * rootNav=[BookNav loadBookNavPoint:ncx];
    free(ncx);
    ncx=NULL;
   //[BookNav freeBookNavPoint:ncx];
    return rootNav;
}
- (void)dealloc
{ 
    mobi_free(_data);
     _bookFilePath=nil;
    if(_rawml!=NULL)
    {
        mobi_free_rawml(_rawml);
    }
    if(_bookNav!=NULL)
    {
        _bookNav=nil;
    }
    _title=nil;
    _author=nil;
    
    NSLog(@"BookMobi对象被回收");
    
}
 


@end
