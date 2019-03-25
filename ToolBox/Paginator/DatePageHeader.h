//
//  DaptePageHeader.h
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import <UIKit/UIKit.h>
#import "DateSpan.h"

@protocol DatePageHeaderDelegate <NSObject>
@optional
- (void)didTapForwardButton;
- (void)didTapBackwardButton;
@end

@interface DatePageHeader : UIView

@property(nonatomic, strong, readonly, nonnull) UIButton *forwardButton;
@property(nonatomic, strong, readonly, nonnull) UIButton *backwardButton;
@property(nonatomic, strong, readonly, nonnull) UILabel  *dateSpanLabel;
@property(nonatomic, strong, readonly, nonnull) UILabel  *dateSpanDescription;

@property (nonatomic, strong, nullable) NSString *presentDateSpanDescription;
@property (nonatomic, strong, nullable) NSString *pastDateSpanDescription;
@property (nonatomic, strong, nullable) NSDateFormatter *dateSpanFormatter;
@property (nonatomic, strong, nullable) NSString *dateSpanFormat;

@property(nonatomic,weak, nullable) id<DatePageHeaderDelegate> delegate;

- (void)updateWith:(nullable DateSpan *)dateSpan;
@end
