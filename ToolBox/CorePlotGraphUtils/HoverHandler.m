//
//  HoverHandler.m
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import "HoverHandler.h"

static const float kDefaultHoverPaddingBottom = 0.0f;
static const float kDefaultBorderLineWidth = 3.0f;
static const float kDefaultLayerCornerRadius = 5.0f;
static const float kLayerContentPaddingTop = 2.0f;
static const float kLayerContentPaddingBottom = 2.0f;
static const float kLayerContentPaddingLeft = 10.0f;
static const float kLayerContentPaddingRight = 10.0f;
static const float kLayerPaddingToMargin = 3.0f;
static const float kDefaultDotSize = 12.0f;
static const float kDefaultLineWidth = 2.0f;
static const float kLayerContentAnchorPointX = 0.5f;
static const float kLayerContentAnchorPointY = 1.0f;
static const float kPaddingMultiplier = -2.0f;
static const NSUInteger kNumberOfCoordinates = 2;
static const NSUInteger kXCoordinate = 0;
static const NSUInteger kYCoordinate = 1;

@interface HoverHandler()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) CPTPlotSpaceAnnotation *plotAnnotation;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *dotAnnotation;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *lineAnnotation;
@property (nonatomic, strong) CPTTextLayer *titleTextLayer;
@property (nonatomic, strong) NSDecimalNumber *plotAnnotationYAnchor;
@property (nonatomic, assign) NSUInteger numberOfRows;

@property (nonatomic, strong) CPTPlotAreaFrame *plotAreaFrame;

@property (nonatomic, strong) UILongPressGestureRecognizer *panGesture;

@property (nonatomic, assign) CGFloat textLayerAnchorDouble;
@property (nonatomic, strong) NSMutableArray *attribs;
@property (nonatomic, strong) NSMutableArray *strings;

@property (nonatomic, strong) NSNumber *lineTopOffset;
@property (nonatomic, assign) float borderLineWidth;
@end

@implementation HoverHandler

// --------------------------------------------------------------------------------
#pragma mark - init
// --------------------------------------------------------------------------------

-(instancetype)initWithContainerView:(UIView *)container graph:(CPTGraph *)graph{
    self = [super init];
    if(self){
        _panGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [container addGestureRecognizer:_panGesture];
        _containerView = container;
        _graph = graph;
        _plotAreaFrame = graph.plotAreaFrame;
    }
    return self;
}

// --------------------------------------------------------------------------------
#pragma mark - Annotations setup
// --------------------------------------------------------------------------------

