//
//  UIImageView+Text.h
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Text)
- (void)setCircularImageWithString:(nonnull NSString *)string
                        attributes:(nonnull NSDictionary*)attributes
                   backgroundColor:(nonnull UIColor *)color;
@end
