
#import "MainScene.h"
#import "SimpleAudioEngine.h"
#define PTM_RATIO 32


enum {
	kTagTileMap = 1,
	kTagSpriteSheet = 1,
	kTagAnimation1 = 1,
	
};

#define DEV_IPHONE 1
#define DEV_IPAD 2
#define DEV_IPHONE4 3

#define SND_ID_S1 0
#define SND_ID_S2 1
#define SND_ID_S3 2
#define SND_ID_S4 3
#define SND_ID_M1 4
#define SND_ID_H1 5

// HelloWorld implementation
@implementation MainScene


+(id) scene
{
	CCScene *scene = [CCScene node];
	MainScene *layer = [MainScene node];
	[scene addChild:layer z:0 tag:1];
	return scene;
}



// initialize your instance here
-(id) init
{
	if( (self=[super init])) {
		
		CGSize s = [[[UIApplication sharedApplication] keyWindow] bounds].size;
		sw = s.width;
		sh = s.height;
		
		if ([[CCDirector sharedDirector] contentScaleFactor] == 2.0)
			DEVICE_TYPE = DEV_IPHONE4;
		else if (s.height == 1024)
			DEVICE_TYPE = DEV_IPAD;
		else
			DEVICE_TYPE = DEV_IPHONE;
		
		
		if (DEVICE_TYPE == DEV_IPHONE) {
			SIZE_SM=5.0f;
			SIZE_MED=15.0f;
			SIZE_LG=30.0f;
			SIZE_FONT_SM=14;
			SIZE_FONT_LG=30;
			FORCE_PULSE = 30.0f;
			FORCE_PULL = 4.0F;
			DEVICE_TYPE = true;
			FORCE_PULL = 2.0f;
			FORCE_DISTANCE = 100.0f;
			POP_MARGIN = 20;
			imgSm = @"circle_10.png";
			imgMed = @"circle_30.png";
			imgLg = @"circle_60.png";
		} else {
			SIZE_SM=10.0f;
			SIZE_MED=30.0f;
			SIZE_LG=60.0f;
			SIZE_FONT_SM=28;
			SIZE_FONT_LG=60;
			FORCE_PULSE = 50.0f;
			FORCE_PULL = 8.0f;
			FORCE_DISTANCE = 300.0f;
			POP_MARGIN = 100;
			imgSm = @"circle_20.png";
			imgMed = @"circle_60.png";
			imgLg = @"circle_120.png";
		}
		
		min = 0.0;
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		b2Vec2 gravity;
		gravity.Set(0.0f, 0.0f);
		bool doSleep = true;
		
		world = new b2World(gravity, doSleep);		
		world->SetContinuousPhysics(true);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
		
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner
		b2Body* groundBody = world->CreateBody(&groundBodyDef);
		b2PolygonShape groundBox;		
		
		float m = 1.0f;
		
		// bottom
		groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// top
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO*m), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO*m));
		groundBody->CreateFixture(&groundBox,0);
		
		// left
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO * m), b2Vec2(0,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// right
		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO * m), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
		[self reset:true];
		
		[self schedule: @selector(tick:)];
		[self schedule:@selector(tickSecond) interval:1];
		
	}
	return self;
}

- (void) reset:(bool)newColors{
	
	
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	unsigned int unitFlags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
	NSDateComponents *comp = [calendar components:unitFlags fromDate:date];
	
	tHour = [comp hour];
	tMin = [comp minute];
	tSec = [comp second];
	
	[self destroySecs];
	[self destroyMins];
	[self destroyHours];
	
	if(newColors){
		rColor =  (float) (rand() / (RAND_MAX / 360 + 1)+ 0);
		hVar = (rand() / (RAND_MAX / 5 + 1) + 0) * 5;
		sVar = (rand() / (RAND_MAX / 10 + 1) + 0) * 10;
		tVar = (rand() / (RAND_MAX / 10 + 1) + 0);
	}
	
	NSLog(@"color %f %i %i %i",rColor, hVar,sVar,tVar);
	
	
	int i;
	for (i=0; i < tHour; i++) {
		[self addHour:false];
	}
	
	for (i=0; i < tMin; i++) {
		[self addMin:false];
	}
	
	for (i=0; i < tSec; i++) {
		[self addSec:false];
	}
}


