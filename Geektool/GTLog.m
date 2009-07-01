//
//  GTLog.m
//  GeekTool
//
//  Created by Yann Bizeul on Sun Jan 26 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GTLog.h"
#import "LogController.h"
#import "NTLogProcess.h"
#import "NSDictionary+IntAndBoolAccessors.h"
#import "defines.h"

// GTLog is a class that is responsible for storing and handling all information pertaining to the log displayed on the screen. It sets up and interacts with other objects such as NSViews to display, update, and manage its graphical representation
@implementation GTLog

@synthesize logProcess;
@synthesize properties;
@synthesize active;

- (id)initWithProperties:(NSDictionary*)newProperties
{
	if (!(self = [super init])) return nil;
    
    [self setProperties:[NSMutableDictionary dictionaryWithDictionary:newProperties]];
    
    logProcess = nil;
    [self setupObservers];
    return self;
}

- (id)init
{    
    NSData *textColorData = [NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
    NSData *backgroundColorData = [NSArchiver archivedDataWithRootObject:[NSColor clearColor]]; 
    
    NSMutableDictionary *defaultProperties = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                              @"New log",@"name",
                                              [NSNumber numberWithInt:TYPE_SHELL],@"type",
                                              [NSNumber numberWithBool:YES],@"enabled",
                                              @"Default",@"group",
                                              
                                              @"Monaco",@"fontName",
                                              [NSNumber numberWithInt:12],@"fontSize",
                                              
                                              @"",@"file",
                                              @"",@"quartzFile",
                                              
                                              @"",@"command",
                                              [NSNumber numberWithInt:10],@"refresh",
                                              
                                              textColorData,@"textColor",
                                              backgroundColorData,@"backgroundColor",
                                              [NSNumber numberWithBool:NO],@"wrap",
                                              [NSNumber numberWithBool:NO],@"shadowText",
                                              [NSNumber numberWithBool:NO],@"shadowWindow",
                                              [NSNumber numberWithBool:NO],@"alignment",
                                                                                          
                                              [NSNumber numberWithInt:TOP_LEFT],@"pictureAlignment",
                                              @"",@"imageURL",
                                              [NSNumber numberWithInt:100],@"transparency",
                                              [NSNumber numberWithInt:PROPORTIONALLY],@"imageFit",
                                              
                                              [NSNumber numberWithInt:0],@"x",
                                              [NSNumber numberWithInt:20],@"y",
                                              [NSNumber numberWithInt:150],@"w",
                                              [NSNumber numberWithInt:150],@"h",
                                              
                                              [NSNumber numberWithBool:NO],@"alwaysOnTop",
                                              nil];
    
    return [self initWithProperties:defaultProperties];
}

- (void)dealloc
{
    // NSTimer screws with the retain count
    [logProcess dealloc];
    [properties release];
    [self removeObservers];
    [super dealloc];
}

