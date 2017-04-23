//
//  BADVideoPlayerController.m
//  BADVKVideo
//
//  Created by Artem Belkov on 22/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import "BADVideoPlayerController.h"

#import "BADVideo.h"

@interface BADVideoPlayerController () <UIWebViewDelegate>

@property (strong, nonnull) BADVideo *video;

@property (weak, nonatomic) UIWebView *webView;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;


@end

@implementation BADVideoPlayerController

- (instancetype)initWithVideo:(BADVideo *)video {
    self = [super init];
    if (self) {
        self.video = video;
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
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor colorWithRed:227 /255.f
                                                      green:228 /255.f
                                                       blue:329 /255.f
                                                      alpha:1.f]}];
    
    self.navigationItem.title = self.video.title;
    
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
    
    // Make video request
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.video.URL];
    
    webView.delegate = self;
    [webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    [self.activityIndicator startAnimating];
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self.activityIndicator stopAnimating];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
