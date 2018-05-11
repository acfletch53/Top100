//
//  RepositoryInfo.m
//  Top100
//
//  Created by Andrea Fletcher on 5/10/18.
//  Copyright © 2018 Andrea Fletcher. All rights reserved.
//

#import "RepositoryInfo.h"

@implementation RepositoryInfo

- (void)loadTopContributorInfoWithCompletionHandler:(void(^)(void))completionHandler {
    if (_topContributorName != nil)
    {
        // We already have the information for the top contributor
        completionHandler();
    }
    else
    {
        NSString *urlString = [_contributorsURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
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
                                                      self.topContributorName = @"This repository is so popular, everyone is a top contributor!";
                                                      self.numContributions = INT_MAX;
                                                      self.topContributorImageURL = [NSURL URLWithString:@"https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/02/13/10/oprah-winfrey.jpg"];
                                                  }
                                                  else if (dataArray.count > 0)
                                                  {
                                                      NSDictionary *topContributor = [dataArray firstObject];
                                                      self.topContributorName = [topContributor objectForKey:@"login"];
                                                      self.numContributions = [[topContributor objectForKey:@"contributions"] intValue];
                                                      self.topContributorImageURL = [NSURL URLWithString:[topContributor objectForKey:@"avatar_url"]];
                                                  }
                                                  completionHandler();
                                              }
                                          }
                                      }];
        // Start the task.
        [task resume];
    }
}

@end
