//
//  Top100TableViewCell.m
//  Top100
//
//  Created by Andrea Fletcher on 5/9/18.
//  Copyright © 2018 Andrea Fletcher. All rights reserved.
//

#import "Top100TableViewCell.h"

@implementation Top100TableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.repositoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 300, 30)];
        self.numStarsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 300, 30)];
        self.topContributorLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 300, 30)];
        
        [self addSubview:self.repositoryLabel];
        [self addSubview:self.numStarsLabel];
        [self addSubview:self.topContributorLabel];
    }
    return self;
}

/** I have no clue how to use nibs.
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
 **/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInfo:(Top100RepositoryInfo *)info {
    if (info != nil)
    {
        self.repositoryLabel.text = info.repositoryName;
        // TODO: set this link to be the url for the repo
        self.numStarsLabel.text = [NSString stringWithFormat:@"%d Stars", info.numStars];
        
        // Time for another NSURLSession
        self.topContributorLabel.text = info.topContributorName;
        [self setNeedsLayout];
    }
}

@end
