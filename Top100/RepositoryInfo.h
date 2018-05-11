//
//  RepositoryInfo.h
//  Top100
//
//  Created by Andrea Fletcher on 5/10/18.
//  Copyright © 2018 Andrea Fletcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepositoryInfo : NSObject

@property NSString *repositoryName;
@property int numStars;
@property NSString *contributorsURLString;
@property NSString *topContributorName;
@property int numContributions;
@property NSURL *topContributorImageURL;

- (void)loadTopContributorInfoWithCompletionHandler:(void(^)(void))completionHandler;

@end
