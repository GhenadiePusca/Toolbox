//
//  PageContentViewController.h
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import <UIKit/UIKit.h>
#import "DateSpan.h"

typedef NS_ENUM(NSInteger, PageContentState) {
    PageContentStatePendingLoad = 0,
    PageContentStateLoaded,
};

// Used to emulate protected access level.
@protocol PageContentInterface <NSObject>
@property (nonatomic, assign) PageContentState state;
@property (nonatomic, assign) BOOL shouldFetchData;
- (void)updateCache;
- (void)updateContent;
// The methods below don't have the default behavior, you should override each method.
- (void)clearContent;
- (void)fetchData;
- (nullable id)objectToBeCached;
- (void)populateWithCacheObject:(nonnull id)cacheObject;
@end

// The base class used as content for the InfiniteDatePageVC
@interface PageContentViewController : UIViewController<PageContentInterface>
@property (nonatomic, strong, nonnull) DateSpan *dateSpan;
@property (nonatomic, assign) NSInteger maxCacheSize;

// The InfiniteDatePageVC will interact with the pageContent trough the next public methods.

// Notify the page that it is about to be reused.
- (void)prepareForReuse:(nonnull DateSpan *)dateSpan;
// Notify the page that it is the current presented page
- (void)pageDidAppear:(nonnull DateSpan *)dateSpan;
- (void)updateForOrientation:(UIInterfaceOrientation)orientation;
- (nonnull instancetype)init;
@end
