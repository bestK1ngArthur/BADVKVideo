//
//  BADKeychainWrapper.h
//  BADVKVideo
//
//  Created by Artem Belkov on 23/03/2017.
//  Code from developer.apple.com
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface BADKeychainWrapper : NSObject {
    NSMutableDictionary        *keychainData;
    NSMutableDictionary        *genericPasswordQuery;
}

@property (nonatomic, strong) NSMutableDictionary *keychainData;
@property (nonatomic, strong) NSMutableDictionary *genericPasswordQuery;

- (void)setObject:(id)inObject forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)resetKeychainItem;

@end
