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
    
    // Repository data only loads at launch, and if the user triggers it by a pull-down refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to reload data"];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    // For self-sizing tableViewCells
    self.tableView.estimatedRowHeight = 200;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Styling
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
        
        // I know this is a cheeky way to get around the fact that this computation is going to
        // take half a second, but instead of loading the page, having an activity indicator,
        // and then fading in the information, i thought it looked better if i just delayed
        // the viewController push until the contributor informatiom was loaded.
        // My internet is also horrifically slow, so this might not be noticeable for any of y'all.
        // In that clase, ignore the above :)
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
                                                  // I got kicked off of calling GitHubs API when I tried to load the top
                                                  // contributor information in this loop. Hit their rate limits pretty hard.
                                                  // Instead of fixing it the right way, with oauth and (from what i can tell)
                                                  // a client id and secret, I adapted my UI so that we only request this
                                                  // information when someone taps on a cell to see the top contributor.
                                                  // I worked the oauth angle for about an hour before giving up and going
                                                  // with something I was more comfortable with in the interest of time,
                                                  // though i'm well aware of the pitfalls of this approach.
                                                  info.contributorsURLString = [NSString stringWithFormat:@"%@%@",
                                                                                [items objectForKey:@"contributors_url"], @"?per_page=1"];
                                                  [self.top100Repositories addObject:info];
                                              }
                                              // I used a completion handler here so I could end the refresh animation
                                              // at the right time
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
