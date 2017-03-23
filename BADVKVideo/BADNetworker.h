//
//  BADNetworker.h
//  BADVKVideo
//
//  Created by Artem Belkov on 17/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BADNetworker : NSObject 

+ (instancetype)networker;
+ (instancetype)networkerWithBaseURL:(NSURL *)url;

// -> JSON

- (void)GET:(NSString *)apiMethod parameters:(NSDictionary *)parameters success:(void (^)(NSDictionary * _Nullable response))success failure:(void (^)(NSError * _Nullable error))failure;

// -> Files

- (void)downloadImageWithURL:(NSURL *)url success:(void (^)(UIImage * _Nullable image))success failure:(void (^)(NSError * _Nullable error))failure;

@end

NS_ASSUME_NONNULL_END
