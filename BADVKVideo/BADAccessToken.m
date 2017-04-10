//
//  BADAccessToken.m
//  BADVKVideo
//
//  Created by Artem Belkov on 17/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import "BADAccessToken.h"

@implementation BADAccessToken

- (instancetype)initWithRequest:(NSURLRequest *)request {
    self = [super init];
    
    // Parsing token
    
    if (self) {
        
        NSString *query = [[request URL] description];
        NSArray *array = [query componentsSeparatedByString:@"#"];
        
        if ([array count] > 1) {
            query = [array lastObject];
        }
        
        NSArray *pairs = [query componentsSeparatedByString:@"&"];
        for (NSString *pair in pairs) {
            NSArray *values = [pair componentsSeparatedByString:@"="];
            if ([values count] == 2) {
                NSString *key = [values firstObject];
                if ([key isEqualToString:@"access_token"]) {
                    self.token = [values lastObject];
                } else if ([key isEqualToString:@"expires_in"]) {
                    NSTimeInterval interval = [[values lastObject] doubleValue];
                    self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                } else if ([key isEqualToString:@"user_id"]) {
                    self.userID = [values lastObject];
                }
            }
        }
    }
    return self;
}

- (BOOL)isValid {
    
    if ([[NSDate dateWithTimeIntervalSinceNow:0] compare:self.expirationDate] == NSOrderedAscending) {
        return true;
    } else {
        return false;
    }
}

@end
