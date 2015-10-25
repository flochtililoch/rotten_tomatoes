//
//  MovieDetailsViewController.m
//  RottenTomatoes
//
//  Created by Florent Bonomo on 10/23/15.
//  Copyright © 2015 flochtililoch. All rights reserved.
//

#import "UIImageView+FadeIn.h"
#import "MovieDetailsViewController.h"
#import "MovieSynopsisTableViewCell.h"

// Sections
static const NSInteger kRatingsSectionId = 0;
static const NSInteger kSynopsisSectionId = 1;
static const NSInteger kCastSectionId = 2;
static const NSInteger kMiscSectionId = 3;


@interface MovieDetailsViewController ()<UITableViewDataSource, UITableViewDelegate>

// Outlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Utils
@property (strong, nonatomic) NSNumberFormatter *percentageFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;


@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self initUI];
}


#pragma - UI

- (void)initUI {
    // Navigation
    self.title = [self.movie.title stringByAppendingFormat:@" (%ld)",(long)self.movie.year];
    
    // Table
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 474)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:headerView.frame];
    [imageView setImageWithURL:self.movie.artworkThumbnailUrl];
    [imageView setImageWithURL:self.movie.artworkFullsizeUrl];
    
    //  Assessment requirement say "All" images should fade in when not cached yet.
    //  But the visual effect is rather unpleasant when we display first the thumbnail while loading the hi-res
    //  Replaced code below with line above to prevent that.
    //  [imageView fadeInImageView:artworkCell.artworkImageView
    //                         url:self.movie.artworkFullsizeUrl
    //                  errorImage:[UIImage imageNamed:@"error"]
    //            placeholderImage:nil];
    
    [headerView addSubview:imageView];
    self.tableView.tableHeaderView = headerView;
}



# pragma - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeader = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 320, 20)];
    label.font = [label.font fontWithSize:12];
    label.text = @[@"Ratings", @"Synopsis", @"Cast", @"Misc"][section];
    sectionHeader.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    [sectionHeader addSubview:label];
    
    return sectionHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    
    if (section == kRatingsSectionId) {
        numberOfRows = 3;
    } else if (section == kSynopsisSectionId) {
        numberOfRows = 1;
    } else if (section == kCastSectionId) {
        numberOfRows = self.movie.cast.count;
    } else if (section == kMiscSectionId) {
        numberOfRows = 2;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSynopsisSectionId) {
        
        // Auto Size Synopsis Label (which happens to be a pain since within a UITableViewCell)
        // http://stackoverflow.com/a/19135591/237637
        // http://doing-it-wrong.mikeweller.com/2012/07/youre-doing-it-wrong-2-sizing-labels.html
        // eh
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13];
        label.text = self.movie.synopsis;
        label.numberOfLines = 0;
        CGSize expectedSize = [label sizeThatFits:CGSizeMake(297, MAXFLOAT)];
        CGFloat labelMargins = 16.0f;
        
        return expectedSize.height + labelMargins;
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *sectionCells = @[@"defaultCell", @"synopsisCell", @"detailCell", @"defaultCell"];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:sectionCells[indexPath.section]];

    // Ratings
    if (indexPath.section == kRatingsSectionId) {
        
        cell.textLabel.text = @[@"MPAA", @"Audience", @"Critics"][indexPath.row];
        
        NSString *rating;
        if (indexPath.row == 0) {
            rating = self.movie.mpaaRating;
        } else {
            NSNumber *score = [[NSNumber alloc] init];
            if (indexPath.row == 1) {
                score = self.movie.audienceScore;
            } else if (indexPath.row == 2) {
                score = self.movie.criticsScore;
            }
            rating = [self.percentageFormatter stringFromNumber:score];
        }
        
        cell.detailTextLabel.text = rating;
    
    // Synopsis
    } else if (indexPath.section == kSynopsisSectionId) {
        
        MovieSynopsisTableViewCell *synopsisCell = (MovieSynopsisTableViewCell *)cell;
        synopsisCell.synopsisLabel.text = self.movie.synopsis;
        cell = synopsisCell;

    // Cast
    } else if (indexPath.section == kCastSectionId) {
        
        cell.textLabel.text = self.movie.cast[indexPath.row][@"name"];
        NSArray *characters = (NSArray *)self.movie.cast[indexPath.row][@"characters"];
        cell.detailTextLabel.text = [characters componentsJoinedByString: @", "];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    // Misc
    } else if (indexPath.section == kMiscSectionId) {
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Duration";
            cell.detailTextLabel.text = [self durationFormatter:self.movie.runtime];
        } else {
            cell.textLabel.text = @"Release Date";
            [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.movie.theaterReleaseDate];
        }
    }
    
    return cell;
}


# pragma - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kCastSectionId) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Prepare Wikipedia URL. Replace spaces by underscores
        NSString *name = self.movie.cast[indexPath.row][@"name"];
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s" options:NSRegularExpressionCaseInsensitive error:&error];
        NSString *urlReadyName = [regex stringByReplacingMatchesInString:name
                                                                 options:0
                                                                   range:NSMakeRange(0, [name length])
                                                            withTemplate:@"_"];
        
        NSURL *url = [NSURL URLWithString:[@"https://en.wikipedia.org/wiki/" stringByAppendingString:urlReadyName]];
        [[UIApplication sharedApplication] openURL:url];
    }
}


#pragma - Utils

- (NSNumberFormatter *)percentageFormatter {
    if (!_percentageFormatter) {
        _percentageFormatter = [[NSNumberFormatter alloc] init];
        [_percentageFormatter setNumberStyle: NSNumberFormatterPercentStyle];
        [_percentageFormatter setMaximumFractionDigits:0];
        [_percentageFormatter setMultiplier:@1];
    }
    return _percentageFormatter;
}

- (NSString *)durationFormatter:(NSInteger)duration {
    NSInteger totalMinutes = duration;
    NSInteger minutes = totalMinutes % 60;
    NSInteger hours = (totalMinutes / 60) % 60;
    return [NSString stringWithFormat:@"%dhr.%02dmin.",(int)hours, (int)minutes];
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}


@end
