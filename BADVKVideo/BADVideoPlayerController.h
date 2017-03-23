//
//  BADVideoPlayerController.h
//  BADVKVideo
//
//  Created by Artem Belkov on 22/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BADVideo;

@interface BADVideoPlayerController : UIViewController

- (instancetype)initWithVideo:(BADVideo *)video;

@end
