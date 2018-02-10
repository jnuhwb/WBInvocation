//
//  NSObject+Invocation.m
//  WBInvocation
//
//  Created by wellbin on 2018/2/8.
//  Copyright © 2018年 wellbin. All rights reserved.
//

#import "NSObject+WBInvocation.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation NSObject (WBInvocation)

- (id)invocationSelector:(NSString *)selectorString, ... {
    SEL aSelector = NSSelectorFromString(selectorString);
    if (!aSelector) return nil;
    
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:aSelector];
    if (!sig) {
        NSLog(@"target %@ unrecognized selector %@", self, NSStringFromSelector(aSelector));
        return nil;
    }
    
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setTarget:self];
    [inv setSelector:aSelector];
    
    NSUInteger argCount = [sig numberOfArguments] - 2; //overcome self _cmd
    if (argCount > 0) {
        NSMutableArray *argArr = [NSMutableArray new];
        va_list list;
        va_start(list, selectorString);
        id arg = nil;
        for (NSInteger i=0; i<argCount; i++) {
            arg = va_arg(list, id);
            [argArr addObject:arg];
        }
        va_end(list);
        
        if (argArr.count == argCount) {
            for (NSInteger i=0; i<argCount; i++) {
                id obj = argArr[i];
                if (![obj isKindOfClass:[NSNull class]]) {
                    [inv setArgument:&obj atIndex:i+2];//notice +2
                }
            }
        } else {
            NSLog(@"parameters count does not fit the selector");
            return nil;
        }
    }
    
    [inv invoke];
    
    __unsafe_unretained id ret;
    if (sig.methodReturnLength > 0) {
        [inv getReturnValue:&ret];
    }
    return ret;
}