- (CPTTextLayer *)titleTextLayer{
    if(nil == _titleTextLayer){
        self.borderLineWidth = kDefaultBorderLineWidth;
        CPTColor *lineColor = [CPTColor colorWithCGColor:[[UIColor greenColor] CGColor]];
        CGColorRef layerBackgroundColor = [UIColor darkGrayColor].CGColor;
        CGFloat layerCornerRadius = kDefaultLayerCornerRadius;;
        CGFloat maxLayerWidth = self.plotAreaFrame.frame.size.width;
        CGFloat maxLayerHeight = self.plotAreaFrame.frame.size.height;
        CGFloat contentPaddingTop = kLayerContentPaddingTop;
        CGFloat contentPaddingBottom = kLayerContentPaddingBottom;
        CGFloat contentPaddingLeft = kLayerContentPaddingLeft;
        CGFloat contentPaddingRight = kLayerContentPaddingRight;

        if([self.UIDelegate respondsToSelector:@selector(textLayerBorderLineWidth:)]){
            self.borderLineWidth = [self.UIDelegate textLayerBorderLineWidth:self];
        }

        if([self.UIDelegate respondsToSelector:@selector(textLayerBorderLineCollor:)]){
            lineColor = [CPTColor colorWithCGColor:[self.UIDelegate textLayerBorderLineCollor:self].CGColor];
        }

        if([self.UIDelegate respondsToSelector:@selector(textLayerBackgroundColor:)]){
            layerBackgroundColor = [self.UIDelegate textLayerBackgroundColor:self].CGColor;
        }


        if([self.UIDelegate respondsToSelector:@selector(textLayerCornerRadius:)]){
            layerCornerRadius = [self.UIDelegate textLayerCornerRadius:self];
        }

        if([self.UIDelegate respondsToSelector:@selector(textLayerContentPaddingTop:)]){
            contentPaddingTop = [self.UIDelegate textLayerContentPaddingTop:self];
        }

        if([self.UIDelegate respondsToSelector:@selector(textLayerContentPaddingBottom:)]){
            contentPaddingBottom = [self.UIDelegate textLayerContentPaddingBottom:self];
        }

        if([self.UIDelegate respondsToSelector:@selector(textLayerContentPaddingLeft:)]){
            contentPaddingLeft = [self.UIDelegate textLayerContentPaddingLeft:self];
        }

        if([self.UIDelegate respondsToSelector:@selector(textLayerContentPaddingRight:)]){
            contentPaddingRight = [self.UIDelegate textLayerContentPaddingRight:self];
        }

        if([self.dataDelegate respondsToSelector:@selector(numberOfRows:)]){
            self.numberOfRows = [self.dataDelegate numberOfRows:self];
        }

        _titleTextLayer = [[CPTTextLayer alloc] init];
        _titleTextLayer.paddingLeft = contentPaddingLeft;
        _titleTextLayer.paddingRight = contentPaddingRight;
        _titleTextLayer.paddingTop = contentPaddingTop;
        _titleTextLayer.paddingBottom = contentPaddingBottom;
        CPTMutableLineStyle *lineStyle = [[CPTMutableLineStyle alloc] init];
        lineStyle.lineWidth = self.borderLineWidth;
        lineStyle.lineColor = lineColor;
        _titleTextLayer.borderLineStyle = lineStyle;
        _titleTextLayer.maximumSize = CGSizeMake(maxLayerWidth,maxLayerHeight);
        _titleTextLayer.cornerRadius = layerCornerRadius;
        _titleTextLayer.masksToBounds = YES;
        _titleTextLayer.backgroundColor = layerBackgroundColor;
    }
    return _titleTextLayer;
}

- (CPTPlotSpaceAnnotation *)plotAnnotation{
    if (nil == _plotAnnotation) {
        _plotAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.graph.defaultPlotSpace anchorPlotPoint:nil];
        _plotAnnotation.contentLayer = self.titleTextLayer;
        self.plotAnnotation.contentAnchorPoint = CGPointMake(kLayerContentAnchorPointX, kLayerContentAnchorPointY);
    }
    return _plotAnnotation;
}

- (CPTPlotSpaceAnnotation *)dotAnnotation{
    if(nil == _dotAnnotation){
        _dotAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.graph.defaultPlotSpace anchorPlotPoint:nil];
        CGFloat dotSize = kDefaultDotSize;
        CGColorRef color = [UIColor greenColor].CGColor;

        if([self.UIDelegate respondsToSelector:@selector(dotSize:)]){
            dotSize = [self.UIDelegate dotSize:self];
        }

        if([self.UIDelegate respondsToSelector:@selector(dotColor:)]){
            color = [self.UIDelegate dotColor:self].CGColor;
        }

        CPTLayer *layer = [[CPTLayer alloc] initWithFrame:CGRectMake(0, 0, dotSize, dotSize)];
        layer.cornerRadius = dotSize/2;
        layer.masksToBounds = YES;
        layer.backgroundColor = color;
        _dotAnnotation.contentLayer = layer;
    }
    return _dotAnnotation;
}