-(ccColor3B) getColor:(bool)active andV:(float)andV andL:(int)l {
	float h;
	float s = 1.0f;
	float v = 1.0f; //100.f + (float) (rand() % 5000) / 100.0f
	
	float r = 0.0f;
	float g = 0.0f;
	float b = 0.0f;
	
	h =  rColor;
	
	//return ccc3(255, 255, 255);
	
	if(active){
		//v -= (float) (rand() % 50) / 50.0f;
		
		if (l == -1) {
			s = 0.0f;
			v = 1.0f;
			//v = (float)(rand() / (RAND_MAX / 50 + 1)) / 50.0f;
		}
		
		HSVtoRGB(&r, &g, &b, h, s, v);
		ccColor3B c = {(GLubyte)(r*255), (GLubyte)(g*255), (GLubyte)(b*255)};
		return c;
	} else {
		h -= 180.0f + (float) (rand() % (hVar+1));
		
		if (l > 0) {
			if (l == 1) {
				h -= 45.0f;
			} else {
				h += 45.0f;
			}
		} 
		
		if(h < 0.0f) h += 360.0f;
		else if(h > 360.0f) h -= 360.0f;
		s -= (float) (rand() % (sVar+1)) / 255.0f;
		v -= (float) (rand() % 255) / 255.0f;
		
		if (l == -1) {
			s = 0.0f;
			v = (float) (rand() % 90) / 255.0f;
		}
		
		HSVtoRGB(&r, &g, &b, h, s, v);
		
		ccColor3B c = {(GLubyte)(r*255), (GLubyte)(g*255), (GLubyte)(b*255)};
		
		return c;
	}
	
}

void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v )
{
	//NSLog(@"Hue %f",h);
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}

-(void) tickSecond {
	
	// NEW MIN //
	
	if (secCount > 58) {
		[self destroySecs];
		
		// NEW HOUR //
		
		if (minCount > 58) {
			[self destroyMins];
			
			// NEW DAY //
			
			if (hourCount > 22) {
				[self destroyHours];
				[[SimpleAudioEngine sharedEngine] playEffect:@"d1.wav"];
			} else {
				[self addHour:true];
				[[SimpleAudioEngine sharedEngine] playEffect:@"h1.wav"];
			}
			
		} else {
			[self addMin:true];
			[[SimpleAudioEngine sharedEngine] playEffect:@"m1.wav"];
		}
	} else {
		[[SimpleAudioEngine sharedEngine] playEffect:@"4.wav" pitch:(float) (rand() % 25) / 50.0f + 0.5f pan:(float) (rand() %200) / 100.0f - 1.0f gain:(float) (rand() %50) / 100.0f + 0.5f];
		[self addSec:true];
	}
	
	
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	unsigned int unitFlags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
	NSDateComponents *comp = [calendar components:unitFlags fromDate:date];
	
	int h = [comp hour];
	int m = [comp minute];
	if (h != hourCount || m != minCount) {
		[self reset:false];
	}
	
}

-(void) destroySecs{
	for (int i=0; i < secCount; i++) {
		[self destroy:secs[i]];
	}
	secCount = 0;	
}

-(void) destroyHours{
	
	for (int i=0; i < hourCount; i++) {
		[self destroy:hours[i]];
	}
	hourCount = 0;	
}

-(void) destroyMins{
	for (int i=0; i < minCount; i++) {
		[self destroy:mins[i]];
	}
	minCount = 0;	
}


