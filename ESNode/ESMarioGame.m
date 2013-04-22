//
//  ESMarioGame.m
//  ESNode
//
//  Created by Wang Feng on 13-4-23.
//  Copyright (c) 2013年 jfwf. All rights reserved.
//

#import "ESMarioGame.h"

@implementation ESKupa
@synthesize movobj ;
-(id)initWithTag:(int)tag1 frame:(CGRect)frm texture:(esTexture *)estexture1
{
    self = [super initWithTag:tag1 frame:frm texture:estexture1] ;
    if( self )
    {
        timecount = 0 ;
        mflip = ESSimpleSpriteFlipTypeLeftRight ;
        movobj = NULL ;
        direct = 1 ;
    }
    return self ;
}

-(void)updateMeAndChildren:(GLfloat)timeinter
{
    if( movobj )
    {
        timecount += timeinter ;
        if( timecount > 5 )
        {
            timecount = 0 ;
            direct *= -1 ;
            if (mflip==ESSimpleSpriteFlipTypeRightLeft) {
                mflip = ESSimpleSpriteFlipTypeLeftRight ;
            }else mflip = ESSimpleSpriteFlipTypeRightLeft ;
            [self flip:mflip] ;
        }
        movobj->xspeed = direct*30.f ;
    }
    [super updateMeAndChildren:timeinter] ;
}

@end
