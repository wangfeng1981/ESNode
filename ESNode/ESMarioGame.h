//
//  ESMarioGame.h
//  ESNode
//
//  Created by Wang Feng on 13-4-23.
//  Copyright (c) 2013年 jfwf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESNode.h"
#import "ESPhysics.h"

@interface ESKupa : ESSimpleSprite
{
    GLfloat timecount ;
    ESSimpleSpriteFlipType mflip ;
    espMovingObject* movobj ;
    int direct ;
}
@property(assign,nonatomic)espMovingObject* movobj ;
@end
