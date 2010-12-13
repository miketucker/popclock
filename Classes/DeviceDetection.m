

#import "DeviceDetection.h"

@implementation DeviceDetection

+ (uint) detectDevice {
    NSString *model= [[UIDevice currentDevice] model];
    struct utsname u;
	uname(&u);
	
    if (!strcmp(u.machine, "iPhone1,1")) {
		return MODEL_IPHONE;
	} else if (!strcmp(u.machine, "iPhone1,2")){
		return MODEL_IPHONE_3G;
	} else if (!strcmp(u.machine, "iPhone2,1")){
		return MODEL_IPHONE_3GS;
	} else if (!strcmp(u.machine, "iPhone3,1")){
		return MODEL_IPHONE_4;
	} else if (!strcmp(u.machine, "iPod1,1")){
		return MODEL_IPOD_TOUCH_GEN1;
	} else if (!strcmp(u.machine, "iPod2,1")){
		return MODEL_IPOD_TOUCH_GEN2;
	} else if (!strcmp(u.machine, "iPod3,1")){
		return MODEL_IPOD_TOUCH_GEN3;
	} else if (!strcmp(u.machine, "iPad1,1")){
		return MODEL_IPAD;
	} else if (!strcmp(u.machine, "i386")){
		//NSString *iPhoneSimulator = @"iPhone Simulator";
		NSString *iPadSimulator = @"iPad Simulator";
		if([model compare:iPadSimulator] == NSOrderedSame)
			return MODEL_IPAD_SIMULATOR;
		else
			return MODEL_IPHONE_SIMULATOR;
	}
	else {
		return MODEL_UNKNOWN;
	}
}

+ (NSString *) returnDeviceName:(BOOL)ignoreSimulator {
    NSString *returnValue = @"Unknown";
	
    switch ([DeviceDetection detectDevice])
	{
        case MODEL_IPHONE_SIMULATOR:
			returnValue = @"iPhone Simulator";
			break;
		case MODEL_IPOD_TOUCH_GEN1:
			returnValue = @"iPod Touch";
			break;
		case MODEL_IPOD_TOUCH_GEN2:
			returnValue = @"iPod Touch";
			break;
		case MODEL_IPOD_TOUCH_GEN3:
			returnValue = @"iPod Touch";
			break;
		case MODEL_IPHONE:
			returnValue = @"iPhone";
			break;
		case MODEL_IPHONE_3G:
			returnValue = @"iPhone 3G";
			break;
		case MODEL_IPHONE_3GS:
			returnValue = @"iPhone 3GS";
			break;
		case MODEL_IPHONE_4:
			returnValue = @"iPhone 4";
			break;
			
		case MODEL_IPAD:
			returnValue = @"iPad";
			break;
		default:
			break;
	}
	
	return returnValue;
}

@end