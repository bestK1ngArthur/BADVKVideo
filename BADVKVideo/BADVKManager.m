//
//  BADVKManager.m
//  BADVKVideo
//
//  Created by Artem Belkov on 18/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import "BADVKManager.h"
#include "BADLoginViewController.h"

#include "BADNetworker.h"

#include "BADAccessToken.h"
#include "BADKeychainWrapper.h"

static NSString * const vkAPIURL = @"https://api.vk.com/method/";
static NSString * const vkAPIVersion = @"5.52";

static NSString * const vkAPIAccessToken = @"vkAPIToken";
static NSString * const vkAPIAccessTokenDate = @"vkAPITokenDate";
static NSString * const vkAPIAccessTokenUser = @"vkAPITokenUser";

@interface BADVKManager ()

@property (strong, nonatomic) BADNetworker *networker;
@property (strong, nonatomic) BADAccessToken *accessToken;

@property (strong, nonatomic) BADKeychainWrapper *keychainWrapper;

@end

#warning Put parsing to back thread

@implementation BADVKManager

+ (instancetype)sharedManager {
    static BADVKManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.networker = [BADNetworker networkerWithBaseURL:[NSURL URLWithString:vkAPIURL]];
        self.keychainWrapper = [[BADKeychainWrapper alloc] init];
        self.accessToken = [[BADAccessToken alloc] init];
    }
    return self;
}

#pragma mark - Keychain

- (void)saveAccessToken {
 
    if(self.accessToken) {
        
        [self.keychainWrapper setObject:self.accessToken.token forKey:(id)kSecValueData];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.accessToken.expirationDate forKey:vkAPIAccessTokenDate];
        [[NSUserDefaults standardUserDefaults] setObject:self.accessToken.userID forKey:vkAPIAccessTokenUser];
    }
}

- (void)getAccessToken {
    
    NSString *token = [self.keychainWrapper objectForKey:(id)kSecValueData];
    
    if (![token isEqualToString:@"password"]) {
        self.accessToken.token = token;
    }
    
    self.accessToken.expirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:vkAPIAccessTokenDate];
    self.accessToken.userID = [[NSUserDefaults standardUserDefaults] objectForKey:vkAPIAccessTokenUser];
}

#pragma mark - Requests

- (void)authorizeUserWithCompletion:(void(^)(bool isAuthorised))completion {
    
    // [self getAccessToken];
    
    if (self.accessToken) { // if token exist
        if (self.accessToken.isValid) { // if token is valid
            completion(true);
            return;
        } else {
            [self presentLoginControllerWithCompletion:^(BADAccessToken * _Nonnull token) {
                if (token) {
                    self.accessToken = token;
                    // [self saveAccessToken];
                    completion(true);
                } else if (completion) {
                    completion(false);
                }
            }];
        }
    } else {
        [self presentLoginControllerWithCompletion:^(BADAccessToken * _Nonnull token) {
            if (token) {
                self.accessToken = token;
                // [self saveAccessToken];
                completion(true);
            } else if (completion) {
                completion(false);
            }
        }];
    }
}

- (void)presentLoginControllerWithCompletion:(void(^)(BADAccessToken *token))completion {
    
    BADLoginViewController *loginController = [[BADLoginViewController alloc] initWithCompletionBlock:completion];
    
    // Present login controller from root
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginController];
    UIViewController *mainController = [[UIApplication sharedApplication].keyWindow rootViewController];
    [mainController presentViewController:navigationController animated:YES completion:nil];
}

- (void)searchVideosWithQuery:(NSString *)query
                      offset:(NSInteger)offset
                       count:(NSInteger)count
                     success:(void (^)(NSArray *videos))success
                     failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                query, @"q",
                                @(2), @"sort", // sorted by relevance (2)
                                @(offset), @"offset",
                                @(count), @"count", nil];
    
    [self.networker GET:@"video.search"
             parameters:[self parametersWithSettings:parameters]
                success:^(NSDictionary * _Nullable response) {
                    
                    if ([[response allKeys] containsObject:@"error"]) { // if error
                        
                        NSDictionary *errorDict = [response objectForKey:@"error"];
                        NSError *error = [NSError errorWithDomain:vkAPIURL
                                                             code:[[errorDict objectForKey:@"error_code"] intValue]
                                                         userInfo:@{NSLocalizedDescriptionKey:[errorDict objectForKey:@"error_msg"]}];
                        
                        if (failure) {
                            failure(error);
                        }
                    } else {
                        
                        // Parse videos
                        NSArray *items = [[response objectForKey:@"response"] objectForKey:@"items"];
                        NSMutableArray *videos = [NSMutableArray array];
                        
                        for (NSDictionary *item in items) {
                            BADVideo *video = [[BADVideo alloc] initWithResponse:item];
                            [videos addObject:video];
                        }
                        
                        if (success) {
                            success(videos);
                        }
                    }
                }
                failure:^(NSError * _Nullable error) {
                    
                    if (failure) {
                        failure(error);
                    }
                }];
}

- (void)getPhotoForVideo:(BADVideo *)video
                withType:(BADVideoPhotoType)photoType
                 success:(void (^)(UIImage *image))success
                 failure:(void (^)(NSError *error))failure {
    
    NSURL *photoURL;
    
    if (photoType == BADVideoPhotoTypeSmall) {
        photoURL = video.smallPhotoURL;
    } else if (photoType == BADVideoPhotoTypeBig) {
        photoURL = video.bigPhotoURL;
    }
    
    if (photoURL) { // If URL exists
        
        [self.networker downloadImageWithURL:photoURL
                                     success:^(UIImage * _Nullable image) {
                                         if (success) {
                                             success(image);
                                         }
                                     }
                                     failure:^(NSError * _Nullable error) {
                                         if (failure) {
                                             failure(error);
                                         }
                                     }];
    } else {
        
        NSError *error = [NSError errorWithDomain:@""
                                             code:1010
                                         userInfo:@{NSLocalizedDescriptionKey:@"Photo URL is nil"}];
        failure(error);
    }
}

#pragma mark - Utilites

- (NSDictionary *)parametersWithSettings:(NSDictionary *)parameters {
    
    NSMutableDictionary *parametersWithSettings = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [parametersWithSettings setObject:vkAPIVersion forKey:@"v"];

    if (self.accessToken) {
        [parametersWithSettings setObject:self.accessToken.token forKey:@"access_token"];
    }
    
    return parametersWithSettings;
}

@end

