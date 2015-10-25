//
//  Movie.h
//  RottenTomatoes
//
//  Created by Florent Bonomo on 10/24/15.
//  Copyright © 2015 flochtililoch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

// Main Info
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *synopsis;

// Artwork
@property (strong, nonatomic) NSURL *artworkThumbnailUrl;
@property (strong, nonatomic) NSURL *artworkFullsizeUrl;

// Ratings
@property (strong, nonatomic) NSString *mpaaRating;
@property (strong, nonatomic) NSString *audienceRatingImageName;
@property (strong, nonatomic) NSString *criticsRatingImageName;
@property (strong, nonatomic) NSNumber *audienceScore;
@property (strong, nonatomic) NSNumber *criticsScore;

// Cast
@property (strong, nonatomic) NSArray *cast;

// Misc
@property (strong, nonatomic) NSDate *theaterReleaseDate;
@property (strong, nonatomic) NSDate *dvdReleaseDate;
@property (nonatomic) NSInteger runtime;
@property (nonatomic) NSInteger year;

- (instancetype)initWithNSDictionnary:(NSDictionary *)movie;

@end
