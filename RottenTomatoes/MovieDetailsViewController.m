//
//  MovieDetailsViewController.m
//  RottenTomatoes
//
//  Created by Florent Bonomo on 10/23/15.
//  Copyright © 2015 flochtililoch. All rights reserved.
//

#import "UIImageView+FadeIn.h"
#import "MovieDetailsViewController.h"
#import "MovieArtworkTableViewCell.h"
#import "MovieRatingTableViewCell.h"
#import "MovieSynopsisTableViewCell.h"
#import "MovieCastTableViewCell.h"
#import "MovieMiscTableViewCell.h"

@interface MovieDetailsViewController ()<UITableViewDataSource, UITableViewDelegate>

// Outlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Data
@property (strong, nonatomic) NSArray *cast;

// Utils
@property (strong, nonatomic) NSNumberFormatter *percentageFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;


@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    
    self.title = self.movie[@"title"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

# pragma - Data

- (NSArray *)cast {
    if (!_cast) {
        _cast = self.movie[@"abridged_cast"];
    }
    return _cast;
}

# pragma - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    
    if (section == 0) {
        numberOfRows = 1;
    } else if (section == 1) {
        numberOfRows = 3;
    } else if (section == 2) {
        numberOfRows = 1;
    } else if (section == 3) {
        numberOfRows = self.cast.count;
    } else {
        numberOfRows = 2;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 320;

    } else if (indexPath.section == 2) {
        
        // Auto Size Synopsis Label (which happens to be a pain since within a UITableViewCell)
        // http://stackoverflow.com/a/19135591/237637
        // http://doing-it-wrong.mikeweller.com/2012/07/youre-doing-it-wrong-2-sizing-labels.html
        // eh
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:17];
        label.text = self.movie[@"synopsis"];
        label.numberOfLines = 0;
        CGSize expectedSize = [label sizeThatFits:CGSizeMake(320, MAXFLOAT)];
        
        return expectedSize.height;
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Artwork
    if (indexPath.section == 0) {
        
        MovieArtworkTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"artworkCell"];
        
        // Hack: generate valid URL from thumbnail URL
        NSURL *artworkThumbnailUrl = [NSURL URLWithString:self.movie[@"posters"][@"thumbnail"]];
        NSURL *artworkFullsizeUrl = [NSURL URLWithString:
                                        [NSString stringWithFormat: @"%@://%@/%@/%@/%@/%@/%@",
                                                  artworkThumbnailUrl.scheme, @"content6.flixster.com",
                                                  artworkThumbnailUrl.pathComponents[4],
                                                  artworkThumbnailUrl.pathComponents[5],
                                                  artworkThumbnailUrl.pathComponents[6],
                                                  artworkThumbnailUrl.pathComponents[7],
                                                  artworkThumbnailUrl.pathComponents[8]]];
        

        [(UIImageView *) cell.artworkImageView setImageWithURL:artworkThumbnailUrl];
        [(UIImageView *) cell.artworkImageView setImageWithURL:artworkFullsizeUrl];

        //  Assessment requirement say "All" images should fade in when not cached yet.
        //  But the visual effect is rather unpleasant when we display first the thumbnail while loading the hi-res
        //  Replaced code below with line above to prevent that.
        //  [(UIImageView *) cell.artworkImageView fadeInImageView:cell.artworkImageView
        //                                                     url:artworkFullsizeUrl
        //                                              errorImage:[UIImage imageNamed:@"placeholder-2"]
        //                                        placeholderImage:nil];

        return cell;
       
    // Ratings
    } else if (indexPath.section == 1) {
        
        MovieRatingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ratingCell"];
        
        
        cell.ratingTypeLabel.text = @[@"MPAA", @"Audience", @"Critics"][indexPath.row];

        // MPAA
        if (indexPath.row == 0) {
            
            cell.ratingValueLabel.text = self.movie[@"mpaa_rating"];

        // Audience & Critics
        } else {
            
            NSInteger keyIndex = indexPath.row - 1;

            NSString *ratingValue = [self.percentageFormatter stringFromNumber:self.movie[@"ratings"][@[@"audience_score", @"critics_score"][keyIndex]]];
            UIImage *ratingImage = [UIImage imageNamed: self.movie[@"ratings"][@[@"critics_rating", @"audience_rating"][keyIndex]]];
            
            cell.ratingValueLabel.text = ratingValue;
            [cell.ratingImageView setImage:ratingImage];
        }
        
        return cell;
    
    // Synopsis
    } else if (indexPath.section == 2) {
        
        MovieSynopsisTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"synopsisCell"];
        cell.synopsisLabel.text = self.movie[@"synopsis"];
        cell.synopsisLabel.frame = cell.contentView.frame;
//        cell.synopsisLabel.numberOfLines = 0;
//        cell.synopsisLabel.lineBreakMode = NSLineBreakByWordWrapping;


        return cell;

    // Cast
    } else if (indexPath.section == 3) {
        
        MovieCastTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"castCell"];
        cell.castLabel.text = self.cast[indexPath.row][@"name"];
        
        return cell;

    // Misc
    } else {
        
        MovieMiscTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"miscCell"];
        
        if (indexPath.row == 0) {
            cell.miscLabel.text = @"Duration";
            cell.miscValue.text = [self durationFormatter:self.movie[@"runtime"]];
        } else {
            cell.miscLabel.text = @"Release Date";
            [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [self.dateFormatter dateFromString:self.movie[@"release_dates"][@"theater"]];
            [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            cell.miscValue.text = [self.dateFormatter stringFromDate:date];
        }

        return cell;

    }

}

#pragma mark - Utils

- (NSNumberFormatter *)percentageFormatter {
    if (!_percentageFormatter) {
        _percentageFormatter = [[NSNumberFormatter alloc] init];
        [_percentageFormatter setNumberStyle: NSNumberFormatterPercentStyle];
        [_percentageFormatter setMaximumFractionDigits:0];
        [_percentageFormatter setMultiplier:@1];
    }
    return _percentageFormatter;
}

- (NSString *)durationFormatter:(NSString *)durationInMinutes {
    int totalMinutes = [durationInMinutes intValue];
    int minutes = totalMinutes % 60;
    int hours = (totalMinutes / 60) % 60;
    return [NSString stringWithFormat:@"%dhr.%02dmin.",hours, minutes];
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}


@end
