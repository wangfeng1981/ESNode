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
#import "ESNode.h"
#import "ESTools.h"
#import "ESPhysics.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,GLKViewDelegate>
{
    CFTimeInterval _lastTimeStamp ;
    CADisplayLink* _displayLink ;
    GLKView* _glView ;
    
    ESRoot* _esRoot ;
    espWorld2D* _espWorld ;
}

@property (strong, nonatomic) UIWindow *window;

-(void)render:(CADisplayLink*)displayLink ;


-(void)onESNodeTimer:(id)sender ;
-(void)onBeforeAnim:(id)sender ;
-(void)onAfterAnim:(id)sender ;
-(void)onButtonTapped:(id)sender ;
-(void)onTouchBegin:(id)sender ;
-(void)onTouchMove:(id)sender ;
-(void)onTouchEnd:(id)sender ;
@end
