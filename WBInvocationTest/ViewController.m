//
//  ViewController.m
//  WBInvocationTest
//
//  Created by wellbin on 2018/2/10.
//  Copyright © 2018年 wellbin. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+WBInvocation.h"
#import <dlfcn.h>

@interface ViewController ()

@property (nonatomic) id webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
#if TARGET_IPHONE_SIMULATOR
        NSString *frameworkPath = [[NSProcessInfo processInfo] environment][@"DYLD_FALLBACK_FRAMEWORK_PATH"];
        if (frameworkPath) {
            NSString *webkitLibraryPath = [NSString pathWithComponents:@[frameworkPath, @"WebKit.framework", @"WebKit"]];
            dlopen([webkitLibraryPath cStringUsingEncoding:NSUTF8StringEncoding], RTLD_LAZY);
        }
#else
        dlopen("/System/Library/Frameworks/WebKit.framework/WebKit", RTLD_LAZY);
#endif
    }
        
    id cfg = [NSClassFromString(@"WKWebViewConfiguration") new];
    id userContentController = [NSClassFromString(@"WKUserContentController") new];
    [userContentController invocationSelector:@"addScriptMessageHandler:name:", self, @"handler"];
    [cfg setValue:userContentController forKey:@"userContentController"];
    self.webView = [[NSClassFromString(@"WKWebView") alloc] invocationSelector:@"initWithFrame:configuration:" types:@[[NSString stringWithUTF8String:@encode(CGRect)], @"@"], self.view.bounds, cfg];
    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com"]]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
