//
//  Movie.m
//  RottenTomatoes
//
//  Created by Florent Bonomo on 10/24/15.
//  Copyright © 2015 flochtililoch. All rights reserved.
//

#import "Movie.h"

@interface Movie ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation Movie

- (instancetype)initWithNSDictionnary:(NSDictionary *)movie {
    self = [super init];
    if (self) {
        
        // Main Info
        _title = movie[@"title"];
        _synopsis = movie[@"synopsis"];
        
        // Artwork
        _artworkThumbnailUrl = [NSURL URLWithString:movie[@"posters"][@"thumbnail"]];
        _artworkFullsizeUrl = [NSURL URLWithString:
                               [NSString stringWithFormat: @"%@://%@/%@/%@/%@/%@/%@",
                                _artworkThumbnailUrl.scheme, @"content6.flixster.com",
                                _artworkThumbnailUrl.pathComponents[4],
                                _artworkThumbnailUrl.pathComponents[5],
                                _artworkThumbnailUrl.pathComponents[6],
                                _artworkThumbnailUrl.pathComponents[7],
                                _artworkThumbnailUrl.pathComponents[8]]];
        
        // Ratings
        _mpaaRating = movie[@"mpaa_rating"];
        _audienceRatingImageName = movie[@"ratings"][@"audience_rating"];
        _criticsRatingImageName = movie[@"ratings"][@"critics_rating"];
        _audienceScore = [NSNumber numberWithInt:[movie[@"ratings"][@"audience_score"] intValue]];
        _criticsScore = [NSNumber numberWithInt:[movie[@"ratings"][@"critics_score"] intValue]];
        
        // Cast
        _cast = movie[@"abridged_cast"];
        
        // Misc
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        _theaterReleaseDate = [dateFormatter dateFromString:movie[@"release_dates"][@"theater"]];
        _dvdReleaseDate = [dateFormatter dateFromString:movie[@"release_dates"][@"dvd"]];
        _runtime = [movie[@"runtime"] intValue];
        _year = [movie[@"year"] intValue];
        
    }
    return self;
}

@end