//
//  RepositoryDetailView.m
//  Top100
//
//  Created by Andrea Fletcher on 5/10/18.
//  Copyright © 2018 Andrea Fletcher. All rights reserved.
//

#import "RepositoryDetailView.h"

@implementation RepositoryDetailView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        _topContributorLabel = [[UILabel alloc] init];
        _topContributorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _topContributorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        _topContributorLabel.adjustsFontForContentSizeCategory = YES;
        [self addSubview:self.topContributorLabel];
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
                                                  
                                                  // TODO: Authenticate somehow so i don't get kicked off from making requests :)
                                                  if ([dataArray isKindOfClass:[NSDictionary class]])
                                                  {
                                                      //info.topContributorName = @"Nope.";
                                                  }
                                                  else if (dataArray.count > 0)
                                                  {
                                                      NSDictionary *topContributor = [dataArray firstObject];
                                                      info.topContributorName = [topContributor objectForKey:@"login"];
                                                      info.topContributorURL = [topContributor objectForKey:@"html_url"];
                                                  }
                                              }
                                          }
                                      }];
        // Start the task.
        [task resume];
    }
}

@end
