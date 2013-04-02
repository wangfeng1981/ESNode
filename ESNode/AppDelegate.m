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
        esTexture* texture1 = [esTexture createByName:@"texture1"] ;
        NSLog(@"textureid %d",texture1.etexture.textureid) ;
        NSLog(@"default 3d shader programid %d",_esRoot._program3d.iprogram) ;
        
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
        ES3dCube* cube = [[[ES3dCube alloc] initWithTag:101 andSize:10.f colors:colors] autorelease] ;
        [cube satTimerDuration:0.01f circles:ESNODE_TIMER_INFINITE_CIRCLE target:self action:@selector(onESNodeTimer:)] ;
        [_esRoot addChild:cube] ;
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
    if( node.tag=101 )
    {
        node.yawDeg = s_deg ;
        s_deg++ ;
    }
    
}

@end
