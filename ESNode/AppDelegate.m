//
//  AppDelegate.m
//  ESNode
//
//  Created by Wang Feng on 13-3-30.
//  Copyright (c) 2013年 jfwf. All rights reserved.
//

#import "AppDelegate.h"
#import "ESTools.h"
#import "ESMarioGame.h"





@implementation AppDelegate

- (void)dealloc
{
    [_displayLink invalidate] ;
    ESTOOLS_RELEASE(_glView) ;
    ESTOOLS_RELEASE(_esRoot) ;
    ESTOOLS_RELEASE(_espWorld) ;
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    EAGLContext* context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease] ;
    
    _glView = [[GLKView alloc] initWithFrame:[UIScreen mainScreen].bounds] ;
    _glView.context = context ;
    _glView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    _glView.drawableDepthFormat = GLKViewDrawableDepthFormat16 ;
    _glView.enableSetNeedsDisplay = NO ;
    _glView.delegate = self ;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)] ;
    _displayLink.frameInterval = 2 ;//30 fps.
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode] ;
    
    //_lastTimeStamp
    _lastTimeStamp = 0.0 ;
    
    [self.window addSubview:_glView] ;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //set context
    [EAGLContext setCurrentContext:_glView.context] ;

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application{_displayLink.paused=YES;}
- (void)applicationDidEnterBackground:(UIApplication *)application{}
- (void)applicationWillEnterForeground:(UIApplication *)application{}
- (void)applicationDidBecomeActive:(UIApplication *)application{_lastTimeStamp=0.0 ; _displayLink.paused=NO;}
- (void)applicationWillTerminate:(UIApplication *)application{}

