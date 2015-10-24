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

    [self initUI];
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
        numberOfRows = self.cast.count;
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
        label.text = self.movie[@"synopsis"];
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
            rating = self.movie[@"mpaa_rating"];
        } else {
            rating = [self.percentageFormatter stringFromNumber:self.movie[@"ratings"][@[@"mpaa_rating", @"audience_score", @"critics_score"][indexPath.row]]];
        }
        cell.detailTextLabel.text = rating;
    
    // Synopsis
    } else if (indexPath.section == kSynopsisSectionId) {
        
        MovieSynopsisTableViewCell *synopsisCell = (MovieSynopsisTableViewCell *)cell;
        synopsisCell.synopsisLabel.text = self.movie[@"synopsis"];
        cell = synopsisCell;

    // Cast
    } else if (indexPath.section == kCastSectionId) {
        
        cell.textLabel.text = self.cast[indexPath.row][@"name"];
        NSArray *characters = (NSArray *)self.cast[indexPath.row][@"characters"];
        cell.detailTextLabel.text = [characters componentsJoinedByString: @", "];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    // Misc
    } else if (indexPath.section == kMiscSectionId) {
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Duration";
            cell.detailTextLabel.text = [self durationFormatter:self.movie[@"runtime"]];
        } else {
            cell.textLabel.text = @"Release Date";
            [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [self.dateFormatter dateFromString:self.movie[@"release_dates"][@"theater"]];
            [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            cell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
        }
    }
    
    return cell;
}


# pragma - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kCastSectionId) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Prepare Wikipedia URL. Replace spaces by underscores
        NSString *name = self.cast[indexPath.row][@"name"];
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


#pragma mark - UI

- (void)initUI {
    // Navigation
    self.title = self.movie[@"title"];
    
    // Table
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
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
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 474)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:headerView.frame];
    [imageView setImageWithURL:artworkThumbnailUrl];
    [imageView setImageWithURL:artworkFullsizeUrl];
    
    //  Assessment requirement say "All" images should fade in when not cached yet.
    //  But the visual effect is rather unpleasant when we display first the thumbnail while loading the hi-res
    //  Replaced code below with line above to prevent that.
    //  [imageView fadeInImageView:artworkCell.artworkImageView
    //                         url:artworkFullsizeUrl
    //                  errorImage:[UIImage imageNamed:@"error"]
    //            placeholderImage:nil];

    [headerView addSubview:imageView];
    self.tableView.tableHeaderView = headerView;
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
