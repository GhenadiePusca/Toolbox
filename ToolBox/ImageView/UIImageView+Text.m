//
//  UIImageView+Text.m
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import "UIImageView+Text.h"

static CGFloat kFontSizeRatio = 0.5f;

@implementation UIImageView (Text)

- (void)setCircularImageWithString:(NSString *)string attributes:(NSDictionary*)attributes backgroundColor:(UIColor *)color {
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGSize imageViewSize = self.bounds.size;

    // adjust size
    if (self.contentMode == UIViewContentModeScaleToFill || self.contentMode == UIViewContentModeScaleAspectFill ||
        self.contentMode == UIViewContentModeScaleAspectFit || self.contentMode == UIViewContentModeRedraw) {
        imageViewSize.width = floorf(imageViewSize.width * screenScale) / screenScale;
        imageViewSize.height = floorf(imageViewSize.height * screenScale) / screenScale;
    }

    // ----------------------- Context begin ---------------------------- //
    UIGraphicsBeginImageContextWithOptions(imageViewSize, NO, screenScale);

    CGContextRef context = UIGraphicsGetCurrentContext();

    // Clip to circle
    CGPathRef path = CGPathCreateWithEllipseInRect(self.bounds, NULL);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGPathRelease(path);

    // Fill with collor
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, imageViewSize.width, imageViewSize.height));

    // Draw text in the context
    NSDictionary *adjustedAttributes = [self adjustedStringAtributes:attributes];
    CGSize stringSize = [string sizeWithAttributes:adjustedAttributes];
    [string drawInRect:CGRectMake(self.bounds.size.width/2 - stringSize.width/2,
                                  self.bounds.size.height/2 - stringSize.height/2,
                                  stringSize.width, stringSize.height)
        withAttributes:adjustedAttributes];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // ----------------------- Context end ---------------------------- //

    self.image = image;
}

- (NSDictionary *)adjustedStringAtributes:(NSDictionary *)attributes {
    CGFloat maxFontSize = self.bounds.size.width * kFontSizeRatio;
    if(!attributes) {
        return @{NSFontAttributeName: [UIFont systemFontOfSize:maxFontSize],
                 NSForegroundColorAttributeName: [UIColor blackColor]};
    }

    UIFont *font = [attributes objectForKey:NSFontAttributeName];
    if(font && font.pointSize <= maxFontSize) {
        return attributes;
    } else if(!font) {
        font = [UIFont systemFontOfSize:maxFontSize];
    } else if(font.pointSize > maxFontSize) {
        font = [UIFont fontWithName:font.fontName size:maxFontSize];
    }

    NSMutableDictionary *mDictionary = [NSMutableDictionary dictionaryWithDictionary:attributes];
    mDictionary[NSFontAttributeName] = font;
    return mDictionary;
}
@end
