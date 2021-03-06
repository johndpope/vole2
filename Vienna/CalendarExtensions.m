//
//  CalendarExtensions.m
//  Vienna
//
//  Created by Steve on Sun Apr 11 2004.
//  Copyright (c) 2004 Steve Palmer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "CalendarExtensions.h"

@implementation NSCalendarDate (CalendarExtensions)

/* friendlyDescription
 * Return a calendar date format string in a friendly format as follows:
 *
 * If the date is today, we show "Today".
 * If the date was yesterday, we show "Yesterday".
 * If the date is tomorrow, we show "Tomorrow".
 * And in all cases, we show a short time format HH:MM am/pm
 *
 * Why not use the Cocoa date formatters for this? Simple. None of them return the
 * format we need. Sigh.
 */
-(NSString *)friendlyDescription
{
//	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString * theDate;
	
	// Note: NSUserDefaults provide built-in localized names for today, yesterday
	// and tomorrow. We don't use them because the initial letter isn't capitalized
	// and it's tough to make assumptions about how to capitalize a localized string.
	NSInteger todayNum = [[NSCalendarDate calendarDate] dayOfCommonEra];
	NSInteger myNum = [self dayOfCommonEra];
    
	if (myNum == todayNum)
	{
		theDate = NSLocalizedString(@"Today", nil);
	}
	else if (myNum == (todayNum - 1))
	{
		theDate = NSLocalizedString(@"Yesterday", nil);
	}
	else if (myNum == (todayNum + 1))
	{
		theDate = NSLocalizedString(@"Tomorrow", nil);
	}
	else
	{
#if 0
        // This is broken on Mavericks
		NSString * outputFormat = [defaults objectForKey:@"NSShortDateFormatString"];
#else
        NSString * outputFormat = @"%d/%m/%Y";
#endif
		theDate = [self descriptionWithCalendarFormat:outputFormat];
	}
	
	// If the time is 12.00 then replace with Noon or Midnight as appropriate.
	// (See http://www.coolquiz.com/trivia/explain/docs/time.asp for an explanation)
	NSString * theTime;
    
	if ([self hourOfDay] == 12 && [self minuteOfHour] == 0)
	{
		theTime = NSLocalizedString(@"Noon", nil);
	}
	else if ([self hourOfDay] == 0 && [self minuteOfHour] == 0)
	{
		theTime = NSLocalizedString(@"Midnight", nil);
	}
	else
	{
		// Use the user's preferred time format but strip off the seconds.
#if 0
        // This breaks on Mavericks - or does it?
		NSMutableString * outputFormat = [NSMutableString stringWithString:[defaults objectForKey:NSTimeFormatString]];
		[outputFormat replaceOccurrencesOfString:@":%S" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [outputFormat length])];
#else
// #warning FIXME get the user defaults for preferred time format (DJE)
        NSString * outputFormat = @"%H:%M";
#endif
		theTime = [self descriptionWithCalendarFormat:outputFormat];
    }
	return [NSString stringWithFormat:@"%@ at %@", theDate, theTime];
}
@end