- (CPTPlotSpaceAnnotation *)lineAnnotation{
    if(nil == _lineAnnotation){
        _lineAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.graph.defaultPlotSpace anchorPlotPoint:nil];
        CGFloat lineWidth = kDefaultLineWidth;
        CGColorRef lineColor = [UIColor greenColor].CGColor;

        if([self.UIDelegate respondsToSelector:@selector(lineColor:)]){
            lineColor = [self.UIDelegate lineColor:self].CGColor;
        }

        if([self.UIDelegate respondsToSelector:@selector(lineWidth:)]){
            lineWidth = [self.UIDelegate lineWidth:self];
        }

        CPTLayer *lineLayer = [[CPTLayer alloc] initWithFrame:CGRectMake(0,0,lineWidth,self.plotAreaFrame.plotArea.frame.size.height - self.lineTopOffset.floatValue)];
        lineLayer.backgroundColor = lineColor;
        _lineAnnotation.contentLayer = lineLayer;
    }
    return _lineAnnotation;
}

// --------------------------------------------------------------------------------
#pragma mark - Hover createion logic
// --------------------------------------------------------------------------------

- (NSDecimalNumber *)convertPointToLayer:(CGPoint)point{
    // Converts the point from screen coordinate system
    // to graph coordinate system.Returns only X coordinate.
    NSDecimal plotPoints[kNumberOfCoordinates];
    CGPoint plotAreaPoint = [self.graph convertPoint:point toLayer:self.plotAreaFrame.plotArea];
    [self.graph.defaultPlotSpace plotPoint:plotPoints numberOfCoordinates:kNumberOfCoordinates forPlotAreaViewPoint:plotAreaPoint];
    NSDecimalNumber *x = [NSDecimalNumber decimalNumberWithDecimal:plotPoints[kXCoordinate]];
    return x;
}

- (GenericGraphData *)getClosestValueToValue:(NSNumber *)value{
    if(value.floatValue > self.data.lastObject.xValue.floatValue || value.floatValue < self.data.firstObject.xValue.floatValue){
        return nil;
    }

    if(value.floatValue == self.data.firstObject.xValue.floatValue){
        return self.data.firstObject;
    }else if (value.floatValue == self.data.lastObject.xValue.floatValue){
        return self.data.lastObject;
    }

    NSUInteger low = 0;
    NSUInteger high = self.data.count - 1;
    while (low + 1 != high) {
        NSUInteger mid = (low + high)/2;
        if(self.data[mid].xValue.floatValue <= value.floatValue){
            low = mid;
        }else{
            high = mid;
        }
    }

    int overDiff = self.data[high].xValue.intValue - value.intValue;
    int underDiff = value.intValue - self.data[low].xValue.intValue;
    GenericGraphData *data = self.data[high];
    if(underDiff < overDiff){
        data = self.data[low];
    }

    return data;
}

- (NSArray *)setupLineAnnotationAnchor:(NSNumber *)xValue{
    CPTPlotRange *range = [(CPTXYPlotSpace *)self.graph.defaultPlotSpace yRange];

    NSDecimal plotPoints[kNumberOfCoordinates];
    CGPoint plotAreaPoint = [self.graph convertPoint:CGPointMake(0,0) toLayer:self.plotAreaFrame.plotArea];
    [self.graph.defaultPlotSpace plotPoint:plotPoints numberOfCoordinates:kNumberOfCoordinates forPlotAreaViewPoint:plotAreaPoint];
    NSDecimalNumber *off = [NSDecimalNumber decimalNumberWithDecimal:plotPoints[kYCoordinate]];
    float val = off.floatValue;

    plotAreaPoint = [self.graph convertPoint:CGPointMake(0,self.lineTopOffset.floatValue/2) toLayer:self.plotAreaFrame.plotArea];
    [self.graph.defaultPlotSpace plotPoint:plotPoints numberOfCoordinates:kNumberOfCoordinates forPlotAreaViewPoint:plotAreaPoint];
    off = [NSDecimalNumber decimalNumberWithDecimal:plotPoints[kYCoordinate]];

    float dif = off.floatValue - val;

    NSArray *anchorPointsLine = [NSArray arrayWithObjects:xValue,@(range.location.floatValue + range.length.floatValue/2 - dif), nil];
    return anchorPointsLine;
}

