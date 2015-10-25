//
//  ViewController.m
//  RottenTomatoes
//
//  Created by Florent Bonomo on 10/23/15.
//  Copyright © 2015 flochtililoch. All rights reserved.
//

#import "Movies.h"
#import "UIImageView+FadeIn.h"
#import "MoviesViewController.h"
#import "MovieDetailsViewController.h"
#import "MovieTableViewCell.h"

@interface MoviesViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITabBarDelegate>

// Outlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

// UI
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

// State
@property (strong, nonatomic) Movies *movies;
@property (nonatomic) BOOL hasError;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    self.tabBar.delegate = self;

    [self initUI];
    [self fetchMovies];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MovieDetailsViewController *vc = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    [vc setMovie:[self.movies objectAtIndex:indexPath.row]];
}


# pragma - Model

- (Movies *)movies {
    if(!_movies) {
        _movies = [[Movies alloc] init];
    }
    return _movies;
}

- (void)fetchMovies {
    [self.refreshControl beginRefreshing];
    
    void (^successHandler)() = ^void() {
        [self.loadingIndicator stopAnimating];
        [self.refreshControl endRefreshing];
        self.hasError = NO;
        [self filterMovies];
    };
    
    void (^errorHandler)() = ^void() {
        [self.loadingIndicator stopAnimating];
        [self.refreshControl endRefreshing];
        self.hasError = YES;
        [self filterMovies];
    };
    
    [self.movies fetch:successHandler error:errorHandler];
}

- (void)filterMovies {
    [self.movies filterWithString:self.searchBar.text
                       andDVDOnly:self.tabBar.selectedItem == [self.tabBar.items objectAtIndex:1]];
    [self.tableView reloadData];

}

# pragma - UI helpers

- (void)initUI {
    // Navigation
    self.title = @"Movies";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];;
    
    // Tab bar
    self.tabBar.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    self.tabBar.tintColor = [UIColor blackColor];
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    
    // Loading
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
        _refreshControl.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
        _refreshControl.tintColor = [UIColor darkGrayColor];
        [_tableView addSubview:_refreshControl];
    }
    return _refreshControl;
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
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasError == YES) {
        return [self.tableView dequeueReusableCellWithIdentifier:@"errorCell"];
    }
    
    Movie *movie = [self.movies objectAtIndex:indexPath.row];
    MovieTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"movieCell"];
    
    cell.titleLabel.text = movie.title;
    cell.synopsisLabel.text = movie.synopsis;
    [cell.criticsImageView setImage:[UIImage imageNamed: movie.criticsRatingImageName]];
    [cell.audienceImageView setImage:[UIImage imageNamed: movie.audienceRatingImageName]];
    [cell.artworkImageView fadeInImageView:cell.artworkImageView
                                       url:movie.artworkThumbnailUrl
                                errorImage:[UIImage imageNamed:@"error"]
                          placeholderImage:nil];
    
    return cell;
}


# pragma - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewWillBeginDragging:(UITableView *)scrollView
{
    [self.searchBar resignFirstResponder];
}


# pragma - UISearchBarDelegate

- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text {
    [self filterMovies];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}


# pragma - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self filterMovies];
}

@end
