//
//  BADVideoCell.m
//  BADVKVideo
//
//  Created by Artem Belkov on 19/03/2017.
//  Copyright © 2017 Artem Belkov. All rights reserved.
//

#import "BADVideoCell.h"

@implementation BADVideoCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubiews];
    }
    return self;
}

- (void)initSubiews {
    
    // Init
    
    UIImageView *photoView = [[UIImageView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    UILabel *durationLabel = [[UILabel alloc] init];
    
    [self addSubview:photoView];
    [self addSubview:titleLabel];
    [self addSubview:durationLabel];
    
    // Setting colors

    self.backgroundColor = [UIColor colorWithRed:20 /255.f
                                           green:29 /255.f
                                            blue:38 /255.f
                                           alpha:1.f];
    self.contentView.backgroundColor = [UIColor colorWithRed:20 /255.f
                                                       green:29 /255.f
                                                        blue:38 /255.f
                                                       alpha:1.f];
    
    [durationLabel setTextAlignment:NSTextAlignmentRight];
    [durationLabel setTextColor:[UIColor colorWithRed:129 /255.f
                                                green:146 /255.f
                                                 blue:159 /255.f
                                                alpha:1.f]];
    
    [titleLabel setTextColor:[UIColor colorWithRed:227 /255.f
                                                green:228 /255.f
                                                 blue:329 /255.f
                                                alpha:1.f]];
    
    UIView *bgColorView = [[UIView alloc] initWithFrame:self.frame];
    bgColorView.backgroundColor = [UIColor colorWithRed:129 /255.f
                                                  green:146 /255.f
                                                   blue:159 /255.f
                                                  alpha:1.f];
    [self setSelectedBackgroundView:bgColorView];
    
    // Circle corners 
    
    photoView.layer.cornerRadius = 5.f;
    photoView.layer.masksToBounds = YES;
    
    // Create constraints
    
    [photoView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [durationLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(photoView, titleLabel, durationLabel);
    NSDictionary *metrics = @{@"padding":@5.0, @"padding2":@10.0};
    
    // Vertical constraints
    NSArray *photoViewVerticalConstraints = [NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-padding-[photoView(==65)]-padding-|"
                                             options:0 metrics:metrics views:views];
    NSArray *titleLabelVerticalConstraints = [NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-padding-[titleLabel]-padding-|"
                                              options:0 metrics:metrics views:views];
    NSArray *durationLabelVerticalConstraints = [NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-padding-[durationLabel]-padding-|"
                                                 options:0 metrics:metrics views:views];
    
    // Horizontal constraints
    NSArray *horizontalConstraints =[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"H:|-padding-[photoView(==87)]-padding2-[titleLabel]-padding-[durationLabel(>=40)]-7-|"
                                    options:0 metrics:metrics views:views];
    
    [self addConstraints:photoViewVerticalConstraints];
    [self addConstraints:titleLabelVerticalConstraints];
    [self addConstraints:durationLabelVerticalConstraints];
    [self addConstraints:horizontalConstraints];
    
    self.photoView = photoView;
    self.titleLabel = titleLabel;
    self.durationLabel = durationLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
