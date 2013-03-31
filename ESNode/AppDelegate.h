//
//  AppDelegate.h
//  ESNode
//
//  Created by Wang Feng on 13-3-30.
//  Copyright (c) 2013年 jfwf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,GLKViewDelegate>
{
    CFTimeInterval _lastTimeStamp ;
    CADisplayLink* _displayLink ;
    GLKView* _glView ;
}

@property (strong, nonatomic) UIWindow *window;

-(void)render:(CADisplayLink*)displayLink ;
@end