-(void) addMin:(bool)doPop {
	
	int cl;
	if(tVar < 4){
		cl = rand() % 2 + 1;
	} else if(tVar < 8) {
		cl = 0;
	} else {
		cl = -1;
	}
	
	if (minCount > 0){
		CCSprite* s = (CCSprite*) mins[minCount-1]->GetUserData();
		[s setColor:[self getColor:false andV:0.0f andL:cl]];	
		CCLabel* l = (CCLabel*) [s getChildByTag:1];
		[l setColor:[self getColor:false andV:0.0f andL:cl]];
	}
	
	mins[minCount] = [self addNewSpriteWithCoords:SIZE_MED andNum:minCount+1 andPop:doPop ];
	curMin = mins[minCount]; 
	[(CCSprite*)curMin->GetUserData() setColor:[self getColor:true andV:0.0f andL:cl]];
	
	if(cl==-1){
		CCSprite* s = (CCSprite*)curMin->GetUserData();
		CCLabel* l = (CCLabel*) [s getChildByTag:1];
		[l setColor:ccBLACK];
	}
	
	
	minCount ++;
}

-(void) addSec:(bool)doPop {
	int cl;
	if(tVar < 4){
		cl = rand() % 2 + 1;
	} else if(tVar < 8) {
		cl = 0;
	} else {
		cl = -1;
	}
	
	if(secCount > 0){
		[(CCSprite*)secs[secCount-1]->GetUserData() setColor:[self getColor:false andV:0.0f andL:cl]];
	}
	
	secs[secCount] = [self addNewSpriteWithCoords:SIZE_SM andNum:0 andPop:doPop ];
	curSec = secs[secCount];
	secCount ++;	
}

-(void) addHour:(bool)doPop {
	
	
	int cl;
	if(tVar < 4){
		cl = rand() % 2 + 1;
	} else if(tVar < 8) {
		cl = 0;
	} else {
		cl = -1;
	}
	
	if (hourCount > 0){
		CCSprite* s = (CCSprite*) hours[hourCount-1]->GetUserData();
		[s setColor:[self getColor:false andV:0.0f andL:cl]];
		CCLabel* l = (CCLabel*) [s getChildByTag:1];
		[l setColor:[self getColor:false andV:0.0f andL:cl]];
		[l setColor:[self getColor:false andV:50.0f andL:cl] ];
	}
	
	hours[hourCount] = [self addNewSpriteWithCoords:SIZE_LG andNum:hourCount+1  andPop:doPop ];
	curHour = hours[hourCount];
	[(CCSprite*)curHour->GetUserData() setColor:[self getColor:true andV:0.0f andL:cl]];
	
	if(cl==-1){
		CCSprite* s = (CCSprite*)curHour->GetUserData();
		CCLabel* l = (CCLabel*) [s getChildByTag:1];
		[l setColor:ccBLACK];
	}
	
	hourCount ++;	
}

-(ccColor3B) HSLtoRGB:(float)h andSat:(float)s andL:(float)l
{
    float r, g, b;
    float temp1, temp2, tempr, tempg, tempb;
	
	h /= 360.0f;
	s /= 256.0f;
	l /= 256.0f;
	
	NSLog(@"HSL %f, %f, %f",h,s,l);
    
    if (s == 0)         //Saturation of 0 means a shade of grey
    {
    	r = g = b = l;
    }
    else                //
    {
        if (l < 0.5)
            temp2 = l * (1.0 + s);
        else
            temp2 = (l + s) - (l * s);
        
        temp1 = 2.0 * l - temp2;
        tempr = h + 1.0 / 3.0;
        if (tempr > 1.0)
            tempr-= 1.0;
        tempg = h;
        tempb = h - 1.0 / 3.0;
        if (tempb < 0) 
            tempb += 1.0; 
        
        // Calculate red value:     
        if (6.0 * tempr < 1.0)
        {
            r = temp1 + (temp2 - temp1) * 6.0 * tempr;
        }
        else if (2.0 * tempr < 1.0)
        {
            r = temp2;
        }
        else if (3.0 * tempr < 2.0)
        {
            r = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - tempr) * 6.0;
        }
        else
        {
            r = temp1;
        }
		
        // Calculate green value       
        if (6.0 * tempg < 1.0)
        {
            g = temp1 + (temp2 - temp1) * 6.0 * tempg;
        }
        else if (2.0 * tempg < 1.0)
        {
            g = temp2;
        }
        else if (3.0 * tempg < 2.0)
        {
            g = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - tempg) * 6.0;
        }
        else
        {
            g = temp1; 
        }
		
        // Calculate blue value    
        if (6.0 * tempb < 1.0)
        {
            b = temp1 + (temp2 - temp1) * 6.0 * tempb;
        }
        else if (2.0 * tempb < 1.0)
        {
            b = temp2;
        }
        else if (3.0 * tempr < 2.0)
        {
            b = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - tempb) * 6.0;
        }
        else
        {
            g = temp1; 
        }
    }
	
    ccColor3B color = ccc3(int(r * 256.0),int(g * 256.0),int(b * 256.0));   
	
	NSLog(@" final: %f, %f, %f,",r,g,b);
	
    return color;
}


