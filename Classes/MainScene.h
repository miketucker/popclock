//
//  HelloWorldScene.h
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "Force.h"

@interface MainScene : CCLayer
{
	CCTexture2D *circle_10;
	CCTexture2D *circle_30;
	CCTexture2D *circle_sm;
	CCTexture2D *circle_med;
	CCTexture2D *circle;
	
	Force forces[9];
	b2World* world;
	GLESDebugDraw *m_debugDraw;
	int nForces;
	float max;
	float min;
	b2Body *curHour;
	b2Body *curMin;
	b2Body *curSec;
	
	int hourCount;
	b2Body *hours[24];	
	int minCount;
	b2Body *mins[60];	
	b2Body *secs[60];	
	
	CCLabel *lMins[60];	
	CCLabel *lHours[24];	
	
	float rColor;
	int hVar;
	int sVar;
	int tVar;
	
	int secCount;
	
	CCLabel *labelHour;
	CCLabel *labelMin;
	
	NSString *imgSm;
	NSString *imgMed;
	NSString *imgLg;
	
	
	bool touchDown;
	int downCount;
	int tap;
	int tapTimer;
	
	int colR;
	int colG;
	int colB;
	
	int tSec;
	int tMin;
	int tHour;
	
	int sw;
	int sh;
	float SIZE_SM;
	float SIZE_MED;
	float SIZE_LG;
	int SIZE_FONT_SM;
	int SIZE_FONT_LG;
	int DEVICE_TYPE;
	float FORCE_PULSE;
	float FORCE_PULL;
	float FORCE_DISTANCE;
	int POP_MARGIN;
}


void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v );

- (void) reset:(bool)newColors;
-(ccColor3B) getColor:(bool)active andV:(float)andV andL:(int)l;
-(void) destroySecs;
-(void) destroyMins;
-(void) destroyHours;


-(void) addMin:(bool)doPop;
-(void) addSec:(bool)doPop;
-(void) addHour:(bool)doPop;

-(ccColor3B) HSLtoRGB:(float)h andSat:(float)s andL:(float)l;

-(void) destroy:(b2Body *)body;
-(void) tickRepulse;
-(void)applyForce:(b2Body*)b andLoc:(CGPoint)location andStrength:(float)str;
-(void)doRepulse:(b2Body*)b andLoc:(CGPoint)location andStrength:(float)str;

-(void) doTouchForces:(NSSet *)set;
-(void) doForce:(CGPoint)location;

float dist(b2Vec2 point1, CGPoint point2);

+(id) scene;
-(void) invoke;
-(void) targetMethod;
+(void) updatePoints:(NSSet *)touches;

-(b2Body *) addNewSpriteWithCoords:(float)rad andNum:(int)num andPop:(bool)doPop;

-(void) tickSecond;

@end
