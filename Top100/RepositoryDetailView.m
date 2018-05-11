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
        _topContributorLabel = [[UILabel alloc] init];
        _topContributorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _topContributorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        _topContributorLabel.adjustsFontForContentSizeCategory = YES;
        [self addSubview:self.topContributorLabel];
        
        _topContributorImageView = [[UIImageView alloc] init];
        _topContributorImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _topContributorImageView.adjustsImageSizeForAccessibilityContentSizeCategory = YES;
        [self addSubview:_topContributorImageView];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setInfo:(RepositoryInfo *)info {
    if (info != nil)
    {
        _info = info;
        
        NSString *urlString = [info.contributorsURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
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
                                                      info.topContributorName = @"FLETCHER YOU SHOULD FIX THIS";
                                                  }
                                                  else if (dataArray.count > 0)
                                                  {
                                                      NSDictionary *topContributor = [dataArray firstObject];
                                                      info.topContributorName = [topContributor objectForKey:@"login"];
                                                      info.topContributorURL = [topContributor objectForKey:@"html_url"];
                                                      NSURL *topContributorImageURL = [NSURL URLWithString:[topContributor objectForKey:@"avatar_url"]];
                                                      // TODO: Is this the best place to do this?
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          self.topContributorLabel.text = info.topContributorName;
                                                          self.topContributorImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:topContributorImageURL]];
                                                      });
                                                  }
                                              }
                                          }
                                      }];
        // Start the task.
        [task resume];
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    NSDictionary *views = NSDictionaryOfVariableBindings(_repositoryLabel, _topContributorImageView, _topContributorLabel);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_repositoryLabel]-|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views];
    [NSLayoutConstraint activateConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_topContributorImageView]-[_topContributorLabel]-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [NSLayoutConstraint activateConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_repositoryLabel]-[_topContributorLabel]-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [NSLayoutConstraint activateConstraints:constraints];
    
    NSLayoutConstraint *topContributorHeightConstraint = [NSLayoutConstraint constraintWithItem:_topContributorImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_topContributorLabel attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    NSLayoutConstraint *topContributorWidthConstraint = [NSLayoutConstraint constraintWithItem:_topContributorImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_topContributorImageView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    NSLayoutConstraint *topContributorCenterYConstraint = [NSLayoutConstraint constraintWithItem:_topContributorImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_topContributorLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [NSLayoutConstraint activateConstraints:@[topContributorHeightConstraint, topContributorWidthConstraint, topContributorCenterYConstraint]];
}

@end
