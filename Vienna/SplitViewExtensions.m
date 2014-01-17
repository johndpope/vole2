//
//  SplitViewExtensions.m
//  Vienna
//
//  Created by Steve on 6/15/05.
//  Copyright (c) 2004-2005 Steve Palmer. All rights reserved.
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

#import "SplitViewExtensions.h"

/* Code borrowed from http://www.cocoadev.com/index.pl?SavingNSSplitViewPosition
 * but I don't see any author associated so I'm unable to credit. Feel free to
 * edit and accredit as appropriate.
 */

@implementation NSSplitView (SplitViewExtensions)

/* storeLayoutWithName
 * Saves the layout of the subviews to the user preferences under the specified
 * key name.
 */
-(void)storeLayoutWithName:(NSString *)key
{
	NSMutableArray * viewRects = [NSMutableArray array];
	NSEnumerator * viewEnum = [[self subviews] objectEnumerator];
	NSView * view;
	NSRect frame;

	while ((view = [viewEnum nextObject]) != nil)
	{
		if ([self isSubviewCollapsed:view])
			frame = NSZeroRect;
		else
			frame = [view frame];
		[viewRects addObject:NSStringFromRect(frame)];
	}
	[[NSUserDefaults standardUserDefaults] setObject:viewRects forKey:key];
}

/* loadLayoutWithName
 * Retrieves the layout of subviews for a split view from the user preferences
 * under the specified key name, then applies those layouts to the current view.
 */
-(void)loadLayoutWithName:(NSString *)key
{
	NSMutableArray * viewRects = [[NSUserDefaults standardUserDefaults] objectForKey: key];
	NSArray * views = [self subviews];
	NSInteger i, count;
	NSRect frame;

	count = MIN([viewRects count], [views count]);
	for (i = 0; i < count; i++)
	{
		frame = NSRectFromString([viewRects objectAtIndex: i]);
		if (NSIsEmptyRect(frame))
		{
			frame = [[views objectAtIndex:i] frame];
			if( [self isVertical] )
				frame.size.width = 0;
			else
				frame.size.height = 0;
		}
		[[views objectAtIndex:i] setFrame:frame];
	}
}
@end
