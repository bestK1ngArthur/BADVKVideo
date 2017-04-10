//
//  BADViewController.m
//  BADVKVideo
//
//  Created by Artem Belkov on 17/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import "BADAuthorizationController.h"
#import "BADVKManager.h"

@interface BADAuthorizationController () <UIWebViewDelegate>

@property (weak, nonatomic) UIWebView *webView;

@end

@implementation BADAuthorizationController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Setup views
    
    CGRect frame = self.view.bounds;
    frame.origin = CGPointZero;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:webView];
    self.webView = webView;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                          target:self
                                                                          action:@selector(actionCancel:)];
    [self.navigationItem setRightBarButtonItem:item animated:NO];
    self.navigationItem.title = @"Авторизация";
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor colorWithRed:227 /255.f
                                                      green:228 /255.f
                                                       blue:329 /255.f
                                                      alpha:1.f]}];
    
    self.webView.backgroundColor = [UIColor colorWithRed:27 /255.f
                                                   green:40 /255.f
                                                    blue:54 /255.f
                                                   alpha:1.0f];
    self.webView.delegate = self;
    [self startAuthorization];
}

- (void)startAuthorization {
    
    // Make authorisation request
    
    NSString *urlString = @"https://oauth.vk.com/authorize?"
    "client_id=5932938&"
    "scope=16&" // + 16 (video access)
    "redirect_uri=&"
    "display=touch&"
    "v=5.52&"
    "response_type=token";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

- (void)dealloc {
    self.webView.delegate = nil;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (([[[request URL] path] isEqualToString:@"/blank.html"]) && ([[[request URL] host] isEqualToString:@"oauth.vk.com"])) {
        
        // Parsing token
        
        BADAccessToken *token = [[BADAccessToken alloc] init];
        NSString *query = [[request URL] description];
        
        NSArray *array = [query componentsSeparatedByString:@"#"];
        
        if ([array count] > 1) {
            query = [array lastObject];
        }
        
        NSArray *pairs = [query componentsSeparatedByString:@"&"];
        for (NSString *pair in pairs) {
            NSArray *values = [pair componentsSeparatedByString:@"="];
            if ([values count] == 2) {
                NSString *key = [values firstObject];
                if ([key isEqualToString:@"access_token"]) {
                    token.token = [values lastObject];
                } else if ([key isEqualToString:@"expires_in"]) {
                    NSTimeInterval interval = [[values lastObject] doubleValue];
                    token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                } else if ([key isEqualToString:@"user_id"]) {
                    token.userID = [values lastObject];
                }
            }
        }
        
        BOOL authorized = false;
        
        if (token.token) {
            authorized = true;
            [[BADVKManager sharedManager] saveAccessToken:token]; // Saving token to BADVKManager
        }
        
        [self.delegate authorizationDidFinsished:authorized]; // Finishing authorization
        self.webView.delegate = nil;
        [self dismissViewControllerAnimated:YES completion:nil]; // Close authorization controller
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Actions 

- (void)actionCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
