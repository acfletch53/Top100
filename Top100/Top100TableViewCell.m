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
        // Styling
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = [UIColor blackColor];
        
        _repositoryLabel = [[UILabel alloc] init];
        _repositoryLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _repositoryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        _repositoryLabel.textColor = [UIColor whiteColor];
        // For AX large text support
        _repositoryLabel.adjustsFontForContentSizeCategory = YES;
        // Wrap to multiple lines
        _repositoryLabel.numberOfLines = 0;
        [self.contentView addSubview:_repositoryLabel];
        
        _numStarsLabel = [[UILabel alloc] init];
        _numStarsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _numStarsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        _numStarsLabel.textColor = [UIColor whiteColor];
        _numStarsLabel.adjustsFontForContentSizeCategory = YES;
        [self.contentView addSubview:_numStarsLabel];
        
        // This guy is a scalable SVG, so it can grow with the users text size
        _starImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small-star"]];
        _starImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _starImageView.adjustsImageSizeForAccessibilityContentSizeCategory = YES;
        [self.contentView addSubview:_starImageView];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setInfo:(RepositoryInfo *)info {
    if (info != nil)
    {
        _repositoryLabel.text = info.repositoryName;
        _numStarsLabel.text = [@(info.numStars) stringValue];
        _numStarsLabel.accessibilityLabel = [NSString stringWithFormat:@"Starred %d times", info.numStars];
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    // I feel much more comfortable doing manual layouts that using storyboards.
    // Also, conveniently, my computer freezes for ten seconds every time I open up a storyboard.
    // I avoid using strict width and height values so these can adapt to the users preferredContentSizeCategory.
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
