//
//  InfinitePaginatorViewController.m
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import "InfinitePaginatorViewController.h"
#import <Masonry/Masonry.h>

const NSInteger kScrollWidthMultiplier = 3;
const CGFloat   kBounceOffset = 0.1;
@interface InfinitePaginatorViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) NSMutableArray<UIViewController *> *vctrls;
@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) CGFloat previousScrollIndex;

// Rubber Banding
@property (nonatomic, assign) CGFloat rubberBandingScrollDistance;
@property (nonatomic, assign) CGFloat rubberBandingPrevOffset;
@property (nonatomic, assign) BOOL rubberBandingFastDragg;
@property (nonatomic, assign) BOOL draggingDone;
@end

@implementation InfinitePaginatorViewController

- (instancetype)initWithVCModel:(Class)vcClass {
    NSMutableArray *viewControllers = [NSMutableArray arrayWithObjects:[vcClass new], [vcClass new], [vcClass new], nil];
    self = [[InfinitePaginatorViewController alloc] initWithViewControllers:viewControllers];
    return self;
}

- (instancetype)initWithViewControllers:(NSMutableArray *)viewControllers {
    if (self = [super init]) {
        UIViewController *viewController;
        for (viewController in viewControllers) {
            NSAssert([viewController isKindOfClass:[UIViewController class]], @"The model class should be subclass of UIViewController");
        }
        _vctrls = viewControllers;
        _previousScrollIndex = 1.0;
        _forwardScrollEnabled = YES;
        _backwardScrollEnabled = YES;
        _rubberBandingResistanceFactor = 0.2;
        _rubberBandingOffset = 0.1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self contentScrollViewSetup];
    [self contentViewControllersSetup];
    self.view.backgroundColor = [UIColor clearColor];
}

