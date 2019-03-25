//
//  GenericGraphData.h
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import <Foundation/Foundation.h>

@interface GenericGraphData : NSObject
@property (nonatomic,readonly) NSNumber *xValue;
@property (nonatomic,readonly) NSNumber *yValue;
@property (nonatomic, strong, nullable) NSDictionary *userInfo;

/**
 *  @param xValue X coordinate value.
 *  @param yValue Y value coresponding to X coordinate
 *  @return self or nil.
 **/
- (instancetype)initWithXValue:(NSNumber *)xValue yValue:(NSNumber *)yValue;

/**
 *  @param xValue X coordinate value.
 *  @param yValue Y value coresponding to X coordinate
 *  @return self or nil.
 **/
- (instancetype)initWithXValue:(NSNumber *)xValue yValue:(NSNumber *)yValue userInfo:(NSDictionary *)userInfo;

@end
