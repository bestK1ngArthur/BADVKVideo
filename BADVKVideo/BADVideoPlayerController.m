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
    
    // Make video request
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.video.URL];
    
    webView.delegate = self;
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
