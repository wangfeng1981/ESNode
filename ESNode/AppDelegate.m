//
//  AppDelegate.m
//  ESNode
//
//  Created by Wang Feng on 13-3-30.
//  Copyright (c) 2013年 jfwf. All rights reserved.
//

#import "AppDelegate.h"
#import "ESTools.h"






@implementation AppDelegate

- (void)dealloc
{
    [_displayLink invalidate] ;
    ESTOOLS_RELEASE(_glView) ;
    ESTOOLS_RELEASE(_esRoot) ;
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

#pragma mark - GLKView delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //[EAGLContext setCurrentContext:_glView.context];

    //duration
    if( _lastTimeStamp < 0.01 )
        _lastTimeStamp = _displayLink.timestamp ;
    float timeinter = _displayLink.timestamp - _lastTimeStamp ;
    
    glClearColor(0.0, 0.0, 0.2, 1.0) ;
    //glClearDepthf(0.0) ;
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT) ;
    
    //[EAGLContext setCurrentContext:_glView.context];
    
    if( _esRoot==nil )
    {
        _esRoot = [[ESRoot alloc] initWithTag:1 andEyePosi:GLKVector4Make(0, 20, 20, 1) andTarPosi:GLKVector4Make(0, 0, 0, 1) andNear:0.1f andFar:1000.f screenLandscape:NO] ;
        esAtlasTexture* atlas1 = [esAtlasTexture create:@"tex1"] ;
        NSLog(@"textureid %d and numSubtex:%d",atlas1.etexture.textureid,atlas1.numberOfSubtex) ;
        NSLog(@"default 3d shader id:%d\n default 2d shader id:%d",_esRoot._program3d.iprogram,_esRoot._program2d.iprogram) ;
        
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
        ES3dCube* cube = [[[ES3dCube alloc] initWithTag:101 andSize:2.f colors:colors] autorelease] ;
        [cube satTimerDuration:0.01f circles:ESNODE_TIMER_INFINITE_CIRCLE target:self action:@selector(onESNodeTimer:)] ;
        [_esRoot addChild:cube] ;
        
        ES3dCube* cube2 = [[[ES3dCube alloc] initWithTag:102 andSize:5.f colors:colors] autorelease] ;
        [cube addChild:cube2] ;
        esAnimation* anim = [[[esAnimation alloc] init] autorelease];
        [anim.keysArray addObject:[esAnimKeyFrame createx:0 y:-10.f z:0 xs:1 ys:1 zs:1 alpha:1 roll:0 yaw:0 pitch:0 duration:0]];
        [anim.keysArray addObject:[esAnimKeyFrame createx:0 y:10.f z:0 xs:1 ys:1 zs:1 alpha:1 roll:0 yaw:0 pitch:360 duration:2]];
        [cube2 satAnim:anim target:self beforeAnimStartAction:@selector(onBeforeAnim:) afterAnimEndAction:@selector(onAfterAnim:) start:0] ;
        
        ESSimpleSprite* spr1 = [[[ESSimpleSprite alloc] initWithTag:200 frame:CGRectMake(0, 0, 64 , 64) texture:[atlas1 buildESTextureById:7]] autorelease];
        //[spr1 satTimerDuration:0.1f circles:ESNODE_TIMER_INFINITE_CIRCLE target:self action:@selector(onESNodeTimer:)] ;
        [_esRoot.orthoRoot addChild:spr1] ;
        
        esAnimation* anim200 = [[[esAnimation alloc] init] autorelease];
        [anim200.keysArray addObject:[esAnimKeyFrame createx:0 y:0 z:0 xs:1 ys:1 zs:1 alpha:0.1 roll:0 yaw:0 pitch:0 duration:0]];
        [anim200.keysArray addObject:[esAnimKeyFrame createx:100 y:200 z:0 xs:1 ys:1 zs:1 alpha:1 roll:360 yaw:0 pitch:0 duration:10]];
        [spr1 satAnim:anim200 target:self beforeAnimStartAction:@selector(onBeforeAnim:) afterAnimEndAction:@selector(onAfterAnim:) start:0] ;
        
        ESSimpleButton* button1 = [[[ESSimpleButton alloc] initWithTag:300 frame:CGRectMake(320-64, 480-64, 64, 64) texture:[atlas1 buildESTextureById:9] target:self action:@selector(onButtonTapped:)] autorelease] ;
        [_esRoot.orthoRoot addChild:button1] ;
        
        //ESAnimationSprites
        int frameids1[16] = {200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215} ;
        eAnimationSprites* eas = [[[eAnimationSprites alloc] initWithAtlas:[esAtlasTexture create:@"spo"] numOfFrames:16 frameIdArray:frameids1 align:eAnimationSpritesQuadAlignTopLeft] autorelease] ;
        ESAnimationSprites* esas = [[[ESAnimationSprites alloc] initWithTag:400 frame:CGRectMake(200, 200, 64, 64) eAnimSprites:eas frameinter:0.1] autorelease];
        [esas playLoop] ;
        [_esRoot.orthoRoot addChild:esas] ;
        
        int frameids2[4] = {4001,4002,4003,4004} ;
        eAnimationSprites* eas2 = [[[eAnimationSprites alloc] initWithAtlas:[esAtlasTexture create:@"hero-packer"] numOfFrames:4 frameIdArray:frameids2 align:eAnimationSpritesQuadAlignBottomCenter] autorelease] ;
        ESAnimationSprites* esas2 = [[[ESAnimationSprites alloc] initWithTag:500 frame:CGRectMake(150, 270, 64, 64) eAnimSprites:eas2 frameinter:0.1] autorelease];
        [esas2 playLoop] ;
        [_esRoot.orthoRoot addChild:esas2] ;
        
    }
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
    static GLfloat s_deg = 0.f ;
    ESNode* node = (ESNode*)sender ;
    if( node.tag==101 )
    {
        node.yawDeg = s_deg ;
        s_deg++ ;
    }
}
-(void)onBeforeAnim:(id)sender
{
    //ESNode* node = (ESNode*)sender ;
    //NSLog(@"%d bef anim",node.tag) ;
}
-(void)onAfterAnim:(id)sender
{
    ESNode* node = (ESNode*)sender ;
    //NSLog(@"%d aft anim",node.tag) ;
    
    if( node.tag==102 )
    {
        esAnimation* anim = [[[esAnimation alloc] init] autorelease];
        [anim.keysArray addObject:[esAnimKeyFrame createx:0 y:-10.f z:0 xs:1 ys:1 zs:1 alpha:1 roll:0 yaw:0 pitch:0 duration:0]];
        [anim.keysArray addObject:[esAnimKeyFrame createx:0 y:10.f z:0 xs:3 ys:1 zs:1 alpha:0.1 roll:360 yaw:0 pitch:0 duration:5]];
        [node satAnim:anim target:self beforeAnimStartAction:@selector(onBeforeAnim:) afterAnimEndAction:@selector(onAfterAnim:) start:0] ;
    }
    
}
-(void)onButtonTapped:(id)sender
{
    ESNode* node = (ESNode*)sender ;
    NSLog(@"button %d tapped.",node.tag) ;
    ESNode* n1 = [[ESRoot currentRoot].orthoRoot locateChildByTag:400] ;
    if( n1 )
    {
        [n1 removeFromParent] ;
        NSLog(@"remove 400") ;
    }else
    {
        n1 = [[ESRoot currentRoot].orthoRoot locateChildByTag:500] ;
        if( n1 )
        {
            [n1 removeFromParent] ;
            NSLog(@"remove 500") ;
        }else
            NSLog(@"no remove");
    }
}
@end
