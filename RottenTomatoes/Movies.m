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

@end

@implementation Movies

- (NSUInteger)count {
    return [self.movies count];
}

- (Movie *)objectAtIndex:(NSUInteger)index {
    return [self.movies objectAtIndex:index];
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
