//
//  DaptePageHeader.m
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import "DatePageHeader.h"
// Utils
#import "DateSpan.h"
#import <Masonry/Masonry.h>
#import "PaginatorConstants.h"

@interface DatePageHeader()
@property(nonatomic,strong) DateSpan *dateSpan;
@end

@implementation DatePageHeader

- (instancetype)init {
    if(self = [super init]) {
        [self setupContent];
        [self setupLayout];
        return self;
    }

    return nil;
}

#pragma mark - Layout
- (void)setupLayout {
    [self addSubview:self.forwardButton];
    [self addSubview:self.backwardButton];
    [self addSubview:self.dateSpanLabel];
    [self addSubview:self.dateSpanDescription];

    [self.forwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kDatePageHeaderDefaultPadding);
        make.right.equalTo(self).offset(-kDatePageHeaderDefaultPadding);
        make.height.width.mas_equalTo(kDatePageHeaderArroHeight);
    }];

    [self.backwardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self).offset(kDatePageHeaderDefaultPadding);
        make.bottom.equalTo(self.forwardButton);
        make.height.width.equalTo(self.forwardButton);
    }];

    [self.dateSpanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.forwardButton);
        make.left.greaterThanOrEqualTo(self.backwardButton.mas_right).offset(kDatePageHeaderDateSpanPadding);
        make.right.lessThanOrEqualTo(self.forwardButton.mas_left).offset(-kDatePageHeaderDateSpanPadding);
        make.centerX.equalTo(self);
    }];

    [self.dateSpanDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backwardButton.mas_bottom).offset(kDatePageHeaderDefaultPadding);
        make.left.greaterThanOrEqualTo(self.backwardButton.mas_right);
        make.right.lessThanOrEqualTo(self.forwardButton.mas_left);
        make.bottom.equalTo(self).offset(-kDatePageHeaderDefaultPadding);
        make.centerX.equalTo(self);
    }];
}

#pragma mark - Components setup
- (void)setupContent {
    _forwardButton = [UIButton new];
    [_forwardButton setTitle:@"Next" forState:UIControlStateNormal];
    [_forwardButton addTarget:self action:@selector(forwardButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    _dateSpanLabel = [UILabel new];
    _dateSpanLabel.textColor = [UIColor grayColor];
    _dateSpanLabel.font = [UIFont systemFontOfSize:14];
    _dateSpanLabel.textAlignment = NSTextAlignmentCenter;
    _dateSpanLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    _dateSpanDescription = [UILabel new];
    _dateSpanDescription.textColor = [UIColor grayColor];
    _dateSpanDescription.font = [UIFont systemFontOfSize:12];
    _dateSpanDescription.textAlignment = NSTextAlignmentCenter;
    _dateSpanDescription.lineBreakMode = NSLineBreakByTruncatingTail;

    _backwardButton = [UIButton new];
    [_backwardButton setTitle:@"Previous" forState:UIControlStateNormal];
    [_backwardButton addTarget:self action:@selector(backwardButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - actions
- (void)forwardButtonTapped {
    if([self.delegate respondsToSelector:@selector(didTapForwardButton)]) {
        [self.delegate didTapForwardButton];
    }
}

- (void)backwardButtonTapped {
    if([self.delegate respondsToSelector:@selector(didTapBackwardButton)]) {
        [self.delegate didTapBackwardButton];
    }
}

#pragma mark - Update
- (void)updateWith:(DateSpan *)dateSpan {
    self.dateSpan = dateSpan;
    self.dateSpanLabel.text = [NSString stringWithFormat:self.dateSpanFormat, [self.dateSpanFormatter stringFromDate:self.dateSpan.startDate], [self.dateSpanFormatter stringFromDate:self.dateSpan.endDate]];
    self.dateSpanDescription.text = [self.dateSpan isCurrentPeriod] ? self.presentDateSpanDescription : self.pastDateSpanDescription;
    if([self.dateSpan isCurrentPeriod]) {
        self.forwardButton.enabled = NO;
    } else {
        self.forwardButton.enabled = YES;
    }

    if([self.dateSpan isMinDateSpan]) {
        self.backwardButton.enabled = NO;
    } else {
        self.backwardButton.enabled = YES;
    }
}
@end

