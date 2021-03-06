//
//  BADViewController.m
//  BADVKVideo
//
//  Created by Artem Belkov on 17/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import "BADLoginViewController.h"
#import "BADAccessToken.h"

@interface BADLoginViewController () <UIWebViewDelegate>

@property (copy, nonatomic) BADLoginCompletionBlock completionBlock;
@property (weak, nonatomic) UIWebView *webView;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation BADLoginViewController

- (instancetype)initWithCompletionBlock:(void(^)(BADAccessToken *token))completionBlock {
    
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Setup views
    
    CGRect frame = self.view.bounds;
    frame.origin = CGPointZero;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:webView];
    self.webView = webView;
    
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
    
    // Add activity indicator
    
    CGFloat side = 50.f;
    CGFloat centerX = (self.view.frame.size.width - side) / 2;
    CGFloat centerY = (self.view.frame.size.height - side) / 2;

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(centerX, centerY, side, side)];
    activityIndicator.color = [UIColor colorWithRed:27 /255.f
                                              green:40 /255.f
                                               blue:54 /255.f
                                              alpha:1.0f];
    [self.view addSubview:activityIndicator];
    [self.view bringSubviewToFront:activityIndicator];
    self.activityIndicator = activityIndicator;
    
    [self.activityIndicator startAnimating];
        
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
    
    webView.delegate = self;
    
    [webView loadRequest:request];
}

- (void)dealloc {
    self.webView.delegate = nil;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
        
    if (([[[request URL] path] isEqualToString:@"/blank.html"]) && ([[[request URL] host] isEqualToString:@"oauth.vk.com"])) {
        
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
        
        self.webView.delegate = nil;
        
        if (self.completionBlock) {
            self.completionBlock(token);
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
        
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if (self.completionBlock) {
        self.completionBlock(nil);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
