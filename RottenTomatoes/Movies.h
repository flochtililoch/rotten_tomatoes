//
//  Movies.h
//  RottenTomatoes
//
//  Created by Florent Bonomo on 10/24/15.
//  Copyright © 2015 flochtililoch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"

@interface Movies : NSObject

- (NSUInteger)count;

- (Movie *)objectAtIndex:(NSUInteger)index;

- (void)fetch:(void (^)())successHandler error:(void (^)())errorHandler;

@end
