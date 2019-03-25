//
//  DataSpan.m
//  ToolBox
//
//  Created by Pusca, Ghenadie on 25/03/2019.
//

#import "DateSpan.h"

@interface DateSpan() <NSCopying>

@end
@implementation DateSpan

- (nullable instancetype)initWithEndDate:(NSDate *)endDate
                                    unit:(NSCalendarUnit)unit
                           numberOfUnits:(NSInteger)numberOfUnits
                                calendar:(nullable NSCalendar *)calendar {
    if(self = [super init]) {
        _endDate = endDate;
        _unit = unit;
        _numberOfUnits = numberOfUnits;
        _calendar = calendar ? : [NSCalendar currentCalendar];
        [self adjustDates];
        return self;
    }
    return nil;
}

- (void)adjustDates {
    switch (self.unit) {
        case NSCalendarUnitDay:
            if (self.numberOfUnits == 1) {
                _startDate = [self.calendar startOfDayForDate:self.endDate];
                _endDate = [self endOfDay:self.endDate];
            } else {
                NSInteger adjustedNumberOfUnits = self.numberOfUnits;
                if (self.numberOfUnits > 0) {
                    adjustedNumberOfUnits -= 1;
                }
                _startDate = [self.calendar dateByAddingUnit:self.unit value:adjustedNumberOfUnits toDate:self.endDate options:0];
                _startDate = [self.calendar startOfDayForDate:self.startDate];
                _endDate = [self.calendar startOfDayForDate:self.endDate];
                _numberOfUnits = labs(_numberOfUnits - 1);
            }
            break;
        case NSCalendarUnitWeekOfYear:
            if(self.numberOfUnits == 1) {
                _startDate = [self startOfWeek:self.endDate];
                _endDate = [self endOfWeek:self.endDate];
            } else {
                _startDate = [self.calendar dateByAddingUnit:NSCalendarUnitWeekOfYear value:self.numberOfUnits - 1 toDate:[self startOfWeek:self.endDate] options:0];
                _endDate = [self startOfWeek:self.endDate];
            }
            break;

        case NSCalendarUnitMonth:
            if(self.numberOfUnits == 1) {
                _startDate = [self startOfMonth:self.endDate];
                _endDate = [self endOfMonth:self.endDate];
            } else {
                _startDate = [self.calendar dateByAddingUnit:self.unit value:self.numberOfUnits - 1 toDate:[self startOfMonth:self.endDate] options:0];
                _endDate = [self startOfMonth:self.endDate];
            }
            break;
        default:
            assert(@"Unsupported unit");
            break;
    }
}

#pragma mark - update
- (void)updateToNextDateSpan {
    _endDate = [self.calendar dateByAddingUnit:self.unit value:self.numberOfUnits toDate:self.endDate options:0];
    _startDate = [self.calendar dateByAddingUnit:self.unit value:self.numberOfUnits toDate:self.startDate options:0];
}

- (void)updateToPreviousDateSpan {
    _endDate = [self.calendar dateByAddingUnit:self.unit value:-self.numberOfUnits toDate:self.endDate options:0];
    _startDate = [self.calendar dateByAddingUnit:self.unit value:-self.numberOfUnits toDate:self.startDate options:0];
}

- (DateSpan *)nextDateSpan {
    DateSpan *span = [self copy];
    span->_startDate = [self.calendar dateByAddingUnit:self.unit value:self.numberOfUnits toDate:self.startDate options:0];
    span->_endDate = [self.calendar dateByAddingUnit:self.unit value:self.numberOfUnits toDate:self.endDate options:0];
    return span;
}

- (DateSpan *)previousDateSpan {
    DateSpan *span = [self copy];
    span->_startDate = [self.calendar dateByAddingUnit:self.unit value:-self.numberOfUnits toDate:self.startDate options:0];
    span->_endDate = [self.calendar dateByAddingUnit:self.unit value:-self.numberOfUnits toDate:self.endDate options:0];
    return span;
}

#pragma mark - utils
- (NSDate *)startOfMonth:(NSDate *)date {
    NSDate *startOfMonth;
    [self.calendar rangeOfUnit:NSCalendarUnitMonth startDate:&startOfMonth interval:nil forDate:self.endDate];
    return startOfMonth;
}

- (NSDate *)endOfMonth:(NSDate *)date {
    NSDate *startOfMonth;
    NSTimeInterval interval;
    [self.calendar rangeOfUnit:NSCalendarUnitMonth startDate:&startOfMonth interval:&interval forDate:self.endDate];
    return [self.calendar startOfDayForDate:[startOfMonth dateByAddingTimeInterval:interval-1]];;
}


- (NSDate *)startOfWeek:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                               fromDate:date];

    NSUInteger currentWeekDay = [components weekday];
    [components setDay:[components day] - ((currentWeekDay + 7) % 7)];

    NSDate *beginningOfWeek = [calendar dateFromComponents:components];
    return beginningOfWeek;
}

- (NSDate *)endOfWeek:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                               fromDate:date];

    NSInteger currentWeekDay = [components weekday];

    [components setDay:[components day]];

    NSDate *endOfWeekDate = [calendar dateFromComponents:components];

    return endOfWeekDate;
}

- (NSDate *)endOfDay:(NSDate *)date {
    NSDate *aDate = [self.calendar startOfDayForDate:date];
    aDate = [self.calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:aDate options:0];
    aDate = [self.calendar dateByAddingUnit:NSCalendarUnitSecond value:-1 toDate:aDate options:0];
    return aDate;
}

#pragma mark - Copy
- (id)copyWithZone:(NSZone *)zone {
    DateSpan *aCopy = [[[self class] allocWithZone:zone] init];

    if(aCopy) {
        aCopy->_startDate = self.startDate;
        aCopy->_endDate = self.endDate;
        aCopy->_unit = self.unit;
        aCopy->_calendar = self.calendar;
        aCopy->_numberOfUnits = self.numberOfUnits;
    }

    return aCopy;
}

- (NSDate *)beginningOfDay:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                               fromDate:date];
    return [calendar dateFromComponents:components];
}

#pragma mark - Public methods
- (NSString *)intervalDescription {
    return [NSString stringWithFormat:@"%@-%@", self.startDate, self.endDate];
}

- (BOOL)isCurrentPeriod {
    NSDate *beginningOfDay = [self beginningOfDay:[NSDate date]];
    NSComparisonResult earlierCompare = [beginningOfDay compare:self.startDate];
    NSComparisonResult laterCompare = [beginningOfDay compare:self.endDate];
    BOOL result = ((earlierCompare == NSOrderedSame || earlierCompare == NSOrderedDescending) &&
                   (laterCompare   == NSOrderedSame || laterCompare   == NSOrderedAscending));
    return result;
}

- (BOOL)isMinDateSpan {
    // TODO: add min date
    NSComparisonResult result = [self.startDate compare:[NSDate dateWithTimeIntervalSinceNow:-3600*24*365*10]];
    return result == NSOrderedSame || result == NSOrderedAscending;
}

- (BOOL)isEqualToDateSpan:(DateSpan *)dateSpan {
    return [self.startDate isEqualToDate:dateSpan.startDate] && [self.endDate isEqualToDate:dateSpan.endDate];
}
@end

