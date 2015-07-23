//
//  JDNSharedImages.m
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNSharedImages.h"
#import "JDNDailyData.h"

@interface JDNSharedImages()
@property (strong, nonatomic) NSMutableDictionary *images;
@end

@implementation JDNSharedImages

static JDNSharedImages *sharedImages_;   

+ (void)initialize{
    sharedImages_ = [[self alloc] initSingleton];
}

+ (JDNSharedImages*)sharedImages{
    return sharedImages_;
}

- (JDNSharedImages*)initSingleton{
    self = [super init];
    if ( self ){
        self.images = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)setImageView:(UIImageView *)aView withUrl:(NSURL *)url{
    UIImage *cachedImage = nil; //[self.images valueForKey:url.description];
    if (!cachedImage){
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT , 0 ) , ^ {
            NSData *data = [[NSData alloc] initWithContentsOfURL: url];
            dispatch_async(dispatch_get_main_queue(), ^{                
                if ( data == nil ){
                    [self updateImageForView:aView andImage:nil];
                    return;
                }
                
                UIImage *image = [UIImage imageWithData:data];
                [self updateImageForView:aView andImage:image];
                [self.images setValue:image forKey:url.description];
            });
        });
    }else{
        if ( aView.image != cachedImage ){
            [self updateImageForView:aView andImage:cachedImage];
        }
    }
}

-(void)updateImageForView:(UIImageView*)aView andImage:(UIImage*)image{
    aView.image = nil;
    aView.backgroundColor = [UIColor clearColor];
    [aView setNeedsLayout];
    if ( image == nil ) return;
    aView.alpha = 0;
    aView.image = image;
    [UIView animateWithDuration:.5 animations:^{
        aView.alpha = 1;
    }];
}

@end