GLfloat demo_xspeed = 0.f ;
ESSimpleSpriteFlipType demo_flip = ESSimpleSpriteFlipTypeLeftRight ;
#pragma mark - GLKView delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [EAGLContext setCurrentContext:_glView.context];

    //duration
    if( _lastTimeStamp < 0.01 )
        _lastTimeStamp = _displayLink.timestamp ;
    
    float timeinter = _displayLink.timestamp - _lastTimeStamp ;
    
    glClearColor(0.0, 0.0, 0.2, 1.0) ;
    //glClearDepthf(0.0) ;
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT) ;
    
    
    if( _esRoot==nil )
    {
        
        _esRoot = [[ESRoot alloc] initWithTag:1 andEyePosi:GLKVector4Make(0, 20, 20, 1) andTarPosi:GLKVector4Make(0, 0, 0, 1) andNear:0.1f andFar:1000.f screenLandscape:NO] ;

        GLKVector4 colors[24] ;
        {
            colors[0] = GLKVector4Make(1, 0, 0, 1) ;
            colors[1] = colors[0] ;
            colors[2] = colors[0] ;
            colors[3] = colors[0] ;
            
            colors[4] = GLKVector4Make(0, 1, 0, 1) ;
            colors[5] = colors[4];
            colors[6] = colors[4] ;
            colors[7] = colors[4] ;
            
            colors[8] = GLKVector4Make(0, 0, 1, 1) ;
            colors[9] = colors[8];
            colors[10] = colors[8];
            colors[11] = colors[8];
            
            colors[12] = GLKVector4Make(1, 1, 0, 1) ;
            colors[13] = colors[12] ;
            colors[14] = colors[12] ;
            colors[15] = colors[12] ;
            
            colors[16] = GLKVector4Make(0, 1, 1, 1) ;
            colors[17] = colors[16] ;
            colors[18] = colors[16] ;
            colors[19] = colors[16] ;
            
            colors[20] = GLKVector4Make(1, 0, 1, 1) ;
            colors[21] = colors[20] ;
            colors[22] = colors[20] ;
            colors[23] = colors[20] ;
        } 
        
        ES3dCube* cube = [[[ES3dCube alloc] initWithTag:101 andSize:5.f colors:colors] autorelease] ;
        [cube satTimerDuration:0.1 circles:ESNODE_TIMER_INFINITE_CIRCLE target:self action:@selector(onESNodeTimer:)] ;
        [_esRoot addChild:cube] ;
//        
//        ES3dCube* cube2 = [[[ES3dCube alloc] initWithTag:102 andSize:5.f colors:colors] autorelease] ;
//        [cube addChild:cube2] ;
//        esAnimation* anim = [[[esAnimation alloc] init] autorelease];
//        [anim.keysArray addObject:[esAnimKeyFrame createx:0 y:-10.f z:0 xs:1 ys:1 zs:1 alpha:1 roll:0 yaw:0 pitch:0 duration:0]];
//        [anim.keysArray addObject:[esAnimKeyFrame createx:0 y:10.f z:0 xs:1 ys:1 zs:1 alpha:1 roll:0 yaw:0 pitch:360 duration:2]];
//        [cube2 satAnim:anim target:self beforeAnimStartAction:@selector(onBeforeAnim:) afterAnimEndAction:@selector(onAfterAnim:) start:0] ;
        
        
        
//        ESSimpleSprite* spr1 = [[[ESSimpleSprite alloc] initWithTag:200 frame:CGRectMake(0, 0, 64 , 64) texture:[atlas1 buildESTextureById:7]] autorelease];
//        //[spr1 satTimerDuration:0.1f circles:ESNODE_TIMER_INFINITE_CIRCLE target:self action:@selector(onESNodeTimer:)] ;
//        [_esRoot.orthoRoot addChild:spr1] ;
//        
//        esAnimation* anim200 = [[[esAnimation alloc] init] autorelease];
//        [anim200.keysArray addObject:[esAnimKeyFrame createx:0 y:0 z:0 xs:1 ys:1 zs:1 alpha:0.1 roll:0 yaw:0 pitch:0 duration:0]];
//        [anim200.keysArray addObject:[esAnimKeyFrame createx:100 y:200 z:0 xs:1 ys:1 zs:1 alpha:1 roll:360 yaw:0 pitch:0 duration:10]];
//        [spr1 satAnim:anim200 target:self beforeAnimStartAction:@selector(onBeforeAnim:) afterAnimEndAction:@selector(onAfterAnim:) start:0] ;
//        
//        ESSimpleButton* button1 = [[[ESSimpleButton alloc] initWithTag:300 frame:CGRectMake(320-64, 480-64, 64, 64) texture:[atlas1 buildESTextureById:9] target:self action:@selector(onButtonTapped:)] autorelease] ;
//        [_esRoot.orthoRoot addChild:button1] ;
        
        //ESAnimationSprites
//        int frameids1[16] = {200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215} ;
//        eAnimationSprites* eas = [[[eAnimationSprites alloc] initWithAtlas:[esAtlasTexture create:@"spo"] numOfFrames:16 frameIdArray:frameids1 align:eAnimationSpritesQuadAlignTopLeft] autorelease] ;
//        ESAnimationSprites* esas = [[[ESAnimationSprites alloc] initWithTag:400 frame:CGRectMake(200, 200, 64, 64) eAnimSprites:eas frameinter:0.1] autorelease];
//        [esas playLoop] ;
//        [_esRoot.orthoRoot addChild:esas] ;
//        
//        int frameids2[4] = {4001,4002,4003,4004} ;
//        eAnimationSprites* eas2 = [[[eAnimationSprites alloc] initWithAtlas:[esAtlasTexture create:@"hero-packer"] numOfFrames:4 frameIdArray:frameids2 align:eAnimationSpritesQuadAlignBottomCenter] autorelease] ;
//        ESAnimationSprites* esas2 = [[[ESAnimationSprites alloc] initWithTag:500 frame:CGRectMake(150, 270, 64, 64) eAnimSprites:eas2 frameinter:0.1] autorelease];
//        [esas2 playLoop] ;
//        [_esRoot.orthoRoot addChild:esas2] ;
        
        
        //map
        ESTileMap* map = [[[ESTileMap alloc] initWithTag:600 resfile:@"testingMap"] autorelease] ;
        [_esRoot.orthoRoot addChild:map] ;
        
        //physics world
        espTileShape shapelist[5] ;
        shapelist[0] = espTileShapeMakeRect(0, 0, 32, 32) ;
        shapelist[1] = espTileShapeMakeTria(32, 0, -32, 32 ) ;
        shapelist[2] = espTileShapeMakeTria(0, 0, 32, 32) ;
        shapelist[3] = espTileShapeMakeTria(32, 32,-32,-32) ;
        shapelist[4] = espTileShapeMakeTria(0, 32, 32,-32 ) ;
        _espWorld = [[espWorld2D alloc] initWithShortDataArray:[map gatTileData] colNum:map.tileWidthNumber rowNum:map.tileHeightNumber tileWid:map.tileCellWidth tileHei:map.tileCellHeight shapelist:shapelist numInShapelist:5] ;
        
        //player
        esAtlasTexture* resAtlas = [[[esAtlasTexture alloc] initWithResName:@"res1"] autorelease] ;
        ESSimpleSprite* player = [[[ESSimpleSprite alloc] initWithTag:700 frame:CGRectMake(34, 34, 18, 18) texture:[resAtlas buildESTextureById:1101]] autorelease];
        [_esRoot.orthoRoot addChild:player] ;
        [_espWorld addMovObject:1 x:34+9 y:34+9 halfwidth:9 halfheight:9] ;
        
        //kupa
        ESKupa* kupa = [[[ESKupa alloc] initWithTag:710 frame:CGRectMake(32*6, 32*4, 24, 24) texture:[resAtlas buildESTextureById:1401]] autorelease] ;
        [_esRoot.orthoRoot addChild:kupa] ;
        int imovobj = [_espWorld addMovObject:2 x:32*6+12 y:32*4+12 halfwidth:12 halfheight:12] ;
        kupa.movobj = [_espWorld getMovObj:imovobj] ;
        
        //game pad
        {
            ESNode* pad = [[[ESNode alloc] initWithTag:800] autorelease] ;
            pad.userInteraction = ESNodeUserInteractionChildrenOnly ;
            ESSimpleButton* left = [[[ESSimpleButton alloc] initWithTag:801 frame:CGRectMake(0, 0, 32, 32) texture:[resAtlas buildESTextureById:3002] target:self action:@selector(onButtonTapped:)] autorelease] ;
            ESSimpleButton* right = [[[ESSimpleButton alloc] initWithTag:802 frame:CGRectMake(64, 0, 32, 32) texture:[resAtlas buildESTextureById:3001] target:self action:@selector(onButtonTapped:)] autorelease] ;
            //ESSimpleButton* up = [[[ESSimpleButton alloc] initWithTag:803 frame:CGRectMake(32, 0, 32, 32) texture:[resAtlas buildESTextureById:3003] target:self action:@selector(onButtonTapped:)] autorelease] ;
            ESSimpleButton* btnA = [[[ESSimpleButton alloc] initWithTag:804 frame:CGRectMake(320-32, 0, 32, 32) texture:[resAtlas buildESTextureById:3005] target:self action:@selector(onButtonTapped:)] autorelease] ;
            ESSimpleButton* start = [[[ESSimpleButton alloc] initWithTag:805 frame:CGRectMake(320-96, 0, 32, 32) texture:[resAtlas buildESTextureById:3010] target:self action:@selector(onButtonTapped:)] autorelease] ;
            left.alpha =right.alpha=btnA.alpha=start.alpha= 0.5 ;
            [pad addChild:left] ;
            [pad addChild:right] ;
            [pad addChild:btnA] ;
            [pad addChild:start] ;
            [left setTouchEventTarget:self begin:@selector(onTouchBegin:) move:@selector(onTouchMove:) end:@selector(onTouchEnd:)] ;
            [right setTouchEventTarget:self begin:@selector(onTouchBegin:) move:@selector(onTouchMove:) end:@selector(onTouchEnd:)] ;
            [_esRoot.orthoRoot addChild:pad] ;
        } 
    }
   
    
    [_espWorld getMovObj:0]->xspeed = demo_xspeed ;
    [_espWorld update:timeinter] ;
    ESNode* playerNode = [_esRoot.orthoRoot locateChildByTag:700] ;
    if( playerNode )
    {
        playerNode.center = GLKVector4Make( [_espWorld getMovObj:0]->x, [_espWorld getMovObj:0]->y, 0, 1) ;
        [(ESSimpleSprite*)playerNode flip:demo_flip] ;
    }
    ESNode* kupaNode = [_esRoot.orthoRoot locateChildByTag:710] ;
    if( kupaNode )
    {
        kupaNode.center = GLKVector4Make([_espWorld getMovObj:1]->x, [_espWorld getMovObj:1]->y , 0, 1) ;
    }
    /* useuse*/
    
    [_esRoot update:timeinter] ;
    [_esRoot draw] ;
    
    _lastTimeStamp = _displayLink.timestamp ;
    
}