//An array of characters that describe the types of the arguments to the method. For possible values, see Objective-C Runtime Programming Guide > Type Encodings. Since the function must take at least two arguments—self and _cmd, the second and third characters must be “@:” (the first character is the return type).
- (NSInvocation *)__doInvocationSelector:(NSString *)selectorString types:(NSArray *)types parameters:(va_list)list {
    SEL aSelector = NSSelectorFromString(selectorString);
    if (!aSelector) return nil;
    
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:aSelector];
    if (!sig) {
        NSLog(@"target %@ unrecognized selector %@", self, NSStringFromSelector(aSelector));
        return nil;
    }
    
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setTarget:self];
    [inv setSelector:aSelector];
    
    NSUInteger argCount = [sig numberOfArguments] - 2; //overcome self _cmd
    if (argCount > 0) {
        if (types.count == argCount) {
            for (NSInteger i=0; i<argCount; i++) {
                NSString *type = types[i];
                const char *cs = [type cStringUsingEncoding:NSUTF8StringEncoding];
                switch (*cs) {
                    case 'c': {
                        char v = va_arg(list, int);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case 'i': {
                        int v = va_arg(list, int);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case 's': {
                        short v = va_arg(list, int);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case 'l': {
                        long v = va_arg(list, long);
                        
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case 'q': {
                        long long v = va_arg(list, long long);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case 'C': {
                        unsigned char v = va_arg(list, int);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case 'I': {
                        unsigned int v = va_arg(list, unsigned int);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case 'S': {
                        unsigned short v = va_arg(list, int);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case 'L': {
                        unsigned long v = va_arg(list, unsigned long);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case 'Q': {
                        unsigned long long v = va_arg(list, unsigned long long);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case 'f': {
                        float v = va_arg(list, double);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case 'd': {
                        double v = va_arg(list, double);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case 'B': {
                        _Bool v = va_arg(list, int);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case '*': {
                        char * v = va_arg(list, char *);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case '@': {
                        id v = va_arg(list, id);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case '#': {
                        Class v = va_arg(list, Class);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case ':': {
                        SEL v = va_arg(list, SEL);
                        [inv setArgument:&v atIndex:i+2];
                        break;
                    }
                    case '{': {
                        if ([type isEqualToString:@"{CGSize=ff}"]
                            || [type isEqualToString:@"{CGSize=dd}"]) {
                            CGSize v = va_arg(list, CGSize);
                            [inv setArgument:&v atIndex:i+2];
                        } else if ([type isEqualToString:@"{CGPoint=ff}"]
                                   || [type isEqualToString:@"{CGPoint=dd}"]) {
                            CGPoint v = va_arg(list, CGPoint);
                            [inv setArgument:&v atIndex:i+2];
                        } else if ([type isEqualToString:@"{CGRect={CGPoint=ff}{CGSize=ff}}"]
                                   || [type isEqualToString:@"{CGRect={CGPoint=dd}{CGSize=dd}}"]) {
                            CGRect v = va_arg(list, CGRect);
                            [inv setArgument:&v atIndex:i+2];
                        } else if ([type isEqualToString:@"{CGAffineTransform=ffffff}"]
                                   || [type isEqualToString:@"{CGAffineTransform=dddddd}"]) {
                            CGAffineTransform v = va_arg(list, CGAffineTransform);
                            [inv setArgument:&v atIndex:i+2];
                        } else if ([type isEqualToString:@"{UIEdgeInsets=ffff}"]
                                   || [type isEqualToString:@"{UIEdgeInsets=dddd}"]) {
                            UIEdgeInsets v = va_arg(list, UIEdgeInsets);
                            [inv setArgument:&v atIndex:i+2];
                        } else if ([type isEqualToString:@"{UIOffset=ff}"]
                                   || [type isEqualToString:@"{UIOffset=dd}"]) {
                            UIOffset v = va_arg(list, UIOffset);
                            [inv setArgument:&v atIndex:i+2];
                        } else {
                            NSLog(@"unsupport parameter type");
                            return nil;
                        }
                        break;
                    }
                        
                    default: {
                        NSLog(@"unsupport parameter type");
                        return nil;
                    }
                }
            }
        } else {
            NSLog(@"types count does not fit the selector");
            return nil;
        }
    }
    
    [inv invoke];
    return inv;
}

- (id)invocationSelector:(NSString *)selectorString types:(NSArray *)types, ... {
    __unsafe_unretained id ret = nil;
    va_list list;
    va_start(list, types);
    NSInvocation *inv = [self __doInvocationSelector:selectorString types:types parameters:list];
    va_end(list);
    if (inv) {
        [inv getReturnValue:&ret];
    }
    return ret;
}

- (NSInteger)integerInvocationSelector:(NSString *)selectorString types:(NSArray *)types, ... {
    NSInteger ret = 0;
    va_list list;
    va_start(list, types);
    NSInvocation *inv = [self __doInvocationSelector:selectorString types:types parameters:list];
    va_end(list);
    if (inv) {
        [inv getReturnValue:&ret];
    }
    return ret;
}

#pragma mark - Class
+ (id)invocationClass:(Class)cls selector:(NSString *)selectorString, ... {
    SEL aSelector = NSSelectorFromString(selectorString);
    if (!cls || !aSelector) return nil;
    
    NSMethodSignature *sig = [cls methodSignatureForSelector:aSelector];
    
    if (!sig) {
        NSLog(@"class %@ unrecognized selector %@", cls, NSStringFromSelector(aSelector));
        return nil;
    }
    
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setTarget:cls];
    [inv setSelector:aSelector];
    
    NSUInteger argCount = [sig numberOfArguments] - 2; //overcome self _cmd
    if (argCount > 0) {
        NSMutableArray *argArr = [NSMutableArray new];
        va_list list;
        va_start(list, selectorString);
        id arg = nil;
        for (NSInteger i=0; i<argCount; i++) {
            arg = va_arg(list, id);
            [argArr addObject:arg];
        }
        va_end(list);
        
        if (argArr.count == argCount) {
            for (NSInteger i=0; i<argCount; i++) {
                id obj = argArr[i];
                if (![obj isKindOfClass:[NSNull class]]) {
                    [inv setArgument:&obj atIndex:i+2];//notice +2
                }
            }
        } else {
            NSLog(@"parameters count does not fit the selector");
            return nil;
        }
    }
    
    [inv invoke];
    
    __unsafe_unretained id ret;
    if (sig.methodReturnLength > 0) {
        [inv getReturnValue:&ret];
    }
    return ret;
}
@end