-(void) destroy:(b2Body *)body{
	
	CCSprite *spr = (CCSprite*)body->GetUserData();
	id sc = [CCScaleBy actionWithDuration:0.5f scale:0 ];
	id del = [CCCallFuncN actionWithTarget:self selector:@selector(removeFromParent:)];
	[spr runAction:[CCSequence actions:sc,del,nil ]];
	world->DestroyBody(body);
}

- (void) removeFromParent:(id)sender{
	[self removeChild:sender cleanup:YES];
}

-(void) draw
{
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
}

-(b2Body *) addNewSpriteWithCoords:(float)rad andNum:(int)num andPop:(bool)doPop
{
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	CGPoint p = CGPointMake(POP_MARGIN/2 + (random() % sw) - POP_MARGIN/2, POP_MARGIN/2+ (random() % sh) - POP_MARGIN/2);	
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	
	CCSprite *cpng;
	
	if (rad == SIZE_SM) {
		cpng = [CCSprite spriteWithFile:imgSm];
	}else if(rad == SIZE_MED){
		cpng = [CCSprite spriteWithFile:imgMed];
	} else {
		cpng = [CCSprite spriteWithFile:imgLg];
	}
	
	if(num > 0){
		CCLabel *label;		//[label setColor:ccc3(0, 0, 0)];
		
		
		if (rad == SIZE_LG) {
			label = [CCLabel labelWithString:[NSString stringWithFormat:@"%d", num] fontName:@"Helvetica-Bold" fontSize:SIZE_FONT_LG ];	
			label.position = CGPointMake( rad, rad);
		} else {
			label = [CCLabel labelWithString:[NSString stringWithFormat:@"%d", num] fontName:@"Helvetica-Bold" fontSize:SIZE_FONT_SM ];	
			label.position = CGPointMake( rad, rad );
		}
		[cpng addChild:label z:1 tag:1];
	}
	
	//[cpng setColor:ccc3(random() % 255,random() % 255, random() % 255)];
	[self addChild:cpng z:0];
	cpng.position = CGPointMake( p.x * PTM_RATIO, p.y * PTM_RATIO);
	if(doPop){
		cpng.scale = 3;
		[cpng runAction:[CCScaleTo actionWithDuration:0.05f scale:1 ]];
	} else {
		cpng.scale = 1;
	}
	bodyDef.userData = cpng;
	
	b2Body *body = world->CreateBody(&bodyDef);
	// Define another box shape for our dynamic body.
	b2CircleShape circle; 
	
	// 57.0f
	
	
	circle.m_radius = (float) rad / PTM_RATIO;//These are mid points for our 1m box
	
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circle;
	
	if (rad == SIZE_SM) {
		fixtureDef.density = 2.0f;
	}else if(rad == SIZE_MED){
		fixtureDef.density = 0.5f;
	} else {
		fixtureDef.density = 0.2f;
	}
	
	
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
	
	
	CGPoint rep = CGPointMake(p.x, p.y);
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		[self doRepulse:b andLoc:rep andStrength:FORCE_PULSE];
	}
	
	return body;
}


