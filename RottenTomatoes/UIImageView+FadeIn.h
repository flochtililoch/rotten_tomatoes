//
//  UIImageView+FadeIn.h
//  RottenTomatoes
//
//  Created by Florent Bonomo on 10/23/15.
//  Copyright © 2015 flochtililoch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"

@interface UIImageView (FadeIn)

- (void)fadeInImageView:(UIImageView *)imageView
                    url:(NSURL *)url
             errorImage:(UIImage *)errorImage
       placeholderImage:(UIImage *)placeholderImage;

@end
