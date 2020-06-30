//
//  epub-archive.m
//  epub_test
//
//  Created by ljc on 2018/10/22.
//


#import "epub-archive.h"
#import "archive.h"
#import "archive_entry.h"


@implementation EpubArchive

-(void) testArchive:(NSString *)path
{
    NSLog(@"zip文件路径：%@",path);
   
    const char *filename=[path UTF8String];
    struct archive *a;
    struct archive_entry *entry;
    int r;
    NSLog(@"文件路径：%s",filename);
    a = archive_read_new();
    
    archive_read_support_format_zip(a);
   
   
    if ((r = archive_read_open_filename(a, filename, 10240)))
        NSLog(@"archive_read_open_filename():%s,%d",
             archive_error_string(a), r);
    
    while (archive_read_next_header(a, &entry)==ARCHIVE_OK)
    {
         NSLog(@"pathName=%s",archive_entry_pathname(entry));
    }
    //else{
      //  NSLog(@"error=%s", archive_error_string(a));
    //}
    /*
    for (;;) {
        r = archive_read_next_header(a, &entry);
        if (r == ARCHIVE_EOF)
            break;
        if (r != ARCHIVE_OK)
             NSLog(@"archive_read_next_header():%s,%d",
                 archive_error_string(a), 1);
        
            NSLog(@"pathName=%s",archive_entry_pathname(entry));
        
    }
    */
    archive_read_close(a);
  //  archive_read_free(a);
   
}

@end