- (BOOL)attachAnnotation:(CGPoint)point{

    //get x plot coordintate
    NSDecimalNumber *x = [self convertPointToLayer:point];

    // Block the user in plot area frame
    CPTPlotRange *XRange =[(CPTXYPlotSpace *)self.graph.defaultPlotSpace xRange];
    if (x.intValue < XRange.location.intValue || x.intValue > (XRange.location.intValue + XRange.length.intValue)) {
        return false;
    }

    NSNumber *yValue = @(0);
    NSNumber *xValue = x;

    GenericGraphData *data = [self getClosestValueToValue:x];
    if(data && data.yValue != nil){
        yValue = data.yValue;
        xValue = data.xValue;
    }else{
        return false;
    }

    // anchor points for dot and line annotation
    // anchor point coord cannot be nil
    NSArray *anchorPointsO = [NSArray arrayWithObjects:xValue,yValue, nil];
    self.dotAnnotation.anchorPlotPoint = anchorPointsO;

    if([self.dataDelegate respondsToSelector:@selector(graphHoverHandler:attributedContentForXValue:yValue:)]){
        self.titleTextLayer.attributedText = [self.dataDelegate graphHoverHandler:self attributedContentForXValue:xValue yValue:yValue];
    }else{
        self.titleTextLayer.attributedText = [self buildTextLayerContentForIndex:xValue value:yValue];
    }

    // calculate min and max check points
    // if plotAnnotation is out of plotAreaFrame, anchor it to min or max x value
    CGFloat width = self.plotAnnotation.contentLayer.frame.size.width;
    CGPoint p = [self.graph.defaultPlotSpace plotAreaViewPointForPlotPoint:[NSArray arrayWithObjects:xValue,yValue,nil]];
    CGPoint checkMinPoint = CGPointMake(p.x - width/2 - self.graph.paddingLeft - kLayerPaddingToMargin, 0);
    CGPoint checkMaxPoint = CGPointMake(p.x + width + self.plotAreaFrame.paddingRight - kLayerPaddingToMargin, 0);

    NSArray *anchorPoints;
    // This method should be called once when hover target graph is changed.
    // Moved here because of issue:
    // When entering for first time the landscape the plotArea frame is CGRectZero
    [self calculatePlotAnnotationAnchorOffset];
    if(checkMinPoint.x < 0){
        float annotPaddingLeft = width/2 + self.plotAreaFrame.paddingLeft - 2*self.lineAnnotation.contentLayer.frame.size.width
        + self.graph.paddingLeft + kLayerPaddingToMargin;
        NSDecimalNumber *x = [self convertPointToLayer:CGPointMake(annotPaddingLeft, 0)];
        anchorPoints = [NSArray arrayWithObjects:x,self.plotAnnotationYAnchor, nil];
    }else if(checkMaxPoint.x > self.containerView.frame.size.width){
        float annotPaddingRight = self.containerView.frame.size.width - width/2
        - kLayerPaddingToMargin + self.lineAnnotation.contentLayer.frame.size.width;;
        NSDecimalNumber *x = [self convertPointToLayer:CGPointMake(annotPaddingRight, 0)];
        anchorPoints = [NSArray arrayWithObjects:x, self.plotAnnotationYAnchor, nil];
    }else{
        anchorPoints = [NSArray arrayWithObjects:xValue,self.plotAnnotationYAnchor, nil];
    }

    self.plotAnnotation.anchorPlotPoint = anchorPoints;

    self.lineAnnotation.anchorPlotPoint = [self setupLineAnnotationAnchor:xValue];
    return true;
}

