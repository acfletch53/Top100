//
//  Top100TableViewController.m
//  Top100
//
//  Created by Andrea Fletcher on 5/9/18.
//  Copyright © 2018 Andrea Fletcher. All rights reserved.
//

#import "Top100TableViewController.h"
#import "Top100TableViewCell.h"
#import "RepositoryDetailView.h"

static NSString *cellIdentifier = @"Top100";
static NSString *top100URL = @"https://api.github.com/search/repositories?q=stars:>0&sort=stars&per_page=100";

@interface Top100TableViewController ()

@end

@implementation Top100TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to reload data"];
    
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    
    self.tableView.estimatedRowHeight = 200;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = [UIColor blackColor];
    
    if (_top100Repositories == nil)
    {
        [self getRepositoryDataWithCompletionHandler:^ {
            // reload the tableView
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _top100Repositories.count;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UIViewController *detailViewController = [[UIViewController alloc] init];
    RepositoryDetailView *detailView = [[RepositoryDetailView alloc] init];
    if (indexPath.row < [self.top100Repositories count])
    {
        RepositoryInfo *info = [self.top100Repositories objectAtIndex:indexPath.row];
        [detailViewController setView:detailView];
        [info loadTopContributorInfoWithCompletionHandler:^ {
            dispatch_async(dispatch_get_main_queue(), ^{
                [detailView setInfo:[self.top100Repositories objectAtIndex:indexPath.row]];
                [[self navigationController] pushViewController:detailViewController animated:YES];
            });
        }];
    }
}

- (void)getRepositoryDataWithCompletionHandler:(void(^)(void))completionHandler {
    NSString *urlString = [top100URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString]
                                                             completionHandler:^(NSData *data,
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
                                          
                                          NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:0
                                                                                                           error:&JSONError];
                                          if (JSONError)
                                          {
                                              NSLog(@"Serialization error: %@", JSONError.localizedDescription);
                                          }
                                          else
                                          {
                                              NSLog(@"Response: %@", dataDictionary);
                                              
                                              self.top100Repositories = [[NSMutableArray alloc] initWithCapacity:100];
                                              NSArray *allItems = [dataDictionary objectForKey:@"items"];
                                              
                                              for (NSDictionary *items in allItems)
                                              {
                                                  RepositoryInfo *info = [[RepositoryInfo alloc] init];
                                                  info.numStars = [[items objectForKey:@"stargazers_count"] intValue];
                                                  info.repositoryName = [items objectForKey:@"name"];
                                                  info.contributorsURLString = [NSString stringWithFormat:@"%@%@",
                                                                                [items objectForKey:@"contributors_url"], @"?per_page=1"];
                                                  [self.top100Repositories addObject:info];
                                              }
                                              completionHandler();
                                          }
                                      }
                                  }];
    // Start the task.
    [task resume];
}

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Reloading Data"];

    [self getRepositoryDataWithCompletionHandler:^{
        // reload the tableView
        [self.tableView reloadData];
        // to end the refresh animation
        [refresh endRefreshing];
    }];
}

@end
