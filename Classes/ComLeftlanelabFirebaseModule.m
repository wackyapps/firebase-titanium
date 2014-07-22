/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComLeftlanelabFirebaseModule.h"
#import "TiHost.h"
#import "TiBase.h"
#import "TiUtils.h"

@implementation ComLeftlanelabFirebaseModule

@synthesize url;
@synthesize gInstances;
@synthesize gEventTypes;
@synthesize gListeners;

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"45ea9836-0715-4f0c-a308-b6f0997431a9";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.leftlanelab.firebase";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

    // Initialize [gEventTypes]
    self.gEventTypes = @[@"child_added", @"child_removed", @"child_changed", @"child_moved", @"value"];

    // Initialize [gInstances]
    self.gInstances = [NSMutableDictionary dictionary];

    // Initialize [gListeners]
    self.gListeners = [NSMutableDictionary dictionary];

    // Enable Automatic Local Persistence
    [Firebase setOption:@"persistence" to:@YES];
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	NSLog(@"[INFO] %@ Shutdown", self);
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	NSLog(@"[INFO] %@ Deallocating", self);
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
	NSLog(@"[INFO] %@ Memory Warning!!!", self);
}

#pragma mark Listener Notifications

/*
-(void)_listenerAdded:(NSString *)type count:(int)count
{
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
}
*/

#pragma Public APIs

/**
 * Generate (push) new [child] w/AutoID
 *
 *	- args[0] - (NSString) the URL for Firebase Reference
 *
 *	Returns: (NSString) new [child].[name] as the ID
 */
- (NSString*)childByAutoId: (id)args
{
    if (! [args count] || ! [args[0] isKindOfClass:[NSString class]]) {return NO;}

	// Set the new [child] and return the [name] as the ID
	return [[[Firebase alloc] initWithUrl:args[0]] childByAutoId].name;
}

/**
 * Set [instance]
 *
 *	- args[0] - (NSString) the URL for Firebase Reference
 *	- args[1] - (id) values to be updated
 *  - args[2] - (KrollCallback) callback
 *  - args[3] - (id) context for callback(s)
 *
 */
- (void)set: (id)args
{
    if (! [args count] > 1) {return;}

	// Initialize the [arguments]
	NSString *_url = (! [args[0] isKindOfClass:[NSNull class]] ? args[0] : nil);
	KrollCallback *_callback = ([args count] > 2 && ! [args[2] isKindOfClass:[NSNull class]] ? args[2] : nil);
	id _context = ([args count] > 3 && ! [args[3] isKindOfClass:[NSNull class]] ? args[3] : nil);
	
	// Argument Filter
	if (! _url) {return;}

	// Store new value in Firebase
	[[[Firebase alloc] initWithUrl:_url] setValue:args[1]];

	// Execute [callback] if supplied
	if (_callback)
	{
		[_callback call:@[args[1]] thisObject:_context];
	}
}

/**
 * Update [instance]
 *
 *	- args[0] - (NSString) the URL for Firebase Reference
 *	- args[1] - (id) values to be updated
 *  - args[2] - (KrollCallback) callback
 *  - args[3] - (id) context for callback(s)
 *  - args[4] - (KrollCallback) sync callback
 *
 */
- (void)update: (id)args
{
	// Safety Net
    if (! [args count] > 1) {return;}

	// Initialize the [arguments]
	NSString *_url = (! [args[0] isKindOfClass:[NSNull class]] ? args[0] : nil);
	KrollCallback *_callback = ([args count] > 2 && ! [args[2] isKindOfClass:[NSNull class]] ? args[2] : nil);
	id _context = ([args count] > 3 && ! [args[3] isKindOfClass:[NSNull class]] ? args[3] : nil);
	KrollCallback *_syncCallback = ([args count] > 4 && ! [args[4] isKindOfClass:[NSNull class]] ? args[4] : nil);
	
	// Argument Filter
	if (! _url) {return;}

	// Update the [instance] @ [url]
	[[[Firebase alloc] initWithUrl:_url] updateChildValues:args[1] withCompletionBlock:(! _syncCallback ? nil : ^(NSError *error, Firebase *ref)
	{
		// Execute [syncCallback]
		[_syncCallback call:@[args[1]] thisObject:nil];
	})];

	// Execute [callback] if supplied
	if (_callback)
	{
		[_callback call:@[args[1]] thisObject:_context];
	}
}

/**
 * Create a Firebase [listener] and return a [handle]
 *
 *	- args[0] - (NSString) the URL for Firebase Reference
 *	- args[1] - (NSString) Event Type to listen for
 *  - args[2] - (KrollCallback) callback
 *  - args[3] - (id) context for callback
 *
 */