- (NSMutableAttributedString *)buildTextLayerContentForIndex:(NSNumber *)xIndex value:(NSNumber *)yValue{
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:@"--"];
    NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n"];
    if([self.dataDelegate respondsToSelector:@selector(graphHoverHandler:contentForXValue:yValue:forRow:)] && self.numberOfRows > 0){
        content = [[NSMutableAttributedString alloc] init];
        for(NSUInteger index = 0; index < self.numberOfRows;index++){
            NSString *string = [self.dataDelegate graphHoverHandler:self contentForXValue:xIndex yValue:yValue forRow:index];
            NSDictionary *attributes;
            if([self.UIDelegate respondsToSelector:@selector(graphHoverHandler:attributesForRow:)]){
                attributes = [self.UIDelegate graphHoverHandler:self attributesForRow:index];
            }

            NSAttributedString *str = [[NSAttributedString alloc] initWithString:string attributes:attributes];
            if(content.length > 0){
                [content appendAttributedString:newLine];
            }
            [content appendAttributedString:str];
        }
    }



    return content;
}

- (void)calculatePlotAnnotationAnchorOffset{
    // calculate y anchor plot point for plotAnnotation
    // we need to add an offset to the length of y axis.
    NSDecimal plotPoints[kNumberOfCoordinates];
    float plotAreaHeight = self.plotAreaFrame.frame.size.height;

    CGFloat paddingBottom = kDefaultHoverPaddingBottom;
    if([self.UIDelegate respondsToSelector:@selector(textLayerPaddingBottom:)]){
        paddingBottom = [self.UIDelegate textLayerPaddingBottom:self];
    }

    self.textLayerAnchorDouble = plotAreaHeight + paddingBottom;
    CGPoint plotAreaPoint = [self.graph convertPoint:CGPointMake(0, self.textLayerAnchorDouble)
                                             toLayer:self.plotAreaFrame.plotArea];
    [self.graph.defaultPlotSpace plotPoint:plotPoints numberOfCoordinates:kNumberOfCoordinates forPlotAreaViewPoint:plotAreaPoint];

    NSDecimalNumber *heightPoint = [NSDecimalNumber decimalNumberWithDecimal:plotPoints[kYCoordinate]];

    self.plotAnnotationYAnchor = heightPoint;
}

- (NSNumber *)lineTopOffset{
    if(_lineTopOffset == nil){
        float offset = self.plotAnnotation.contentLayer.frame.size.height - self.borderLineWidth;
        if ([self.UIDelegate respondsToSelector:@selector(textLayerPaddingBottom:)]) {
            offset += kPaddingMultiplier * [self.UIDelegate textLayerPaddingBottom:self];
        }
        _lineTopOffset = [NSNumber numberWithFloat:offset/2];
    }
    return _lineTopOffset;
}

- (void)panGesture:(UILongPressGestureRecognizer*)sender {
    if ((sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateBegan) && (self.data.count > 0)) {
        CGPoint point = [sender locationInView:self.containerView];

        if(sender.state == UIGestureRecognizerStateBegan){
            if([self.actionDelegate respondsToSelector:@selector(willDisplayHover:hoverHandler:)]){
                [self.actionDelegate willDisplayHover:YES hoverHandler:self];
            }
        }

        if([self attachAnnotation:point]){
            [self.plotAreaFrame.plotArea addAnnotation:self.dotAnnotation];
            [self.plotAreaFrame.plotArea addAnnotation:self.plotAnnotation];
            [self.plotAreaFrame.plotArea addAnnotation:self.lineAnnotation];
        }
    }else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        if([self.plotAreaFrame.plotArea.annotations containsObject:self.dotAnnotation]){
            [self.graph.plotAreaFrame.plotArea removeAnnotation:self.dotAnnotation];
        }
        if([self.plotAreaFrame.plotArea.annotations containsObject:self.lineAnnotation]){
            [self.graph.plotAreaFrame.plotArea removeAnnotation:self.lineAnnotation];
        }
        if([self.plotAreaFrame.plotArea.annotations containsObject:self.plotAnnotation]){
            [self.graph.plotAreaFrame.plotArea removeAnnotation:self.plotAnnotation];
        }
    }
}

@end