-(void) tickRepulse{
	
	int i;
	CGPoint p;
	for (i=0; i<hourCount; i++) {
		if (hours[i] != curHour) {
			
			p = CGPointMake(hours[i]->GetPosition().x * PTM_RATIO, hours[i]->GetPosition().y * PTM_RATIO);
			
			for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
			{
				[self doRepulse:b andLoc:p andStrength:1.0f];
			}
			
		}
	}
	
}

-(void) tick: (ccTime) dt
{
	
	
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
	
	
	//Iterate over the bodies in the physics world
	
	
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		
		if (b->GetUserData() != NULL) {
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			if (myActor.contentSize.width > SIZE_SM) {
				[myActor getChildByTag:1].rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
			}
			
		}	
	}
	
	if(touchDown) downCount ++;
	if(tapTimer >0) tapTimer --;
	else tap = 0;
}


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self doTouchForces:event.allTouches];
}

-(void) doTouchForces:(NSSet *)set{
	CGPoint location;
	
	
	for( UITouch *touch in set ) {
		if (touch.phase < 3) {
			location = [touch locationInView: [touch view]];
			location = [[CCDirector sharedDirector] convertToGL: location];
			
			[self doForce:location];
		}
		
	}
	
}

-(void) doForce:(CGPoint)location{
	
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		[self applyForce:b andLoc:location andStrength:FORCE_PULL];
	}	
	
}
-(void) applyForce:(b2Body*)b andLoc:(CGPoint)location andStrength:(float)str{
	
	float fx;
	float fy;
	float d;
	float r;
	b2Vec2 vec;
	
	
	
	if(dist(b->GetPosition(),location) < FORCE_DISTANCE){
		fx = ( location.x - b->GetPosition().x * PTM_RATIO );
		fy = ( location.y - b->GetPosition().y * PTM_RATIO );
		d = sqrt(fx * fx + fy*fy);
		
		fx /= d;
		fy /= d;
		
		r = (d - min) / (FORCE_DISTANCE - min);
		
		if (r < 0) {
			r = 0;
		} else if (r > 1) {
			r = 1;
		}
		
		vec = b2Vec2(fx * r * str, fy * r * str);
		b->ApplyLinearImpulse(vec,b->GetPosition());
		
	}							
	
}					

-(void)doRepulse:(b2Body*)b andLoc:(CGPoint)location andStrength:(float)str{
	
	float fx;
	float fy;
	float d;
	float r;
	b2Vec2 vec;
	
	
	
	if(dist(b->GetPosition(),location) < FORCE_DISTANCE){
		fx = 1e-7 + ( location.x - b->GetPosition().x * PTM_RATIO );
		fy = 1e-7 + ( location.y - b->GetPosition().y * PTM_RATIO );
		d = sqrt(fx * fx + fy*fy);
		
		fx /= d;
		fy /= d;
		
		r = (d - min) / (FORCE_DISTANCE - min);
		
		if (r < 0) {
			r = 0;
		} else if (r > 1) {
			r = 1;
		}
		
		vec = b2Vec2(-fx * r * str, -fy * r * str);
		b->ApplyLinearImpulse(vec,b->GetPosition());
		
	}							
	
}					



float dist(b2Vec2 point1, CGPoint point2)
{
	float dx = point2.x - point1.x* PTM_RATIO;
	float dy = point2.y - point1.y* PTM_RATIO;
	return sqrt(dx*dx + dy*dy );
};


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	
	if ([touches count] < 2) {
		touchDown = true;
		downCount = 0;
	} else {
		touchDown = false;
	}
	[self doTouchForces:event.allTouches];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (touchDown && downCount < 10) {
		if(tap == 0){
			tap++;
			tapTimer = 20;
		} else { // DOUBLE TAP RESETS COLORS
			[self reset:true];
		}
	}
	touchDown = false;
	
	[self doTouchForces:event.allTouches];
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	b2Vec2 gravity( accelX * 10, accelY * 10);
	
	world->SetGravity( gravity );
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	//delete m_debugDraw;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
