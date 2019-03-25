//
//  PaginatorConstants.h
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#ifndef PaginatorConstants_h
#define PaginatorConstants_h

typedef NS_ENUM(NSInteger, VC_POSITION) {
    VC_POSITION_LEFT = 0,
    VC_POSITION_CENTER,
    VC_POSITION_RIGHT
};

typedef NS_ENUM(NSInteger, SCROLL_DIRECTION) {
    SCROLL_DIRECTION_FORWARD = 0,
    SCROLL_DIRECTION_BACKWARD
};

static const CGFloat kDatePageHeaderDateSpanPadding = 15;
static const CGFloat kDatePageHeaderDefaultPadding = 5;
static const CGFloat kDatePageHeaderArroHeight = 30;
static const CGFloat kDatePageVCFastScrollDelay = 0.125;
static const NSString *kDatePageHeaderShortDateSpanFormat = @"%@";
static const NSString *kDatePageHeaderDateSpanFormat = @"%@ - %@";

#endif /* PaginatorConstants_h */
