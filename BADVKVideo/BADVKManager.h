//
//  BADVKManager.h
//  BADVKVideo
//
//  Created by Artem Belkov on 18/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BADVideo.h"
#import "BADAccessToken.h"
#import "BADAuthorizationController.h"

@interface BADVKManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)isUserAuthorized;

- (void)searchVideosWithQuery:(NSString *)query
                       offset:(NSInteger)offset
                        count:(NSInteger)count
                      success:(void (^)(NSArray *videos))success
                      failure:(void (^)(NSError *error))failure;
- (void)getPhotoForVideo:(BADVideo *)video
                withType:(BADVideoPhotoType)photoType
                 success:(void (^)(UIImage *image))success
                 failure:(void (^)(NSError *error))failure;

- (void)saveAccessToken:(BADAccessToken *)accessToken;

@end