#pragma mark - Content Setup
- (void)contentScrollViewSetup {
    self.contentScrollView = [UIScrollView new];
    // Debug color
    self.contentScrollView.backgroundColor = [UIColor clearColor];
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.delegate = self;
    self.contentScrollView.bounces = NO;
    self.contentScrollView.pagingEnabled = YES;
    if (@available(iOS 11.0, *)) {
        self.contentScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    [self.view addSubview:self.contentScrollView];
    [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self centerScrollView];
}

- (void)contentViewControllersSetup {
    for(UIViewController *controller in self.vctrls) {
        [self addChildViewController:controller];
        [self.contentScrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
}

#pragma mark - Positioning
- (void)updateViewControllersFrameOrigin {
    [self vcUpdateCenterFrameOrigin:VC_POSITION_LEFT];
    [self vcUpdateCenterFrameOrigin:VC_POSITION_CENTER];
    [self vcUpdateCenterFrameOrigin:VC_POSITION_RIGHT];
}

- (void)vcUpdateCenterFrameOrigin:(VC_POSITION)position {
    self.vctrls[position].view.frame = CGRectMake(position*self.viewWidth,0,self.vctrls[position].view.frame.size.width,self.vctrls[position].view.frame.size.height);
}

- (void)centerScrollView {
    [self.contentScrollView setContentOffset:CGPointMake(self.viewWidth, 0) animated:NO];
}

#pragma mark - Resize
- (void)resizeContent {
    self.viewWidth = self.view.frame.size.width;
    self.contentScrollView.contentSize = CGSizeMake(kScrollWidthMultiplier*self.viewWidth, self.contentScrollView.frame.size.height);
    [self resizeViewControllers];
    [self updateViewControllersFrameOrigin];
    [self centerScrollView];
}

- (void)resizeViewControllers {
    [self resizeViewController:self.vctrls[VC_POSITION_LEFT]];
    [self resizeViewController:self.vctrls[VC_POSITION_CENTER]];
    [self resizeViewController:self.vctrls[VC_POSITION_RIGHT]];
}

- (void)resizeViewController:(UIViewController *)controller {
    controller.view.frame = CGRectMake(controller.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - UIScrollView delegate methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.rubberBandingFastDragg = NO;
    self.draggingDone = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.draggingDone = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollIndex = scrollView.contentOffset.x/self.viewWidth;

    if((!self.forwardScrollEnabled && scrollIndex > VC_POSITION_CENTER) || (!self.backwardScrollEnabled && scrollIndex < VC_POSITION_CENTER)) {
        // Imitate rubber banding behavior

        CGFloat scrollOffset = fabs(scrollView.contentOffset.x - self.viewWidth); // Transfer scroll offset to [0, self.viewWidth] range for easier calculations;
        // Scroll offset with no resistance
        CGFloat maxOffset = self.viewWidth * self.rubberBandingOffset;
        // If over max offset the resistance is applied
        BOOL overMaxOffset = scrollOffset >= maxOffset;

        if(self.rubberBandingFastDragg) {
            // Fast dragg detected scroll back to initial position, otherwise the content offset will remain in unexpected position
            [scrollView setContentOffset:CGPointMake(self.viewWidth, 0) animated:NO];
        } else if(overMaxOffset) {
            CGFloat rubberBandingCurrentOffset = maxOffset - scrollOffset;
            if(rubberBandingCurrentOffset <= self.rubberBandingPrevOffset) {
                self.rubberBandingFastDragg = self.draggingDone; // detect fast scroll

                // Actual scrolled distance, use this to calculate new offset. A function over rubberBandingCurrentOffset to calculate new
                // offset is very unstable, as scroll offset will not have stable linear progression when scrolling in one direction, while the new offset
                // should have stable linear progression.
                self.rubberBandingScrollDistance += rubberBandingCurrentOffset - self.rubberBandingPrevOffset;

                CGFloat prevOffset = self.rubberBandingResistanceFactor * self.rubberBandingScrollDistance;
                // Apply screen scale for smooth transition
                CGFloat adjustedPrevOffset = round([UIScreen mainScreen].scale * prevOffset)/[UIScreen mainScreen].scale;
                self.rubberBandingPrevOffset = adjustedPrevOffset;

                CGFloat newContentOffset =  maxOffset - self.rubberBandingPrevOffset;
                CGFloat scrollDiretctionAdjustedOffset = (scrollIndex > VC_POSITION_CENTER ? newContentOffset : -newContentOffset); // Left or Right
                // Transfer scroll offset back to [self.viewWidth, 2*self.viewWidth] range;
                CGFloat normalizedOffset = scrollDiretctionAdjustedOffset + self.viewWidth;
                [scrollView setContentOffset:CGPointMake(normalizedOffset, 0)];
            } else {
                // Adjust offset for scrolling back to initial position
                self.rubberBandingScrollDistance = rubberBandingCurrentOffset/self.rubberBandingResistanceFactor;
                self.rubberBandingPrevOffset = rubberBandingCurrentOffset;
            }
        } else {
            self.rubberBandingScrollDistance = 0;
            self.rubberBandingPrevOffset = 0;
        }
        return;
    }

    // Normalize the scrollIndex to be bounded in [VC_POSITION_LEFT, VC_POSITION_RIGHT] range; it's possible to get the value
    // outside of the range on fast pagination.
    scrollIndex = MIN(MAX(VC_POSITION_LEFT, scrollIndex), VC_POSITION_RIGHT);
    [self scrollIndexChanged:scrollIndex];
}

#pragma mark - Page change handling
// If the page did change then reorder the view controllers in the array.
// E.g If we have initial vc's setup like:
//      1 - 2 - 3, the on page change we have:
//   - Scroll to the left results -> 3-1-2 -> 2-3-1 -> 1-2-3 ....
//   - Scroll to the right results -> 2-3-1 -> 3-1-2 -> 1-2-3 ...
// After the array is correctly reordered the view controllers center constraints are updated and
// the scroll view is recentered to show the vc at the VC_POSITION_CENTER index.
- (void)scrollIndexChanged:(CGFloat)scrollIndex {
    if(self.previousScrollIndex == scrollIndex) {
        return;
    }

    self.previousScrollIndex = scrollIndex;
    SCROLL_DIRECTION direction = scrollIndex > VC_POSITION_CENTER ? SCROLL_DIRECTION_FORWARD : SCROLL_DIRECTION_BACKWARD;
    if(scrollIndex == VC_POSITION_LEFT) {
        UIViewController *lastVctrl = self.vctrls[VC_POSITION_RIGHT];
        self.vctrls[VC_POSITION_RIGHT] = self.vctrls[VC_POSITION_CENTER];
        self.vctrls[VC_POSITION_CENTER] = self.vctrls[VC_POSITION_LEFT];
        self.vctrls[VC_POSITION_LEFT] = lastVctrl;
    } else if(scrollIndex == VC_POSITION_RIGHT){;
        UIViewController *firstVctrl = self.vctrls[VC_POSITION_LEFT];
        self.vctrls[VC_POSITION_LEFT] = self.vctrls[VC_POSITION_CENTER];
        self.vctrls[VC_POSITION_CENTER] = self.vctrls[VC_POSITION_RIGHT];
        self.vctrls[VC_POSITION_RIGHT] = firstVctrl;
    } else {
        return;
    }

    self.vctrls[VC_POSITION_LEFT].view.hidden = !self.backwardScrollEnabled;
    self.vctrls[VC_POSITION_RIGHT].view.hidden = !self.forwardScrollEnabled;

    if([self.delegate respondsToSelector:@selector(paginator:didChangePage:presentedPage:reusePage:)]) {
        UIViewController *reusePage = self.vctrls[direction == SCROLL_DIRECTION_BACKWARD ? VC_POSITION_LEFT : VC_POSITION_RIGHT];
        [self.delegate paginator:self didChangePage:direction presentedPage:self.vctrls[VC_POSITION_CENTER] reusePage:reusePage];
    }

    // Recenter all the VC's
    [self updateViewControllersFrameOrigin];
    [self centerScrollView];
}

#pragma mark - Container Size change handling
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // Resize the content according to the new container bounds.
    [self resizeContent];
}

#pragma mark - Public

- (void)scroll:(SCROLL_DIRECTION)direction {
    CGFloat contentOffsetX = direction == SCROLL_DIRECTION_BACKWARD ? VC_POSITION_LEFT : VC_POSITION_RIGHT*self.viewWidth;
    [self.contentScrollView setContentOffset:CGPointMake(contentOffsetX, 0) animated:YES];
}

- (void)disableScroll {
    self.contentScrollView.scrollEnabled = NO;
}

- (void)enableScroll {
    self.contentScrollView.scrollEnabled = YES;
}

- (void)setForwardScrollEnabled:(BOOL)forwardScrollEnabled {
    _forwardScrollEnabled = forwardScrollEnabled;
    self.forwardPage.view.hidden = !_forwardScrollEnabled;
}

- (void)setBackwardScrollEnabled:(BOOL)backwardScrollEnabled {
    _backwardScrollEnabled = backwardScrollEnabled;
    self.backwardPage.view.hidden = !_backwardScrollEnabled;
}

- (NSArray<UIViewController *> *)pages {
    return self.vctrls;
}

- (UIViewController *)presentedPage {
    return self.vctrls[VC_POSITION_CENTER];
}

- (UIViewController *)forwardPage {
    return self.vctrls[VC_POSITION_RIGHT];
}

- (UIViewController *)backwardPage {
    return self.vctrls[VC_POSITION_LEFT];
}

@end
