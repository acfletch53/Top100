//
//  RepositoryDetailView.m
//  Top100
//
//  Created by Andrea Fletcher on 5/10/18.
//  Copyright © 2018 Andrea Fletcher. All rights reserved.
//

#import "RepositoryDetailView.h"

@implementation RepositoryDetailView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
        
        _repositoryLabel = [[UILabel alloc] init];
        _repositoryLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _repositoryLabel.textColor = [UIColor whiteColor];
        _repositoryLabel.textAlignment = NSTextAlignmentCenter;
        _repositoryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle];
        _repositoryLabel.adjustsFontForContentSizeCategory = YES;
        _repositoryLabel.adjustsFontSizeToFitWidth = YES;
        _repositoryLabel.minimumScaleFactor = 0.7;
        [self addSubview:self.repositoryLabel];
        
        _topContributorLabel = [[UILabel alloc] init];
        _topContributorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _topContributorLabel.text = @"Top Contributor";
        _topContributorLabel.textColor = [UIColor whiteColor];
        _topContributorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _topContributorLabel.adjustsFontForContentSizeCategory = YES;
        _topContributorLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.topContributorLabel];
        
        _topContributorNameLabel = [[UILabel alloc] init];
        _topContributorNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _topContributorNameLabel.textColor = [UIColor whiteColor];
        _topContributorNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _topContributorNameLabel.adjustsFontForContentSizeCategory = YES;
        _topContributorNameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.topContributorNameLabel];
        
        _topContributorContributionsLabel = [[UILabel alloc] init];
        _topContributorContributionsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _topContributorContributionsLabel.textColor = [UIColor whiteColor];
        _topContributorContributionsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _topContributorContributionsLabel.adjustsFontForContentSizeCategory = YES;
        _topContributorContributionsLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.topContributorContributionsLabel];
        
        _topContributorImageView = [[UIImageView alloc] init];
        _topContributorImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _topContributorImageView.adjustsImageSizeForAccessibilityContentSizeCategory = YES;
        [self addSubview:_topContributorImageView];
    }
    return self;
}

- (void)setInfo:(RepositoryInfo *)info {
    if (info != nil)
    {
        _info = info;
        _repositoryLabel.text = info.repositoryName;
        
        if (info.topContributorName != nil && info.topContributorImageURL != nil)
        {
            // This information has already been fetched, so don't bother requesting it again.
            self.topContributorNameLabel.text = info.topContributorName;
            self.topContributorContributionsLabel.text = [NSString stringWithFormat:@"%d Contributions", info.numContributions];
            self.topContributorImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:info.topContributorImageURL]];
            [self setNeedsLayout];
        }
        else
        {
            NSString *urlString = [info.contributorsURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data,
                                                                                                                                           NSURLResponse *response,
                                                                                                                                           NSError *error)
                                          {
                                              // Modified from https://gist.github.com/r3econ/9923319
                                              if (error)
                                              {
                                                  NSLog(@"Error: %@", error.localizedDescription);
                                              }
                                              else
                                              {
                                                  NSError *JSONError = nil;
                                                  
                                                  NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data
                                                                                                            options:0
                                                                                                              error:&JSONError];
                                                  if (JSONError)
                                                  {
                                                      NSLog(@"Serialization error: %@", JSONError.localizedDescription);
                                                  }
                                                  else
                                                  {
                                                      NSLog(@"Response: %@", dataArray);
                                                      
                                                      if ([dataArray isKindOfClass:[NSDictionary class]])
                                                      {
                                                          // This means we got an error message regarding the list of contributors
                                                          // being too long to get with this API call.
                                                          info.topContributorName = @"This repository is so popular, everyone is a top contributor!";
                                                          info.numContributions = INT_MAX;
                                                          info.topContributorImageURL = [NSURL URLWithString:@"https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/02/13/10/oprah-winfrey.jpg"];
                                                      }
                                                      else if (dataArray.count > 0)
                                                      {
                                                          NSDictionary *topContributor = [dataArray firstObject];
                                                          info.topContributorName = [topContributor objectForKey:@"login"];
                                                          info.numContributions = [[topContributor objectForKey:@"contributions"] intValue];
                                                          info.topContributorImageURL = [NSURL URLWithString:[topContributor objectForKey:@"avatar_url"]];
                                                      }
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          self.topContributorNameLabel.text = info.topContributorName;
                                                          self.topContributorContributionsLabel.text = [NSString stringWithFormat:@"%d Contributions", info.numContributions];
                                                          self.topContributorImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:info.topContributorImageURL]];
                                                          [self setNeedsLayout];
                                                      });
                                                  }
                                              }
                                          }];
            // Start the task.
            [task resume];
        }
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    NSDictionary *views = NSDictionaryOfVariableBindings(_repositoryLabel, _topContributorLabel, _topContributorNameLabel, _topContributorContributionsLabel, _topContributorImageView);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_repositoryLabel]-|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views];
    [NSLayoutConstraint activateConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_topContributorLabel]-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [NSLayoutConstraint activateConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_topContributorNameLabel]-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [NSLayoutConstraint activateConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_topContributorContributionsLabel]-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [NSLayoutConstraint activateConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_topContributorImageView]-20-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [NSLayoutConstraint activateConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_repositoryLabel]-[_topContributorLabel]-[_topContributorNameLabel]-[_topContributorContributionsLabel]-[_topContributorImageView]-20-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [NSLayoutConstraint activateConstraints:constraints];
    
    NSLayoutConstraint *topContributorWidthConstraint = [NSLayoutConstraint constraintWithItem:_topContributorImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_topContributorImageView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [NSLayoutConstraint activateConstraints:@[topContributorWidthConstraint]];
}

@end
