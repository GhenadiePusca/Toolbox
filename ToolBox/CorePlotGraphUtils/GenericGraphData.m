//
//  GenericGraphData.m
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import "GenericGraphData.h"

@implementation GenericGraphData

- (instancetype)initWithXValue:(NSNumber *)xValue yValue:(NSNumber *)yValue{
    if(self = [super init]){
        _xValue = xValue;
        _yValue = yValue;
        _userInfo = nil;
    }
    return self;
}

- (instancetype)initWithXValue:(NSNumber *)xValue yValue:(NSNumber *)yValue userInfo:(NSDictionary *)userInfo {
    if(self = [super init]){
        _xValue = xValue;
        _yValue = yValue;
        _userInfo = userInfo;
    }
    return self;
}

@end
