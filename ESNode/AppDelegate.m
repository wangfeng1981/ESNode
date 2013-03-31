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
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    EAGLContext* context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease] ;
    
    _glView = [[GLKView alloc] initWithFrame:[UIScreen mainScreen].bounds context:context] ;
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
    //duration
    if( _lastTimeStamp < 0.01 )
        _lastTimeStamp = _displayLink.timestamp ;
    //float duration = _displayLink.timestamp - _lastTimeStamp ;
    
    glClearColor(0.0, 0.0, 0.2, 1.0) ;
    glClear(GL_COLOR_BUFFER_BIT) ;
    
    
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
    NSLog(@"touch") ;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
