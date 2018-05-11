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
@property NSURL *repositoryURL;
@property int numStars;
@property NSString *contributorsURL;
@property NSString *topContributorName;
@property NSURL *topContributorURL;

@end