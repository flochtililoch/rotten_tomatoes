//
//  ViewController.m
//  RottenTomatoes
//
//  Created by Florent Bonomo on 10/23/15.
//  Copyright © 2015 flochtililoch. All rights reserved.
//

#import "UIImageView+FadeIn.h"
#import "MoviesViewController.h"
#import "MovieDetailsViewController.h"
#import "MovieTableViewCell.h"

@interface MoviesViewController ()<UITableViewDataSource, UITableViewDelegate>

// Outlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// UI
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

// State
@property (strong, nonatomic) NSArray *movies;
@property (nonatomic) BOOL hasError;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self initUI];
    [self fetchMovies];
}


# pragma - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.hasError == YES) {
        return 1;
    }
    return self.movies.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasError == YES) {
        return 30;
        
    }
    return 124;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasError == YES) {
        return [self.tableView dequeueReusableCellWithIdentifier:@"errorCell"];
    }
    
    MovieTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"movieCell"];
    
    cell.titleLabel.text = self.movies[indexPath.row][@"title"];
    cell.synopsisLabel.text = self.movies[indexPath.row][@"synopsis"];

    NSURL *url = [NSURL URLWithString:self.movies[indexPath.row][@"posters"][@"thumbnail"]];
    [cell.artworkImageView fadeInImageView:cell.artworkImageView
                                       url:url
                                errorImage:[UIImage imageNamed:@"error"]
                          placeholderImage:nil];
    
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MovieDetailsViewController *vc = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    [vc setMovie:[self.movies objectAtIndex:indexPath.row]];
}


# pragma - State helpers

- (void)fetchMovies {
    [self.refreshControl beginRefreshing];
    
    NSString *urlString = @"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) = ^void(NSData *data, NSURLResponse *response, NSError *error) {
        [self.loadingIndicator stopAnimating];
        [self.refreshControl endRefreshing];
        
        if (!error) {
            self.hasError = NO;
            NSError *jsonError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:kNilOptions
                                                                                 error:&jsonError];
            NSLog(@"Response: %@", responseDictionary);
            self.movies = responseDictionary[@"movies"];
        } else {
            self.hasError = YES;
            NSLog(@"An error occurred: %@", error.description);
        }

        [self.tableView reloadData];
    };
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
}


# pragma - UI helpers

- (void)initUI {
    self.title = @"Movies";
    
    [self.loadingIndicator startAnimating];
    [self.refreshControl addTarget:self
                            action:@selector(fetchMovies)
                  forControlEvents:UIControlEventValueChanged];
}

// http://stackoverflow.com/a/29600397/237637
- (UIActivityIndicatorView *)loadingIndicator {
    if(!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGRect frame = _loadingIndicator.frame;
        frame.origin.x = (self.view.frame.size.width / 2 - frame.size.width / 2);
        frame.origin.y = (self.view.frame.size.height / 2 - frame.size.height / 2);
        _loadingIndicator.frame = frame;
        [self.view addSubview:_loadingIndicator];
    }
    return _loadingIndicator;
}

// http://www.appcoda.com/pull-to-refresh-uitableview-empty/
// http://stackoverflow.com/a/12502450/237637
- (UIRefreshControl *)refreshControl {
    if(!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        _refreshControl.backgroundColor = [UIColor blackColor];
        _refreshControl.tintColor = [UIColor whiteColor];
        [_tableView addSubview:_refreshControl];
    }
    return _refreshControl;
}

@end
