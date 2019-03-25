//
//  InfiniteDatePageViewController.h
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import <UIKit/UIKit.h>
#import "DateSpan.h"
#import "DatePageHeader.h"
#import "InfinitePaginatorViewController.h"

@interface InfiniteDatePageViewController : UIViewController <PaginatorViewControllerDelegate>
@property (nonatomic, strong, nullable) DatePageHeader *headerView;
@property (nonatomic, strong, readonly, nonnull) DateSpan *currentDateSpan;
@property (nonatomic, strong, readonly, nonnull)  InfinitePaginatorViewController *paginator;
// The content page that is currently shown will be notified to load the data after loadDataDelay amount of time.
// Needed to detect if the user stops scrolling. So if the delta between pages scroll is less than loadDataDelay, the page the user is
// swiping from will not be notified to load data. This way it's assured that on fast scrolling the data loaded only when the fast scroll is done.
@property (nonatomic, assign)                     CGFloat loadDataDelay;

// Passed vcModel should be a subclass of GCMPageContentViewController
- (nullable instancetype)initWithDateSpan:(nonnull DateSpan *)dateSpan
                           contentVCModel:(nonnull Class)vcModel
                               headerView:(nullable DatePageHeader *)header;
@end
