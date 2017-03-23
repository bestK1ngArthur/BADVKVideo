//
//  BADViewController.h
//  BADVKVideo
//
//  Created by Artem Belkov on 17/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BADAccessToken;

typedef void(^BADLoginCompletionBlock)(BADAccessToken *token);

@interface BADLoginViewController : UIViewController

- (instancetype)initWithCompletionBlock:(BADLoginCompletionBlock) completionBlock;

@end