-(id)on: (id)args
{
	// Initialize the [arguments]
	NSString *_url = ([args count] && ! [args[0] isKindOfClass:[NSNull class]] ? args[0] : nil);
	NSString *_type = ([args count] > 1 && ! [args[1] isKindOfClass:[NSNull class]] ? args[1] : nil);
	KrollCallback *_callback = ([args count] > 2 && ! [args[2] isKindOfClass:[NSNull class]] ? args[2] : nil);
	id _context = ([args count] > 3 && ! [args[3] isKindOfClass:[NSNull class]] ? args[3] : nil);

	NSLog(@"[INFO] Adding Listener: %@ (%@)", _type, _url);

	// Argument Filter
	if (! _url || ! _type || ! _callback) {return NO;}

	// Search for [type] in [gEventTypes]
	NSUInteger _search = [self.gEventTypes indexOfObject:_type];
	if (_search == NSNotFound) {return;}

	// Initialize [event] from [search]
	int* _event = _search;

	// Initialize [gInstances] for [url] (only done once p/[url])
	if (! self.gInstances[_url])
	{
		[self.gInstances setObject:[[Firebase alloc] initWithUrl:_url] forKey:_url];
		[self.gListeners setObject:[NSMutableDictionary dictionary] forKey:_url];
	}

	// Set the [handle] while creating a [listener]
	FirebaseHandle _handle = [self.gInstances[_url] observeEventType:_event withBlock:^(FDataSnapshot *_snapshot)
	{
		// Execute [callback]
		[_callback call:@[[NSMutableDictionary dictionaryWithObject:[self FDataSnapshotSpider:_snapshot] forKey:@"snapshot"]] thisObject:_context];
	}];

	// Initialize the [key] for [handle]
	NSNumber *_key = [NSNumber numberWithInteger:_handle];

	// Save the [handle] in [gListeners].[type]
	[self.gListeners[_url] setObject:_key forKey:_key];

	NSLog(@"[INFO] Returning Handle: (%@)", _key);

	// Return the [key] for future reference
	return _key;
}

/**
 * Remove a Firebase [listener] by [handle]
 *
 *	- args[0] - (NSString) the URL for Firebase Reference
 *	- args[1] - (NSString) Event Type to remove
 *	- args[2] - (NSNumber) Key to [gListeners][type] for [handle]
 *
 */
-(void)off: (id)args
{
	// Initialize the [arguments]
	NSString *_url = ([args count] && ! [args[0] isKindOfClass:[NSNull class]] ? args[0] : nil);
	NSString *_type = ([args count] > 1 && ! [args[1] isKindOfClass:[NSNull class]] ? args[1] : nil);
	NSNumber *_key = ([args count] > 2 && ! [args[2] isKindOfClass:[NSNull class]] ? args[2] : nil);

	NSLog(@"[INFO] Removing Listener: %@ (%@)", _type, _key);

	// Argument Filter
	if (! _url || ! _type || ! _key) {return;}

	// Search for [type] in [gEventTypes]
	NSUInteger _search = [self.gEventTypes indexOfObject:_type];
	if (_search == NSNotFound) {return;}

	// Initialize [event] from [search]
	int* _event = _search;

	// Ensure there is a [gInstance] for this [url]
	if (! self.gInstances[_url]) {

		// Take the opportunity to release [gListeners].[url] if needed
		if (self.gListeners[_url]) {
			[self.gListeners removeObjectForKey:_url];
		}

		return;
	}

	// Ensure there is a [gListener] for this [url] && [key]
	if (! self.gListeners[_url])
	{
		// Take the opportunity to release [gInstances].[url] if needed
		[self.gInstances removeObjectForKey:_url];

		return;
	}

	// Ensure there is a [gListener] for this [key]
	if (! self.gListeners[_url][_key]) {return;}

	// Remove the [listener] by [handle] from [gInstance]
	[self.gInstances[_url] removeObserverWithHandle:[self.gListeners[_url][_key] integerValue]];

	NSLog(@"[INFO] Listener Removed: %@ (%@)", _type, self.gListeners[_url][_key]);

	// Remove the [handle] from [gListeners].[type]
	[self.gListeners[_url] removeObjectForKey:_key];

	// Release [gInstance].[url] if this is the last [gListener]
	if (! [self.gListeners[_url] count])
	{
		NSLog(@"[INFO] Releasing Instance (%@)", _url);

		[self.gListeners removeObjectForKey:_url];
		[self.gInstances removeObjectForKey:_url];

		NSLog(@"[INFO] Released Instance (%@)", _url);
	}
}

#pragma mark Internal Utility Functions

-(id)FDataSnapshotSpider: (FDataSnapshot*)snapshot
{
	// Initialize the [payload]
	NSMutableDictionary *payload = [NSMutableDictionary dictionary];
	
	[payload setObject:(snapshot.name ? snapshot.name : @"root") forKey:@"name"];
	[payload setObject:snapshot.priority forKey:@"priority"];
	[payload setObject:[NSNumber numberWithInteger:snapshot.childrenCount] forKey:@"childrenCount"];
	
	// Check if [value] is an ARRAY
	if ([snapshot.value isKindOfClass:[NSArray class]])
	{
		[payload setObject:snapshot.value forKey:@"value"];
		[payload setObject:[NSNumber numberWithInteger:0] forKey:@"childrenCount"];
	}
	
	// Use [children] to set [value] w/Priority
	else if (snapshot.childrenCount)
	{
		// Initialize the [children]
		NSMutableDictionary *children = [NSMutableDictionary dictionary];
		
		for (FDataSnapshot *child in snapshot.children)
		{
			[children setObject:[self FDataSnapshotSpider:child] forKey:child.name];
		}
		
		[payload setObject:children forKey:@"value"];
	}
	
	// No [children]
	else
	{[payload setObject:snapshot.value forKey:@"value"];}
	
	return payload;
}

@end
