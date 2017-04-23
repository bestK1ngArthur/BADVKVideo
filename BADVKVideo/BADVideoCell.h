//
//  BADVideoCell.h
//  BADVKVideo
//
//  Created by Artem Belkov on 19/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BADVideoCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UIImageView *photoView;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
