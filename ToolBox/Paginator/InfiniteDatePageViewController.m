//
//  InfiniteDatePageViewController.m
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import "InfiniteDatePageViewController.h"
#import "PageContentViewController.h"

#import <Masonry/Masonry.h>

const NSString *kPageContentKey = @"pageContentKey";
const NSString *kDateSpanKey    = @"dateSpanKey";

@interface InfiniteDatePageViewController () <DatePageHeaderDelegate>
@property (nonatomic, strong) NSTimer *scrollDoneTimer;
@end

@implementation InfiniteDatePageViewController

- (instancetype)initWithDateSpan:(nonnull DateSpan *)dateSpan
                  contentVCModel:(Class)vcModel
                      headerView:(nullable DatePageHeader *)header {
    if(self = [super init]) {
        NSAssert([[vcModel class] isSubclassOfClass:[PageContentViewController class]], @"Passed vc model should be subclass of GCMPageContentViewController");
        _currentDateSpan = dateSpan;
        _loadDataDelay = kDatePageVCFastScrollDelay;
        _paginator = [[InfinitePaginatorViewController alloc] initWithVCModel:vcModel];
        _headerView = header;
        _headerView.delegate = self;
        [(PageContentViewController *)self.paginator.presentedPage setDateSpan:[_currentDateSpan copy]];
        [(PageContentViewController *)self.paginator.forwardPage setDateSpan:[_currentDateSpan nextDateSpan]];
        [(PageContentViewController *)self.paginator.backwardPage setDateSpan:[_currentDateSpan previousDateSpan]];
        _paginator.forwardScrollEnabled = ![_currentDateSpan isCurrentPeriod];
        _paginator.delegate = self;
    }

    return self;
}

#pragma mark - VC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];

    [self addChildViewController:self.paginator];
    [self.view addSubview:self.paginator.view];
    self.paginator.view.frame = self.view.bounds;
    [self.paginator didMoveToParentViewController:self];
    [self layoutComponents];
    [(PageContentViewController *)self.paginator.presentedPage pageDidAppear:[self.currentDateSpan copy]];
}

- (void)dealloc {
    [self.scrollDoneTimer invalidate];
}

- (void)layoutComponents {
    if(self.headerView) {
        [self.headerView updateWith:[self.currentDateSpan copy]];
        [self.view addSubview:self.headerView];
        [self.headerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.paginator.view.mas_top);
        }];
    }

    [self.paginator.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        if(!self.headerView) {
            make.top.equalTo(self.view);
        }
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)setHeaderView:(DatePageHeader * _Nullable)headerView {
    [_headerView removeFromSuperview];
    _headerView = headerView;
    [self layoutComponents];
}

#pragma mark - Paginator delegate methods

- (void)paginator:(InfinitePaginatorViewController *)paginator didChangePage:(SCROLL_DIRECTION)direction presentedPage:(UIViewController *)presentedPage reusePage:(UIViewController *)reusePage {

    [self.scrollDoneTimer invalidate];

    DateSpan *nextInterval;
    if(direction == SCROLL_DIRECTION_FORWARD) {
        [self.currentDateSpan updateToNextDateSpan];
        nextInterval = [self.currentDateSpan nextDateSpan];
    } else {
        [self.currentDateSpan updateToPreviousDateSpan];
        nextInterval = [self.currentDateSpan previousDateSpan];
    }

    [self.headerView updateWith:[self.currentDateSpan copy]];

    self.paginator.forwardScrollEnabled = ![self.currentDateSpan isCurrentPeriod];
    self.paginator.backwardScrollEnabled = ![self.currentDateSpan isMinDateSpan];

    [(PageContentViewController *)reusePage prepareForReuse: nextInterval];

    self.scrollDoneTimer = [NSTimer scheduledTimerWithTimeInterval:self.loadDataDelay target:self selector:@selector(scrollDone:)
                                                          userInfo:@{kPageContentKey : (PageContentViewController *)presentedPage,
                                                                     kDateSpanKey : [self.currentDateSpan copy]}
                                                           repeats:NO];
}

- (void)scrollDone:(NSTimer *)timer {
    if([timer.userInfo isKindOfClass:[NSDictionary class]]) {
        NSDictionary *data = timer.userInfo;
        if([data[kPageContentKey] isKindOfClass:[PageContentViewController class]] && [data[kDateSpanKey] isKindOfClass:[DateSpan class]]) {
            PageContentViewController *presentedPage = data[kPageContentKey];
            DateSpan *currentDateSpan = data[kDateSpanKey];

            [presentedPage pageDidAppear:currentDateSpan];
            return;
        }
    }

    // If timer.userInfo is wrong format, try to show a page, even though it might not be accurate
    [(PageContentViewController *)self.paginator.presentedPage pageDidAppear:self.currentDateSpan];
}

#pragma mark - Actions
- (void)didTapForwardButton {
    [self.paginator scroll:SCROLL_DIRECTION_FORWARD];
}

- (void)didTapBackwardButton {
    [self.paginator scroll:SCROLL_DIRECTION_BACKWARD];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end

