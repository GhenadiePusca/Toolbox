//
//  HoverHandler.h
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//  Copyright © 2019 Pusca, Ghenadie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericGraphData.h"
@import CorePlot;

@class HoverHandler;

@protocol HoverHandlerUIDelegate <NSObject>

@optional
/**
 *  @warning This method will be invoked only if contentForXValue method
 *           will be implemented and number of rows will be >0
 *  @param index The index of row.
 *  @return The attributes for string for specific row.
 **/
- (NSDictionary *)graphHoverHandler:(HoverHandler *)graphHover attributesForRow:(NSUInteger)index;

/** @warning Default value is swagger2 color;
 *  @param graphHover The graph hover.
 *  @return The color for straight vertical line.
 **/
- (UIColor *)lineColor:(HoverHandler *)graphHover;

/** @warning Default value is 2.0.
 *           The Line height is equal to graph plot area frame height.
 *  @param graphHover The graph hover.
 *  @return The width for straight vertical line.
 **/
- (CGFloat)lineWidth:(HoverHandler *)graphHover;

/** @warning Default value is swagger2 color;
 *  @param graphHover The graph hover.
 *  @return The color for dot annotation.
 **/
- (UIColor *)dotColor:(HoverHandler *)graphHover;

/** @warning Default value is 12.0
 *  @param graphHover The graph hover.
 *  @return The size for dot annotation.
 **/
- (CGFloat)dotSize:(HoverHandler *)graphHover;

/** @warning Default value is swagger2 color;
 *  @param graphHover The graph hover.
 *  @return The color for border line.
 **/
- (UIColor *)textLayerBorderLineCollor:(HoverHandler *)graphHover;

/** @warning Default value is 3.0
 *  @param graphHover The graph hover.
 *  @return The line width for border line.
 **/
- (CGFloat)textLayerBorderLineWidth:(HoverHandler *)graphHover;

/** @warning Default value is 5.0
 *  @param graphHover The graph hover.
 *  @return The color for border line.
 **/
- (CGFloat)textLayerCornerRadius:(HoverHandler *)graphHover;

/** @warning Default value is interface26 color, it shouldn't be clear color.
 *  @param graphHover The graph hover.
 *  @return The color for layer background color.
 **/
- (UIColor *)textLayerBackgroundColor:(HoverHandler *)graphHover;

/** @warning Default value is 15.0,it should be adjusted to correctly fit in the view.
 *  @param graphHover The graph hover.
 *  @return The bottom padding for layer from plot area, the result anchor point will be
 *          plot area height + padding.
 **/
- (CGFloat)textLayerPaddingBottom:(HoverHandler *)graphHover;

/** @warning Default value is 2.0.
 *  @param graphHover The graph hover.
 *  @return The top padding for the content in the Layer.
 **/
- (CGFloat)textLayerContentPaddingTop:(HoverHandler *)graphHover;

/** @warning Default value is 2.0.
 *  @param graphHover The graph hover.
 *  @return The bottom padding for the content in the Layer.
 **/
- (CGFloat)textLayerContentPaddingBottom:(HoverHandler *)graphHover;

/** @warning Default value is 10.0.
 *  @param graphHover The graph hover.
 *  @return The left padding for the content in the Layer.
 **/
- (CGFloat)textLayerContentPaddingLeft:(HoverHandler *)graphHover;

/** @warning Default value is 10.0.
 *  @param graphHover The graph hover.
 *  @return The right padding for the content in the Layer.
 **/
- (CGFloat)textLayerContentPaddingRight:(HoverHandler *)graphHover;
@end

/*
 * @brief Graph Hover delegate.
 */
@protocol HoverHandlerDataDelegate <NSObject>
@optional

// Warning: You have to implemented attributedContentForXValue or
//          contentForXValue(for this you should also implement numberOfRows)
//

/**
 *  @param graphHover The graph hover.
 *  @param xValue X value in graph coordinate system.
 *  @param yValue Is the Y value from datasource coresponding to xValue.
 *  @return The attributed content for xValue
 **/
- (NSAttributedString *)graphHoverHandler:(HoverHandler *)graphHoverHandler
               attributedContentForXValue:(NSNumber *)xValue yValue:(NSNumber *)yValue;

/**
 *  @param graphHover The graph hover.
 *  @param xValue X value in graph coordinate system.
 *  @param yValue Is the Y value from datasource coresponding to xValue.
 *  @param forRow The string for specific row
 *  @return The content for specific row
 **/
- (NSString*)graphHoverHandler:(HoverHandler *)graphHoverHandler
              contentForXValue:(NSNumber *)xValue yValue:(NSNumber *)yValue forRow:(NSUInteger)index;

/**
 *  @param graphHover The graph hover.
 *  @return The number of rows for hover content
 **/
- (NSInteger)numberOfRows:(HoverHandler *)graphHoverHandler;
@end

@protocol HoverHandlerActionDelegate <NSObject>
@optional
/**
 *  @param graphHover The graph hover.
 *  @param display    Notifiy the delegate that hover handler will display hover
 *  @return The number of rows for hover content
 **/
- (void)willDisplayHover:(BOOL)display hoverHandler:(HoverHandler *)graphHoverHandler;
@end

@interface HoverHandler : NSObject
@property (nonatomic,weak) id<HoverHandlerUIDelegate> UIDelegate;
@property (nonatomic,weak) id<HoverHandlerDataDelegate> dataDelegate;
@property (nonatomic,weak) id<HoverHandlerActionDelegate> actionDelegate;
@property (nonatomic,weak) CPTGraph *graph;
@property (nonatomic,weak) NSArray<GenericGraphData*> *data;
@property (nonatomic,weak) UIView *containerView;

/**
 *  @param container The view that contains the graph.
 *  @warning        For now the the container should be superview!
 *  @param graph    The target graph for hover
 *  @param data     The datasource for hover; you have to convert the graph datasource
 *                  to NSArray<GCMGraphData> model.
 *  @return nil or self.
 **/
-(instancetype)initWithContainerView:(UIView *)container graph:(CPTGraph *)graph;
@end
