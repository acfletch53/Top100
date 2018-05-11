//
//  RepositoryDetailView.h
//  Top100
//
//  Created by Andrea Fletcher on 5/10/18.
//  Copyright © 2018 Andrea Fletcher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepositoryInfo.h"

@interface RepositoryDetailView : UIView

@property (nonatomic, weak) RepositoryInfo *info;
@property (nonatomic, strong) UILabel *repositoryLabel;
@property (nonatomic, strong) UIImageView *topContributorImageView;
@property (nonatomic, strong) UILabel *topContributorLabel;

@end
