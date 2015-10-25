//
//  UIImageView+FadeIn.m
//  RottenTomatoes
//
//  Created by Florent Bonomo on 10/23/15.
//  Copyright © 2015 flochtililoch. All rights reserved.
//

#import "UIImageView+FadeIn.h"

@implementation UIImageView (FadeIn)

- (void)fadeInImageView:(UIImageView *)imageView
                    url:(NSURL *)url
             errorImage:(UIImage *)errorImage
       placeholderImage:(UIImage *)placeholderImage {

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    void (^imageFadeIn)(NSURLRequest *request , NSHTTPURLResponse *response , id image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, id image) {
        if ([image class] != [UIImage class]) {
            image = errorImage;
        }
        [imageView setImage:image];
        if(response != nil) {
            imageView.alpha = 0;
            [UIView beginAnimations:@"fade in" context:nil];
            [UIView setAnimationDuration:.5];
            imageView.alpha = 1.0;
            [UIView commitAnimations];
        }
    };
    
    [imageView setImageWithURLRequest:request
                     placeholderImage:placeholderImage
                              success:imageFadeIn
                              failure:imageFadeIn];


}

@end
