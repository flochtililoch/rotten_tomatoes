//
//  MovieRatingTableViewCell.h
//  RottenTomatoes
//
//  Created by Florent Bonomo on 10/23/15.
//  Copyright © 2015 flochtililoch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieRatingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ratingTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UILabel *ratingValueLabel;

@end
