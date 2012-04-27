//
//  SortedSet.m
//  SortedSet
//
//  Created by Matt Gallagher on 19/12/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "SortedSet.h"

NSString *DescriptionForObject(NSObject *object, id locale, NSUInteger indent);

NSString *DescriptionForObject(NSObject *object, id locale, NSUInteger indent)
{
	NSString *objectString;
	if ([object isKindOfClass:[NSString class]])
	{
		objectString = (NSString *)[[object retain] autorelease];
	}
	else if ([object respondsToSelector:@selector(descriptionWithLocale:indent:)])
	{
		objectString = [(NSDictionary *)object descriptionWithLocale:locale indent:indent];
	}
	else if ([object respondsToSelector:@selector(descriptionWithLocale:)])
	{
		objectString = [(NSSet *)object descriptionWithLocale:locale];
	}
	else
	{
		objectString = [object description];
	}
	return objectString;
}

@implementation SortedSet

- (BOOL)containsObject:(id)anObject
{
    return [_set containsObject:anObject];
}

- (void)addObject:(id)anObject withComparator:(NSComparator)compareBlock
{
    [_set  addObject:anObject];
	[_array addObject:anObject];
    if (compareBlock) {
        [_array sortUsingComparator:compareBlock];
    }    
}

- (void)addObject:(id)anObject
{
    [_set  addObject:anObject];
	[_array addObject:anObject];
}

- (void)removeObject:(id)anObject
{
    [_set  removeObject:anObject];
	[_array removeObject:anObject];
}

- (id)init
{
	return [self initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)capacity
{
	self = [super init];
    if (self != nil)
	{
		_set = [[NSMutableSet alloc] initWithCapacity:capacity];
		_array = [[NSMutableArray alloc] initWithCapacity:capacity];
	}
	return self;
}

- (void)dealloc
{
	[_set release];
	[_array release];
	[super dealloc];
}

- (id)copy
{
	return [self mutableCopy];
}

- (NSUInteger)count
{
	return [_set count];
}

- (NSEnumerator *)keyEnumerator
{
	return [_array objectEnumerator];
}

- (NSEnumerator *)reverseKeyEnumerator
{
	return [_array reverseObjectEnumerator];
}

- (id)keyAtIndex:(NSUInteger)anIndex
{
	return [_array objectAtIndex:anIndex];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
	NSMutableString *indentString = [NSMutableString string];
	NSUInteger i, count = level;
	for (i = 0; i < count; i++)
	{
		[indentString appendFormat:@"    "];
	}
	
	NSMutableString *description = [NSMutableString string];
	[description appendFormat:@"%@{\n", indentString];
	for (NSObject *key in self)
	{
		[description appendFormat:@"%@    %@;\n",
			indentString,
			DescriptionForObject(key, locale, level)];
	}
	[description appendFormat:@"%@}\n", indentString];
	return description;
}

@end
