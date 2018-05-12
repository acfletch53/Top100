//
//  Top100TableViewController.h
//  Top100
//
//  Created by Andrea Fletcher on 5/9/18.
//  Copyright © 2018 Andrea Fletcher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepositoryInfo.h"

@interface Top100TableViewController : UITableViewController

@property NSMutableArray<RepositoryInfo *> *top100Repositories;

@end