#pragma mark -
#pragma mark Observing
- (void)setupObservers
{
    [self addObserver:self forKeyPath:@"active" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    
    [self addObserver:self forKeyPath:@"properties.name" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.type" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.enabled" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.group" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.fontName" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.fontSize" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.file" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.quartzFile" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.command" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.refresh" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.textColor" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.backgroundColor" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.wrap" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.shadowText" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.shadowWindow" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.alignment" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.pictureAlignment" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.imageURL" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.transparency" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.imageFit" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.x" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.y" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.w" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.h" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"properties.alwaysOnTop" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

- (void)removeObservers
{
    [self removeObserver:self forKeyPath:@"active"];
    
    [self removeObserver:self forKeyPath:@"properties.name"];
    [self removeObserver:self forKeyPath:@"properties.type"];
    [self removeObserver:self forKeyPath:@"properties.enabled"];
    [self removeObserver:self forKeyPath:@"properties.group"];
    [self removeObserver:self forKeyPath:@"properties.fontName"];
    [self removeObserver:self forKeyPath:@"properties.fontSize"];
    [self removeObserver:self forKeyPath:@"properties.file"];
    [self removeObserver:self forKeyPath:@"properties.quartzFile"];
    [self removeObserver:self forKeyPath:@"properties.command"];
    [self removeObserver:self forKeyPath:@"properties.refresh"];
    [self removeObserver:self forKeyPath:@"properties.textColor"];
    [self removeObserver:self forKeyPath:@"properties.backgroundColor"];
    [self removeObserver:self forKeyPath:@"properties.wrap"];
    [self removeObserver:self forKeyPath:@"properties.shadowText"];
    [self removeObserver:self forKeyPath:@"properties.shadowWindow"];
    [self removeObserver:self forKeyPath:@"properties.alignment"];
    [self removeObserver:self forKeyPath:@"properties.pictureAlignment"];
    [self removeObserver:self forKeyPath:@"properties.imageURL"];
    [self removeObserver:self forKeyPath:@"properties.transparency"];
    [self removeObserver:self forKeyPath:@"properties.imageFit"];
    [self removeObserver:self forKeyPath:@"properties.x"];
    [self removeObserver:self forKeyPath:@"properties.y"];
    [self removeObserver:self forKeyPath:@"properties.w"];
    [self removeObserver:self forKeyPath:@"properties.h"];
    [self removeObserver:self forKeyPath:@"properties.alwaysOnTop"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // open/close windows if at all possible
    if ([keyPath isEqualToString:@"properties.enabled"] || [keyPath isEqualToString:@"active"])
    {
        if (logProcess) [logProcess dealloc]; // see this classes dealloc for more info
        if (![[self active]boolValue] || ![properties boolForKey:@"enabled"]) return;
        
        self.logProcess = [[NTLogProcess alloc]initWithParentLog:self];
        [logProcess setupLogWindowAndDisplay];
    }
    else if ([keyPath isEqualToString:@"properties.shadowWindow"] || [keyPath isEqualToString:@"properties.file"] || [keyPath isEqualToString:@"properties.command"] || [keyPath isEqualToString:@"properties.type"])
    {
        [logProcess setupLogWindowAndDisplay];
    }
    else
    {
        [logProcess setTimerNeedsUpdate:NO];
        [logProcess updateWindow];
    }
}

#pragma mark -
#pragma mark KVC

- (void)setIsBeingDragged:(BOOL)var
{
    isBeingDragged = var;
    if (isBeingDragged)
    {
        [self removeObserver:self forKeyPath:@"properties.x"];
        [self removeObserver:self forKeyPath:@"properties.y"];
        [self removeObserver:self forKeyPath:@"properties.w"];
        [self removeObserver:self forKeyPath:@"properties.h"];
    }
    else 
    {
        [self addObserver:self forKeyPath:@"properties.x" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
        [self addObserver:self forKeyPath:@"properties.y" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
        [self addObserver:self forKeyPath:@"properties.w" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
        [self addObserver:self forKeyPath:@"properties.h" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];        
    }
}

- (BOOL)isBeingDragged
{
    return isBeingDragged;
}

#pragma mark -
#pragma mark Convience Methods
- (void)setCoords:(NSRect)newCoords
{
    [[self properties]setValue:[NSNumber numberWithInt:newCoords.origin.x] forKey:@"x"];
    [[self properties]setValue:[NSNumber numberWithInt:newCoords.origin.y] forKey:@"y"];
    [[self properties]setValue:[NSNumber numberWithInt:newCoords.size.width] forKey:@"w"];
    [[self properties]setValue:[NSNumber numberWithInt:newCoords.size.height] forKey:@"h"];
}

#pragma mark -
#pragma mark Misc
- (BOOL)equals:(GTLog*)comp
{
    if ([[self properties] isEqualTo: [comp properties]]) return YES;
    else return NO;
}

- (NSString*)description
{
    return [NSString stringWithFormat: @"Log:%@\nEnabled:%@",[[self properties]objectForKey:@"name"],[[self properties]objectForKey:@"enabled"]];
}

#pragma mark -
#pragma mark Copying
- (id)copyWithZone:(NSZone *)zone
{
    id result = [[[self class] allocWithZone:zone] init];
    
    [result setProperties:[self properties]];
    
    return result;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone: zone];
}

#pragma mark Coding
- (id)initWithCoder:(NSCoder *)coder
{
    return [self initWithProperties:[coder decodeObjectForKey:@"properties"]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:properties forKey:@"properties"];
}

@end