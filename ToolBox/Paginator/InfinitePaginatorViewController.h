//
//  InfinitePaginatorViewController.h
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import <UIKit/UIKit.h>
#import "PaginatorConstants.h"

@class InfinitePaginatorViewController;

@protocol PaginatorViewControllerDelegate <NSObject>
- (void)paginator:(nonnull InfinitePaginatorViewController *)paginator
    didChangePage:(SCROLL_DIRECTION)direction
    presentedPage:(nonnull UIViewController *)presentedPage
        reusePage:(nonnull UIViewController *)reusePage;
@end


/**
 *  Infinite paginator to paginate through view controllers.
 *
 *  The paginator will have always 3 view controllers(instantiated only once) that are created from the provided vc model
 *  and are used to imitate the infinite pagination.
 *  The main goal is to use the already created view controller to paginate forward or backward instead of creating new one.
 *
 *  How it works:
 *  1. The initial setup - there are 3 ordered UIViewController instances:
 *        LeftPosition--------CenterPosition---------RightPosition
 *            |                     |                      |
 *           VC1                   VC2                     VC3
 *
 *  2. Scroll to the right action is made(same logic is applied for scrolling to the left):
 *        LeftPosition--------CenterPosition---------RightPosition
 *            |                     |                      |
 *           VC2                   VC3                     VC1
 *
 *     2.1 - Instead of creating a new UIViewController to put at the RightPosition move the VC1 to the right position.
 *
 *  Even though the UIPageViewController can be used to implement the above logic, this custom class offers transparent and configurable
 *  pagination logic so it can be updated to boost the pagination performance.
 */
@interface InfinitePaginatorViewController : UIViewController

@property (nonatomic, readonly, nonnull)  NSArray<UIViewController *> *pages;
@property (nonatomic, readonly, nonnull)  UIViewController *presentedPage;
@property (nonatomic, readonly, nullable) UIViewController *forwardPage;
@property (nonatomic, readonly, nullable) UIViewController *backwardPage;

@property (nonatomic, assign) CGFloat rubberBandingResistanceFactor;
@property (nonatomic, assign) CGFloat rubberBandingOffset;

@property (nonatomic, assign)             BOOL forwardScrollEnabled;
@property (nonatomic, assign)             BOOL backwardScrollEnabled;
@property (nonatomic, weak, nullable)     id<PaginatorViewControllerDelegate> delegate;

/**
 *  @abstract   A paginator initializer.
 *
 *  @warning    The aVcClass parameter should be a subclass of UIViewController.
 *  @param      vcClass the class model used to create view controller instances.
 *  @param      startPos the position of the VC to be shown at startup.
 */
-(_Nonnull instancetype)initWithVCModel:(Class _Nonnull)vcClass;

/**
 *  @abstract   A paginator initializer.
 *
 *  @param      viewControllers the viewControllers to set.
 */
- (_Nonnull instancetype)initWithViewControllers:(NSMutableArray *)viewControllers;

// Force scroll in specified direction
- (void)scroll:(SCROLL_DIRECTION)direction;

// Disable/enable scroll in any direction
- (void)disableScroll;
- (void)enableScroll;
@end

