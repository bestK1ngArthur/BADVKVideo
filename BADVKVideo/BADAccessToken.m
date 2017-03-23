//
//  BADAccessToken.m
//  BADVKVideo
//
//  Created by Artem Belkov on 17/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import "BADAccessToken.h"

@implementation BADAccessToken

- (BOOL)isValid {
    
    if ([[NSDate dateWithTimeIntervalSinceNow:0] compare:self.expirationDate] == NSOrderedAscending) {
        return true;
    } else {
        return false;
    }
}

@end
