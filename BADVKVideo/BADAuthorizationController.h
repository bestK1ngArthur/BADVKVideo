//
//  BADViewController.h
//  BADVKVideo
//
//  Created by Artem Belkov on 17/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BADAuthorizationDelegate <NSObject>

- (void)authorizationDidFinsished:(BOOL)isAuthorized;

@end

@interface BADAuthorizationController : UIViewController

@property (nonatomic, retain) id <BADAuthorizationDelegate> delegate;

- (void)startAuthorization;

@end
