//
//  DateSpan.h
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import <Foundation/Foundation.h>

@interface DateSpan : NSObject

@property (nonatomic, copy, readonly, nonnull) NSDate *startDate;
@property (nonatomic, copy, readonly, nonnull) NSDate *endDate;
@property (nonatomic, readonly, assign)        NSCalendarUnit unit;
@property (nonatomic, readonly, assign)        NSInteger numberOfUnits;
@property (nonatomic, copy, readonly, nonnull) NSCalendar *calendar;

// Note: unit = NSCalendarUnitDay units = 1 -> startDate = YY.MM.DD 00:00 - YY.MM.DD 23:59
//       unit = NSCalendarUnitDay units = 2 -> startDate = YY.MM.01 00:00 - YY.MM.02 00:00
//       unit = NSCalendarUnitMonth units = 1 -> startDate = YY.01.01 00:00 - YY.01.31 00:00
//       unit = NSCalendarUnitMonth units = 2 -> startDate = YY.01.01 00:00 - YY.02.01 00:00

// Current supported units - NSCalendarDay, NSCalendarWeek, NSCalendarMonth
- (nullable instancetype)initWithEndDate:(nonnull NSDate *)endDate
                                    unit:(NSCalendarUnit)unit
                           numberOfUnits:(NSInteger)numberOfUnits
                                calendar:(nullable NSCalendar *)calendar;

// Update the date span to the next interval with the self.unit and self.numberOfUnits
- (void)updateToNextDateSpan;
// Update the date span to the previous interval with the self.unit and self.numberOfUnits
- (void)updateToPreviousDateSpan;
// Creates and returns the next date span using current date span and the self.unit and self.numberOfUnits
- (nullable DateSpan *)nextDateSpan;
- (nullable DateSpan *)previousDateSpan;

- (nonnull NSString *)intervalDescription;
// If current period contains today
- (BOOL)isCurrentPeriod;
- (BOOL)isEqualToDateSpan:(nonnull DateSpan *)dateSpan;
// Min date is 01-01-2006 == [GCMUtil recordingsBeginDate]
- (BOOL)isMinDateSpan;
@end