#pragma mark - Render
-(void)render:(CADisplayLink*)displayLink
{
    [_glView display] ;
}

#pragma mark - User Events
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_esRoot touchesBegan:touches withEvent:event] ;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_esRoot touchesMoved:touches withEvent:event] ;
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event] ;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_esRoot touchesEnded:touches withEvent:event] ;
}


-(void)onESNodeTimer:(id)sender
{
    ESNode* node = (ESNode*)sender ;
    if( node.tag==101 )
    {
        node.yawDeg += 3.f ;
        if( node.yawDeg >= 360.f )
            node.yawDeg = 1.f ;
    }
}
-(void)onBeforeAnim:(id)sender
{

}
-(void)onAfterAnim:(id)sender
{
    //ESNode* node = (ESNode*)sender ;
    //NSLog(@"%d aft anim",node.tag) ;
}
-(void)onButtonTapped:(id)sender
{
    ESNode* node = (ESNode*)sender ;
    if( node.tag==804 )
    {
        [_espWorld getMovObj:0]->yspeed = 120 ;
    }
}
-(void)onTouchBegin:(id)sender
{
    ESNode* node = (ESNode*)sender ;
    if( node.tag==801 )
    {
        demo_xspeed = -40 ;
        demo_flip = ESSimpleSpriteFlipTypeRightLeft ;
    }
    else if( node.tag==802 )
    {
        demo_xspeed = 40 ;
        demo_flip = ESSimpleSpriteFlipTypeLeftRight  ;
    }
}
-(void)onTouchMove:(id)sender
{
    
}
-(void)onTouchEnd:(id)sender
{
    ESNode* node = (ESNode*)sender ;
    if( node.tag==801 || node.tag == 802 )
        demo_xspeed = 0 ;
}
@end
