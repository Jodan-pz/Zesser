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
@property (strong, nonatomic) NSString            *path;
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
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.path = [documentsDirectory stringByAppendingPathComponent:@"img-dat.plist"];
    }
    return self;
}

-(void)store{
    [NSKeyedArchiver archiveRootObject:self.images toFile:self.path];
}

-(void)retrieve{
    if ( [[NSFileManager new] fileExistsAtPath:self.path]){
        self.images = [NSKeyedUnarchiver unarchiveObjectWithFile:self.path];
    }
}

-(void)setImageView:(UIImageView *)aView withUrl:(NSURL *)url{
    if ( url == nil ) {
        [self updateImageForView:aView andImage:nil];
        return;
    }
    
    UIImage *cachedImage = [self.images valueForKey:url.description];
    if ( !cachedImage ) {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^ {
            NSError *nserror = nil;
            NSData *data = [[NSData alloc] initWithContentsOfURL: url  options:NSDataReadingUncached error:&nserror];
            if (nserror) NSLog(@"%@", nserror.description);
            UIImage *image  = nil;
            if ( data == nil ) image = nil; else image = [UIImage imageWithData:data];
            [self.images setValue:image forKey:url.description];
            [self updateImageForView:aView andImage:image];
        });
    }else{
        if ( aView.image != cachedImage ){
            [self updateImageForView:aView andImage:cachedImage];
        }
    }
}

-(void)updateImageForView:(UIImageView*)aView andImage:(UIImage*)image{
    dispatch_async(dispatch_get_main_queue(), ^{
        aView.image = nil;
        aView.backgroundColor = [UIColor clearColor];
        aView.alpha = 0;
        aView.image = image;
        [aView setNeedsLayout];
        
        if ( image == nil ) return;
        [UIView animateWithDuration:.5 animations:^{
            aView.alpha = 1;
        }];
    });
}

@end