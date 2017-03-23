//
//  BADAccessToken.h
//  BADVKVideo
//
//  Created by Artem Belkov on 17/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BADAccessToken : NSObject

@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSDate *expirationDate;
@property (strong, nonatomic) NSString *userID;

- (BOOL)isValid;

@end
