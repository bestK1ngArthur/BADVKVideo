//
//  BADNetworker.m
//  BADVKVideo
//
//  Created by Artem Belkov on 17/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import "BADNetworker.h"

@interface BADNetworker ()

@property (strong, nonatomic) NSURL *baseURL;

@end

@implementation BADNetworker

+ (instancetype)networker {
    return [[self alloc] init];
}

+ (instancetype)networkerWithBaseURL:(NSURL *)url {
    return [[self alloc] initWithBaseURL:url];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Init
    }
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.baseURL = url;
    }
    return self;
}

- (void)loadRequestWithURL:(NSURL *)url
                    method:(NSString *)method
                   success:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response))success
                   failure:(void (^)(NSError * _Nullable error))failure {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:method];
    [request setURL:url];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
          
          if (!error) {
              // Success
              success(data, response);
          } else {
              // Failure
              failure(error);
          }
      }] resume];
    
}

- (void)GET:(NSString *)apiMethod
 parameters:(NSDictionary *)parameters
    success:(void (^)(NSDictionary * _Nullable response))success
    failure:(void (^)(NSError * _Nullable error))failure {
    
    NSString *urlString = [self urlStringWithAPIMethod:apiMethod parameters:parameters];
    NSString *webURLString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
    
    #warning Encode URL
    NSURL *url = [NSURL URLWithString:webURLString]; // encodeWithCoder:];
    NSLog(@"%@", webURLString);
    [self loadRequestWithURL:url
                  method:@"GET"
                 success:^(NSData * _Nullable data, NSURLResponse * _Nullable response) {
                     
                     // Success
                     
                     // If exists
                     if ((response != nil) && (data != nil)) {
                         
                         // Parse incoming data to dictionary
                         
                         NSError *error;
                         id parsedResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
                         
                         if ([parsedResponse isKindOfClass:[NSDictionary class]]) {
                             success(parsedResponse);
                         } else {
                             error = [NSError errorWithDomain:@"com.bestK1ng.BADVKVideo"
                                                         code:1
                                                     userInfo:nil];
                         }

                         if (error) {
                             failure(error);
                         }
                     }
                 }
                 failure:^(NSError * _Nullable error) {
                     
                     // Failure
                     
                 }];
}

#pragma mark - Files

- (void)downloadImageWithURL:(NSURL *)url
                     success:(void (^)(UIImage * _Nullable image))success
                     failure:(void (^)(NSError * _Nullable error))failure {
    
    [self loadRequestWithURL:url
                  method:@"GET"
                 success:^(NSData * _Nullable data, NSURLResponse * _Nullable response) {
                     
                     // Success
                     
                     if ((response != nil) && (data != nil)) {
                         
                         // Parse incoming data to image
                         UIImage *image = [UIImage imageWithData:data];
                         
                         if (image) {
                             success(image);
                         } else {
                             NSError *error = [NSError errorWithDomain:@""
                                                                  code:1000
                                                              userInfo:@{NSLocalizedDescriptionKey:@"Can't parse image from data"}];
                             failure(error);
                         }
                     }
                     
                 }
                 failure:^(NSError * _Nullable error) {
                     
                     // Failure
                     
                 }];
}

#pragma mark - Utilites

- (NSString *)urlStringWithAPIMethod:(NSString *)method parameters:(NSDictionary *)parameters {
    
    if (self.baseURL) {
        if (parameters) {
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?", self.baseURL.absoluteString, method];
            
            for (NSString *key in parameters.allKeys) {
                [urlString appendString:[NSString stringWithFormat:@"%@=%@", key, [parameters valueForKey:key]]];
                if (![key isEqualToString:[[parameters allKeys] lastObject]]) {
                    [urlString appendString:@"&"];
                }
            }
            
            return urlString;
        } else {
            return [self.baseURL absoluteString];
        }
    } else {
        return nil;
    }
}

@end
