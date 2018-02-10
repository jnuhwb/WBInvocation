//
//  NSObject+Invocation.h
//  WBInvocation
//
//  Created by wellbin on 2018/2/8.
//  Copyright © 2018年 wellbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (WBInvocation)

- (id)invocationSelector:(NSString *)selectorString, ...;

/**
 Table 6-1  Objective-C type encodings
 
 Code
 
 
 Meaning
 
 c
 
 
 A char
 
 i
 
 
 An int
 
 s
 
 
 A short
 
 l
 
 
 A long
 
 l is treated as a 32-bit quantity on 64-bit programs.
 
 q
 
 
 A long long
 
 C
 
 
 An unsigned char
 
 I
 
 
 An unsigned int
 
 S
 
 
 An unsigned short
 
 L
 
 
 An unsigned long
 
 Q
 
 
 An unsigned long long
 
 f
 
 
 A float
 
 d
 
 
 A double
 
 B
 
 
 A C++ bool or a C99 _Bool
 
 v
 
 
 A void
 
 *
 
 
 A character string (char *)
 
 @
 
 
 An object (whether statically typed or typed id)
 
 #
 
 
 A class object (Class)
 
 :
 
 
 A method selector (SEL)
 
 [array type]
 
 
 An array
 
 {name=type...}
 
 
 A structure
 
 (name=type...)
 
 
 A union
 
 bnum
 
 
 A bit field of num bits
 
 ^type
 
 
 A pointer to type
 
 ?
 
 
 An unknown type (among other things, this code is used for function pointers)
 */
- (id)invocationSelector:(NSString *)selectorString types:(NSArray *)types, ...;

- (NSInteger)integerInvocationSelector:(NSString *)selectorString types:(NSArray *)types, ...;

+ (id)invocationClass:(Class)cls selector:(NSString *)selectorString, ...;

@end
