//
//  Top100TableViewCell.h
//  Top100
//
//  Created by Andrea Fletcher on 5/9/18.
//  Copyright © 2018 Andrea Fletcher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Top100RepositoryInfo.h"

@interface Top100TableViewCell : UITableViewCell

@property (nonatomic, weak) Top100RepositoryInfo *info;
@property (nonatomic, strong) UILabel *repositoryLabel;
@property (nonatomic, strong) UILabel *numStarsLabel;
@property (nonatomic, strong) UILabel *topContributorLabel;

@end
