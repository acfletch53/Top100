//
//  Top100TableViewController.m
//  Top100
//
//  Created by Andrea Fletcher on 5/9/18.
//  Copyright © 2018 Andrea Fletcher. All rights reserved.
//

#import "Top100TableViewController.h"
#import "Top100TableViewCell.h"

static NSString *cellIdentifier = @"Top100";
static NSString *top100URL = @"https://api.github.com/search/repositories?q=stars:>0&sort=stars&per_page=100";

@interface Top100TableViewController ()

@end

@implementation Top100TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TODO: Only do this if we need to, or if the user asks to refresh the contents.
    // Things change, people star repos, people unstar repos.
    [self fetchDataForURL:top100URL completionHandler:^(NSData *data,
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
             NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:0
                                                                          error:&JSONError];
             if (JSONError)
             {
                 NSLog(@"Serialization error: %@", JSONError.localizedDescription);
             }
             else
             {
                 NSLog(@"Response: %@", dictionary);
                 
                 self.top100Repositories = [[NSMutableArray alloc] initWithCapacity:100];
                 NSArray *allItems = [dictionary objectForKey:@"items"];
                 
                 // TODO: Make sure i'm only doing 100... i only did this to make everything shut up
                 for (NSDictionary *items in allItems)
                 {
                     Top100RepositoryInfo *info = [[Top100RepositoryInfo alloc] init];
                     //NSDictionary *items = [allItems objectAtIndex:i];
                     info.numStars = [[items objectForKey:@"stargazers_count"] intValue];
                     info.repositoryName = [items objectForKey:@"name"];
                     info.repositoryURL = [NSURL URLWithString:[items objectForKey:@"html_url"]];
                     // TODO: Dispatch this asynchronously?
                     [self getTopContributorInfo:info forURL:[NSString stringWithFormat:@"%@%@", [items objectForKey:@"contributors_url"], @"?per_page=1"]];
                     [self.top100Repositories addObject:info];
                 }
             }
         }
     }];
    
}

- (void)getTopContributorInfo:(Top100RepositoryInfo *)info forURL:(NSString *)url {
    [self fetchDataForURL:url completionHandler:^(NSData *data,
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

             NSArray *contributors = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:&JSONError];
             if (JSONError)
             {
                 NSLog(@"Serialization error: %@", JSONError.localizedDescription);
             }
             else
             {
                 NSLog(@"Response: %@", contributors);
                 
                 if (contributors.count > 0)
                 {
                     NSDictionary *topContributor = [contributors firstObject];
                     info.topContributorName = [topContributor objectForKey:@"login"];
                     info.topContributorURL = [topContributor objectForKey:@"html_url"];
                 }
             }
         }
     }];
}

- (void)fetchDataForURL:(NSString *)url completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    NSString *urlString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:completionHandler];
    // Start the task.
    [task resume];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Top100TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[Top100TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row < [self.top100Repositories count])
    {
        [cell setInfo:[self.top100Repositories objectAtIndex:indexPath.row]];
    }

    return cell;
}

@end
