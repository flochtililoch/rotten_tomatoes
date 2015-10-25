//
//  Movies.m
//  RottenTomatoes
//
//  Created by Florent Bonomo on 10/24/15.
//  Copyright © 2015 flochtililoch. All rights reserved.
//

#import "Movies.h"

@interface Movies ()

@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSMutableArray *filteredMovies;
@property (strong, nonatomic) NSMutableString *filter;

@end

@implementation Movies

- (NSMutableArray *)filteredMovies {
    if(!_filteredMovies) {
        _filteredMovies = [[NSMutableArray alloc] init];
    }
    return _filteredMovies;
}

- (NSString *)filter {
    if(!_filter) {
        _filter = [[NSMutableString alloc] initWithString:@""];
    }
    return _filter;
}

- (NSUInteger)count {
    return [self.filteredMovies count];
}

- (NSMutableArray *)filterWithString:(NSString *)filter {
    [self.filteredMovies removeAllObjects];
    for (Movie *movie in self.movies) {
        NSRange titleRange = [movie.title rangeOfString:filter options:NSCaseInsensitiveSearch];
        if(titleRange.location != NSNotFound || [filter isEqualToString:@""]) {
            [self.filteredMovies addObject:movie];
        }
    }
    return self.filteredMovies;
}

- (NSMutableArray *)filterWithString:(NSString *)filter andDVDOnly:(BOOL)dvdOnly {
    NSMutableArray *filteredMovies = [[NSMutableArray alloc] initWithArray:[self filterWithString:filter]];
    if (dvdOnly == YES) {
        for (Movie *movie in filteredMovies) {
            if (![movie isAvailableInDVD]) {
                [self.filteredMovies removeObject:movie];
            }
        }
    }
    return self.filteredMovies;
}

- (Movie *)objectAtIndex:(NSUInteger)index{
    return [self.filteredMovies objectAtIndex:index];
}

- (void)fetch:(void (^)())successHandler error:(void (^)())errorHandler {
    
    NSString *urlString = @"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) = ^void(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            NSError *jsonError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:kNilOptions
                                                                                 error:&jsonError];
            NSLog(@"Response: %@", responseDictionary);
            
            NSMutableArray *movies = [[NSMutableArray alloc] init];
            for (NSDictionary *movieDictionnary in responseDictionary[@"movies"]) {
                Movie *movie = [[Movie alloc] initWithNSDictionnary:movieDictionnary];
                [movies addObject:movie];
            }
            self.movies = movies;
            [self filterWithString:@""];

            successHandler();
        } else {
            NSLog(@"An error occurred: %@", error.description);
            errorHandler();
        }
    };
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
}

@end
