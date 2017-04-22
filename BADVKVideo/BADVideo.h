//
//  BADVideo.h
//  BADVKVideo
//
//  Created by Artem Belkov on 19/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BADVideo : NSObject

@property (assign, nonatomic) NSInteger ID;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *fullDescription;
@property (assign, nonatomic) NSInteger duration;

@property (strong, nonatomic) NSURL *photoURL;
@property (strong, nonatomic) NSURL *URL;

- (instancetype)initWithResponse:(NSDictionary *)response;

- (NSString *)durationString;

@end
