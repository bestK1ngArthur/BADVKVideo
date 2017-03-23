//
//  BADVideo.m
//  BADVKVideo
//
//  Created by Artem Belkov on 19/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import "BADVideo.h"

static NSString * const kVideoID            = @"id";
static NSString * const kVideoTitle         = @"title";
static NSString * const kVideoDescription   = @"description";
static NSString * const kVideoDuration      = @"duration";
static NSString * const kVideoSmallPhotoURL = @"photo_130";
static NSString * const kVideoBigPhotoURL   = @"photo_320";
static NSString * const kVideoURL           = @"player";

@implementation BADVideo

- (instancetype)initWithResponse:(NSDictionary *)response {
    self = [super init];
    if (self) {
        
        // Parse from dictionary
        
        if ([self dictionary:response containKey:kVideoID]) {
            self.ID = [[response objectForKey:kVideoID] integerValue];
        }
        if ([self dictionary:response containKey:kVideoTitle]) {
            self.title = [response objectForKey:kVideoTitle];
        }
        if ([self dictionary:response containKey:kVideoDescription]) {
            self.fullDescription = [response objectForKey:kVideoDescription];
        }
        if ([self dictionary:response containKey:kVideoDuration]) {
            self.duration = [[response objectForKey:kVideoDuration] integerValue];
        }
        if ([self dictionary:response containKey:kVideoSmallPhotoURL]) {
            self.smallPhotoURL = [NSURL URLWithString:[response objectForKey:kVideoSmallPhotoURL]];
        }
        if ([self dictionary:response containKey:kVideoBigPhotoURL]) {
            self.smallPhotoURL = [NSURL URLWithString:[response objectForKey:kVideoBigPhotoURL]];
        }
        if ([self dictionary:response containKey:kVideoURL]) {
            self.URL = [NSURL URLWithString:[response objectForKey:kVideoURL]];
        }
    }
    return self;
}

- (BOOL)dictionary:(NSDictionary *)dictionary containKey:(NSString *)key {
    
    return [[dictionary allKeys] containsObject:key];
}

#pragma mark - Duration

// This method converts "seconds" to "hours:minutes:seconds"
- (NSString *)durationString {
    
    NSString *durationString;
    
    NSInteger seconds = self.duration;
    NSInteger minutes = seconds / 60;
    
    if (minutes < 60) {
        
        seconds = seconds - 60 * minutes;
        
        if (seconds < 10) {
            durationString = [NSString stringWithFormat:@"%li:0%li", (long)minutes, (long)seconds];
        } else {
            durationString = [NSString stringWithFormat:@"%li:%li", (long)minutes, (long)seconds];
        }
        
    } else {
        
        NSInteger hours = minutes / 60;
        minutes = minutes - 60 * hours;
        seconds = seconds - 60 * 60 * hours - 60 * minutes;
        
        durationString = [NSString stringWithFormat:@"%li:", (long)hours];
        
        if (minutes < 10) {
            durationString = [durationString stringByAppendingString:[NSString stringWithFormat:@"0%li:", (long)seconds]];
        } else {
            durationString = [durationString stringByAppendingString:[NSString stringWithFormat:@"%li:", (long)seconds]];
        }
        
        if (seconds < 10) {
            durationString = [durationString stringByAppendingString:[NSString stringWithFormat:@"0%li", (long)minutes]];
        } else {
            durationString = [durationString stringByAppendingString:[NSString stringWithFormat:@"%li", (long)minutes]];
        }
        
    }
    
    return durationString;
}


@end
