//
//  BookReadToolbar.m
//  book
//
//  Created by ljc on 2018/10/23.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/NSResponder.h>
#import "BookReadWindow.h"
#import "BookWindow.h"
@implementation BookReadWindow{
//    NSResponder *mNextResponder;
    BookWindow *mBookWindow;
}

-(void) setBookWindow:(id)bookWindow{
    mBookWindow=bookWindow;
}

-(void) keyDown:(NSEvent *)event{
   
    NSLog(@"=bookReadWindow keyDown  ===== %@",event);
   // [self showResponderInfo];
    if(mBookWindow!=nil)
    {
        [mBookWindow keyDown:event];
    }else{
     [super keyDown:event];
    }
}

-(void) showResponderInfo{
    
          NSResponder *responder=self.firstResponder;
    int index=0;
    while (responder) {
        NSLog(@"%d responder -%@",index,responder);
        index++;
        responder=responder.nextResponder;
        
    }
//    if(mNextResponder!=nil)
//    {
//        [self setNextResponder:mNextResponder];
//    }
    
}

//- (void)mouseMoved:(NSEvent *)event{
//#pragma unused(event)
//        NSPoint point=event.locationInWindow;
//         NSLog(@"BookReadToolbar mouseMoved x=%f,y=%f",point.x,point.y);
//    //    NSPoint point = [NSEvent mouseLocation];
//    //    NSLog(@"curPoint,x=%f,y=%f",point.x,point.y);
//}

//如果按下的是快捷键，系统会在当前活动的window内发送performKeyEquivalent:消息，window依次遍历它的子视图
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    if(mBookWindow!=nil)
    {
        return [mBookWindow performKeyEquivalent:theEvent];
    }
    return [super performKeyEquivalent:theEvent];
//    NSString  *characters = [theEvent charactersIgnoringModifiers];
//    NSLog(@"=== 快捷键：%@",characters);
//      if ([characters isEqual:@"l"]) {
////        [self performClick:self];
//        return YES;
//    }
//    if ([characters isEqual:@"w"]) {
//        //        [self performClick:self];
//        return YES;
//    }
    //return YES;
}

@end
