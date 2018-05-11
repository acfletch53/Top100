//
//  Top100TableViewCell.m
//  Top100
//
//  Created by Andrea Fletcher on 5/9/18.
//  Copyright © 2018 Andrea Fletcher. All rights reserved.
//

#import "Top100TableViewCell.h"

@implementation Top100TableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        _repositoryLabel = [[UILabel alloc] init];
        _repositoryLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _repositoryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        _repositoryLabel.adjustsFontForContentSizeCategory = YES;
        _repositoryLabel.numberOfLines = 0;
        [self.contentView addSubview:_repositoryLabel];
        
        _numStarsLabel = [[UILabel alloc] init];
        _numStarsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _numStarsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        _numStarsLabel.adjustsFontForContentSizeCategory = YES;
        [self.contentView addSubview:_numStarsLabel];
        
        _starImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small-star"]];
        _starImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _starImageView.adjustsImageSizeForAccessibilityContentSizeCategory = YES;
        [self.contentView addSubview:_starImageView];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInfo:(RepositoryInfo *)info {
    if (info != nil)
    {
        _repositoryLabel.text = info.repositoryName;
        _numStarsLabel.text = [@(info.numStars) stringValue];
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    NSDictionary *views = NSDictionaryOfVariableBindings(_repositoryLabel, _numStarsLabel, _starImageView);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_repositoryLabel]-|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views];
    [NSLayoutConstraint activateConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_starImageView]-[_numStarsLabel]-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [NSLayoutConstraint activateConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_repositoryLabel]-[_numStarsLabel]-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [NSLayoutConstraint activateConstraints:constraints];
    
    NSLayoutConstraint *starHeightConstraint = [NSLayoutConstraint constraintWithItem:_starImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_numStarsLabel attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    NSLayoutConstraint *starWidthConstraint = [NSLayoutConstraint constraintWithItem:_starImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_starImageView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    NSLayoutConstraint *starCenterYConstraint = [NSLayoutConstraint constraintWithItem:_starImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_numStarsLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [NSLayoutConstraint activateConstraints:@[starHeightConstraint, starWidthConstraint, starCenterYConstraint]];
}

@end
