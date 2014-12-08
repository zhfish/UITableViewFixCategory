//
//  UITableView+fix.m
//
//
//  Created by zhfish on 14/12/8.
//  Copyright (c) 2014年 zhfish. All rights reserved.
//

#import "UITableView+fix.h"
#import <objc/runtime.h>

@implementation UITableView (fix)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending))
        {
            Class class = [self class];
            
            // When swizzling a class method, use the following:
            // Class class = object_getClass((id)self);
            
            SEL originalSelector = @selector(setContentSize:);
            SEL swizzledSelector = @selector(fix_setContentSize:);
            
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            
            BOOL didAddMethod =
            class_addMethod(class,
                      
                            
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
            
            if (didAddMethod) {
                class_replaceMethod(class,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
        
    });
}

- (void)fix_setContentSize:(CGSize)contentSize
{
    [self fix_setContentSize:contentSize];
    if(self.tableFooterView)
    {
        CGRect frame = self.tableFooterView.frame;
        frame.origin.y = contentSize.height - CGRectGetHeight(frame);
        self.tableFooterView.frame = frame;
    }
}
@end
