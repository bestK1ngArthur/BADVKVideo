//
//  BADVKManager.m
//  BADVKVideo
//
//  Created by Artem Belkov on 18/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import "BADVKManager.h"

#include "BADNetworker.h"
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
        #warning Something magic with keychain
        //[self getAccessTokenFromKeychain];
    }
    return self;
}

#pragma mark -

- (BOOL)isUserAuthorized {
    
    if (self.accessToken) { // if token exist
        return self.accessToken.isValid;
    } else {
        return false;
    }
}

- (void)saveAccessToken:(BADAccessToken *)accessToken {
    
    self.accessToken = accessToken;
    [self saveAccessTokenToKeychain];
}

#pragma mark - Keychain

- (void)saveAccessTokenToKeychain {
 
    if(self.accessToken) {
        
        [self.keychainWrapper setObject:self.accessToken.token forKey:(id)kSecValueData];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.accessToken.expirationDate forKey:vkAPIAccessTokenDate];
        [[NSUserDefaults standardUserDefaults] setObject:self.accessToken.userID forKey:vkAPIAccessTokenUser];
    }
}

- (void)getAccessTokenFromKeychain {
    
    NSString *token = [self.keychainWrapper objectForKey:(id)kSecValueData];
    
    if (![token isEqualToString:@"password"]) {
        self.accessToken.token = token;
    }
    
    self.accessToken.expirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:vkAPIAccessTokenDate];
    self.accessToken.userID = [[NSUserDefaults standardUserDefaults] objectForKey:vkAPIAccessTokenUser];
}

#pragma mark - Requests

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

