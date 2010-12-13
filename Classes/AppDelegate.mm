//
//  popclock2AppDelegate.m
//  popclock2
//
//  Created by Michael Tucker on 9/11/10.
//  Copyright BASE / APEX 2010. All rights reserved.
//

#import "AppDelegate.h"
#import "cocos2d.h"
#import "MainScene.h"
#import "DeviceDetection.h"

@implementation AppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{

	CC_DIRECTOR_INIT();
	
	CCDirector *director = [CCDirector sharedDirector];
	
	if([[DeviceDetection returnDeviceName:false] isEqualToString:@"iPhone 4"]) {
		[[CCDirector sharedDirector] setContentScaleFactor:2.0];
	} 
	
	
	EAGLView *view = [director openGLView];
	[view setMultipleTouchEnabled:YES];
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	[[CCDirector sharedDirector] runWithScene: [MainScene scene]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[CCDirector sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
