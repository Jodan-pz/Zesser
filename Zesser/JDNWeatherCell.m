//
//  JDNWeatherCell.m
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNWeatherCell.h"
#import "JDNDailyData.h"

@implementation JDNWeatherCell

-(void)setupCellWithDailyData:(JDNDailyData *)dailyData{

    if (!dailyData) return;
    
    self.hourOfDay.text = dailyData.hourOfDay;
    if (dailyData.temperature.length != 0){
        self.temperature.text = [NSString stringWithFormat:@"%@°", dailyData.temperature];
    }else{
        self.temperature.text = @"-";
    }
    if (dailyData.apparentTemperature.length != 0){
        [JDNClientHelper configureTemperatureLayoutForLabel:self.apparentTemperature
                                                    byValue:dailyData.apparentTemperature.integerValue];
        self.apparentTemperature.text = [NSString stringWithFormat:@"(%@°)", dailyData.apparentTemperature];
    }else{
        self.apparentTemperature.text = @"-";
    }
    
    if ( [JDNClientHelper stringIsNilOrEmpty:dailyData.windSpeed]){
        self.windSpeed.text = @"";
        self.windSpeed.alpha = 0;
        [[JDNSharedImages sharedImages] updateImageForView:self.windImage andImage:nil];
    }else{
        self.windSpeed.alpha = 1;
        self.windImage.layer.zPosition = 1;
        self.windSpeed.text = dailyData.windSpeed;
        self.windSpeed.layer.cornerRadius = 8.0;
        [[JDNSharedImages sharedImages] setImageView:self.windImage withUrl:[NSURL URLWithString:dailyData.windImage]];
    }
    
    [[JDNSharedImages sharedImages] setImageView:self.forecastImage withUrl:[NSURL URLWithString:dailyData.forecastImage]];
    self.forecast.text = dailyData.forecast;
    self.forecast.textColor = [UIColor colorWithRed:0.828 green:0.757 blue:0.941 alpha:1.000];
    self.wind.text = dailyData.wind;
    
    if ( dailyData.percentageRainfall ) {
        if ([dailyData.percentageRainfall isEqualToString:@"-"]) {
            [[JDNSharedImages sharedImages] updateImageForView:self.rainShowers
                                                      andImage:nil];

            return;
        }
        
        UIImage *imgPerc = [self drawText:dailyData.percentageRainfall
                                           inImage:[UIImage imageNamed:@"raindrop.png"]];
        
        [[JDNSharedImages sharedImages] updateImageForView:self.rainShowers
                                                  andImage:imgPerc];
    }
    
}

-(CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode  {
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    NSDictionary * attributes = @{NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName:paragraphStyle
                                  };
    
    
    CGRect textRect = [text boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    return textRect.size;
}

-(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image {
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    
    UITextView *myText = [[UITextView alloc] init];
    myText.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:10.0f];
    myText.text = text;
    
    NSDictionary *textAttributes = @{NSFontAttributeName: myText.font,
                                     NSForegroundColorAttributeName:[UIColor blueColor]};
    
    CGSize maximumLabelSize = CGSizeMake(image.size.width,image.size.height);
    CGSize expectedLabelSize = [self frameForText:myText.text
                                     sizeWithFont:myText.font
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:NSLineBreakByWordWrapping];
    
    myText.frame = CGRectMake((image.size.width / 2) - (expectedLabelSize.width / 2),
                              (image.size.height / 2) - (expectedLabelSize.height / 3),
                              image.size.width,
                              image.size.height);
    
    [myText.text drawInRect:myText.frame withAttributes:textAttributes];
    UIImage *myNewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return myNewImage;
}

@end