//
//  ESNode.m
//  ESNode
//
//  Created by Wang Feng on 13-3-30.
//  Copyright (c) 2013年 jfwf. All rights reserved.
//

#import "ESNode.h"
#import "ESTools.h"
//============================================================
#pragma mark - indie functions
const GLfloat c_es2piD180 = 0.01745f ;
void es2Matrix4RotateXYZ(GLKMatrix4* mat4,GLfloat rollFir,GLfloat yawSec,GLfloat pitchThi)
{// roll( z rotate) first; yaw(y rotate) second ; pitch(x rotate) last. All in Degree.
    GLfloat c=rollFir*c_es2piD180 ; // z
    GLfloat b=yawSec*c_es2piD180; // y
    GLfloat a=pitchThi*c_es2piD180 ; //x
    GLfloat ca = cosf(a) ;
    GLfloat sa = sinf(a) ;
    GLfloat cb = cosf(b) ;
    GLfloat sb = sinf(b) ;
    GLfloat cc = cosf(c) ;
    GLfloat sc = sinf(c) ;
    mat4->m[0] = cb * cc ;
    mat4->m[1] = sa*sb*cc+ca*sc ;
    mat4->m[2] = -ca*sb*cc+sa*sc ;
    mat4->m[4] = -cb*sc ;
    mat4->m[5] = -sa*sb*sc+ca*cc ;
    mat4->m[6] = ca*sb*sc + sa*cc ;
    mat4->m[8] = sb ;
    mat4->m[9] = -sa*cb ;
    mat4->m[10]= ca*cb ;
}







//=============================================================
#pragma mark - ESNode the very beginning.

@implementation ESNode
//assign properties
@synthesize tag, displayed, userInteraction , hasRemovedFromParent ;
@synthesize center, rollDeg, yawDeg, pitchDeg, xScale, yScale, zScale,alpha ;
@synthesize parentNodeA,prevSiblingA ;
@synthesize animPaused ;

//retain properties
@synthesize firstChildR , nextSiblingR ;

//readonly
@synthesize timerState ,timerCircles ;

-(void)dealloc
{
	parentNodeA = nil;
	prevSiblingA = nil ;
    timerState = ESNODE_TIMER_NONE ;
    timerTarget = nil ;
    
    //release children
    ESTOOLS_RELEASE(firstChildR) ;
    ESTOOLS_RELEASE(nextSiblingR) ;
    //anim
    ESTOOLS_RELEASE(animation) ;
	[super dealloc] ;
}
-(id)initWithTag:(int)tag1
{
	self = [super init] ;
	if( self )
	{
		tag = tag1 ;
        displayed = YES ;
		parentNodeA = nil ;
        prevSiblingA = nil ;
		firstChildR = nil ;
		nextSiblingR = nil ;
		hasRemovedFromParent = NO ;
		rollDeg = yawDeg = pitchDeg = 0.f ;
		center = GLKVector4Make(0, 0, 0, 1) ;
        xScale = yScale = zScale = 1.f ;
        alpha = 1.f ;
        
        needUpdateMatrix[0]=needUpdateMatrix[1]=needUpdateMatrix[2]=YES;
        movMatrix = GLKMatrix4Identity ;
        rotMatrix = GLKMatrix4Identity ;
        sclMatrix = GLKMatrix4Identity ;
        modMatrix = GLKMatrix4Identity ;
        transformMatrix = GLKMatrix4Identity ;
        
		timerState = ESNODE_TIMER_NONE ;
        timerTarget = nil ;
        
        userInteraction = ESNodeUserInteractionNone ;
	}
	return self ;
}

-(void)addChild:(ESNode*)node
{
	if( node ==nil ) return ;
	node.parentNodeA = self ;
	if( firstChildR )
	{
		ESNode* n = firstChildR;
		while (n.nextSiblingR) {
			n = n.nextSiblingR;
		}
		n.nextSiblingR= node ;
		node.prevSiblingA= n ;
	}else {
		self.firstChildR= node ;
	}
}

-(void)insertChild:(ESNode*)node afterNode:(ESNode*)anode
{
	if( node ==nil || anode==nil ) return ;
	node.parentNodeA= self ;
	ESNode* n = firstChildR;
	while ( n ) {
		if( n==anode )
		{
			n.nextSiblingR.prevSiblingA= node ;
			node.prevSiblingA= n ;
			node.nextSiblingR= n.nextSiblingR;
			n.nextSiblingR= node ;
			return ;
		}
		n = n.nextSiblingR;
	}
}
-(void)insertChild:(ESNode *)node beforeNode:(ESNode*)bnode
{
	if( node ==nil || bnode==nil ) return  ;
	node.parentNodeA= self ;
	if( self.firstChildR == bnode )
	{
		self.firstChildR.prevSiblingA= node ;
		node.nextSiblingR= self.firstChildR ;
		self.firstChildR = node ;
		return  ;
	}else {
		ESNode* n = self.firstChildR ;
		while (n.nextSiblingR) {
			if( n.nextSiblingR==bnode )
			{
				n.nextSiblingR.prevSiblingA= node ;
				node.prevSiblingA= n ;
				node.nextSiblingR= n.nextSiblingR;
				n.nextSiblingR= node ;
				return ;
			}
			n = n.nextSiblingR;
		}
	}
}

-(BOOL)removeChild:(ESNode*)node
{
	if( node==nil || node.parentNodeA==nil || node.hasRemovedFromParent ) return NO;
	ESNode* c =self.firstChildR ;
	while (c) {
		if( c == node )
		{
			[node removeFromParent] ;
			return YES;
		}
		c = c.nextSiblingR;
	}
    
	c = self.firstChildR ;
	while (c) {
		if( [c removeChild:node] ) return YES ;
		c = c.nextSiblingR;
	}
	return NO ;
}

-(ESNode*)locateChildByTag:(int)tag1
{
	ESNode* n = self.firstChildR ;
	while (n) {
		if( n.tag == tag1 )
			return n ;
		n = n.nextSiblingR;
	}
	n = self.firstChildR ;
	while (n) {
		ESNode* nodeFind = [n locateChildByTag:tag1] ;
		if( nodeFind ) return nodeFind ;
		n = n.nextSiblingR;
	}
	return nil;
}

-(void)removeFromParent
{
	if( hasRemovedFromParent ) return ;
	hasRemovedFromParent = YES ;//self.nextSiblingR= nil ;
	if( self.parentNodeA==nil ) return ;
	if( self.prevSiblingA)
	{
		[self retain] ;
		self.prevSiblingA.nextSiblingR= self.nextSiblingR;
		self.nextSiblingR.prevSiblingA= self.prevSiblingA;
		[self autorelease] ;
	}else {
		[self retain] ;
		self.parentNodeA.firstChildR = self.nextSiblingR;
		self.nextSiblingR.prevSiblingA= nil ;
		[self autorelease] ;
	}
	self.parentNodeA= nil ;
	self.prevSiblingA= nil ;
}



-(void)update:(GLfloat)timeinter
{//---------------------------------------
	if( timerState==ESNODE_TIMER_GOING )
	{
        if( timerCircles == 0 ) [self deleteTimer] ;
        else
        {
            timerSeconds += timeinter ;
            if( timerSeconds >= timerDuration )
            {
                timerSeconds = 0.f ;
                if(timerCircles!=ESNODE_TIMER_INFINITE_CIRCLE)
                    timerCircles-- ;
                [timerTarget performSelector:timerAction withObject:self] ;
            }
        }
	}
    //anim
    if( animation && animPaused == NO )
    {
        if( animDuration < 0.001f && animDuration+timeinter >= 0.001f && animTarget )
            [animTarget performSelector:animBeforeAction withObject:self] ;
        BOOL isAnimFinished = NO ;
        [animation update:animDuration finished:&isAnimFinished]; 
        animDuration += timeinter ;
        self.center = GLKVector4Make(animation.x, animation.y, animation.z, 1.f) ;
        self.xScale = animation.xs ;
        self.yScale = animation.ys ;
        self.zScale = animation.zs ;
        self.rollDeg = animation.roll ;
        self.yawDeg = animation.yaw ;
        self.pitchDeg = animation.pitch ;
        self.alpha = animation.alpha ;
        if( isAnimFinished )
        {
            ESTOOLS_RELEASE(animation) ;
            if( animTarget )
                [animTarget performSelector:animAfterAction withObject:self] ;
        }
    }
	[self updateMeAndChildren:timeinter] ;
	if( self.nextSiblingR)
	{
        [self.nextSiblingR update:timeinter] ;
		if( hasRemovedFromParent ) self.nextSiblingR= nil ;
	}//2012-11-02
}

-(void)updateMeAndChildren:(GLfloat)timeinter
{//---------------------------------------
	if( self.firstChildR )
		[self.firstChildR update:timeinter] ;
}

-(void)draw
{//---------------------------------------
	if( displayed )
	{
		[self updateTransformMatrix] ;
		[self drawMeAndChildren] ;
	}
	if( self.nextSiblingR )
		[self.nextSiblingR draw] ;
    needUpdateMatrix[0]=needUpdateMatrix[1]=needUpdateMatrix[2]=needUpdateMatrix[3]=NO ;
}

#pragma mark - testing properties if need matrix recalculating.
-(void)setCenter:(GLKVector4)center1
{
    if( memcmp(&center , &center1, sizeof(center))==0 )
        return ;
    center = center1 ;
    needUpdateMatrix[0] = YES ;
}
-(void)setRollDeg:(GLfloat)rollDeg1
{
    if( fabsf(rollDeg-rollDeg1 ) < 0.01f )
        return ;
    rollDeg = rollDeg1 ;
    needUpdateMatrix[1] = YES ;
}

-(void)setYawDeg:(GLfloat)yawDeg1
{
    if( fabsf(yawDeg -yawDeg1 ) < 0.01f )
        return ;
    yawDeg = yawDeg1 ;
    needUpdateMatrix[1] = YES ;
}
-(void)setPitchDeg:(GLfloat)pitchDeg1
{
    if( fabsf(pitchDeg -pitchDeg1 ) < 0.01f )
        return ;
    pitchDeg = pitchDeg1 ;
    needUpdateMatrix[1] = YES ;
}
-(void)setXScale:(GLfloat)xScale1
{
    if( fabsf(xScale-xScale1 ) < 0.001f )
        return ;
    xScale = xScale1 ;
    needUpdateMatrix[2] = YES ;
}
-(void)setYScale:(GLfloat)yScale1
{
    if( fabsf(yScale-yScale1 ) < 0.001f )
        return ;
    yScale = yScale1 ;
    needUpdateMatrix[2] = YES ;
}
-(void)setZScale:(GLfloat)zScale1
{
    if( fabsf(zScale-zScale1 ) < 0.001f )
        return ;
    zScale = zScale1 ;
    needUpdateMatrix[2] = YES ;
}
-(void)updateTransformMatrix
{//---------------------------------------
    needUpdateMatrix[3] = NO ;
	if( needUpdateMatrix[0] )
	{
        needUpdateMatrix[3] = YES ;
        movMatrix.m[12] = center.x ;
        movMatrix.m[13] = center.y ;
        movMatrix.m[14] = center.z ;
	}
	if( needUpdateMatrix[1] )
	{
        needUpdateMatrix[3] = YES ;
		es2Matrix4RotateXYZ(&rotMatrix, rollDeg, yawDeg, pitchDeg) ;
	}
    if( needUpdateMatrix[2] )
    {
        needUpdateMatrix[3] = YES ;
        sclMatrix.m00 = xScale ;
        sclMatrix.m11 = yScale ;
        sclMatrix.m22 = zScale ;
    }
    //V'= Mrot x Mmov x V : Mov first , then Rot.
    if( needUpdateMatrix[3] )
    {// mM = scl x rot x mov
        modMatrix = GLKMatrix4Multiply( rotMatrix, sclMatrix ) ;
        modMatrix = GLKMatrix4Multiply( movMatrix, modMatrix) ;
    }
	if( parentNodeA )
    {
        if( [parentNodeA isTransformMatrixChanged] || needUpdateMatrix[3])
        {
            needUpdateMatrix[3] = YES ;
            transformMatrix = GLKMatrix4Multiply(*[parentNodeA gatTransformMatrix], modMatrix) ;
        }
    }else if( needUpdateMatrix[3] )
    {
        transformMatrix = modMatrix ;
    }
}

-(void)drawMeAndChildren
{//---------------------------------------
	if( self.firstChildR )
		[self.firstChildR draw] ;
}

-(GLKMatrix4*)gatTransformMatrix 
{//---------------------------------------
	return &transformMatrix ;
}


-(void)satTransformMatrix:(GLKMatrix4)mat4
{//---------------------------------------
    transformMatrix = mat4 ;
}
-(BOOL)isTransformMatrixChanged
{//---------------------------------------
    if( needUpdateMatrix[0] || needUpdateMatrix[1] || needUpdateMatrix[2]
       || needUpdateMatrix[3] )
        return YES ;
    else return NO ;
}



-(void)satTimerDuration:(GLfloat)dura1circ circles:(int)ncirc target:(id)tar action:(SEL)act
{//---------------------------------------
    timerState = ESNODE_TIMER_GOING ;
    timerSeconds = 0.f ;
	timerDuration = dura1circ ;
	timerCircles = ncirc ;
	timerTarget = tar ;
	timerAction = act ;
}

-(void)deleteTimer
{
    timerState = ESNODE_TIMER_NONE ;
    timerTarget = nil ;
}
-(void)pauseTimer
{
    if( timerState == ESNODE_TIMER_GOING )
        timerState=ESNODE_TIMER_PAUSE;
}
-(void)resumeTimer
{
    if( timerState== ESNODE_TIMER_PAUSE )
        timerState = ESNODE_TIMER_GOING ;
}
//animation
-(void)satAnim:(esAnimation*)anim target:(id)tar beforeAnimStartAction:(SEL)befAction afterAnimEndAction:(SEL)aftAction start:(GLfloat)start
{
    if( anim != animation )
    {
        ESTOOLS_RELEASE(animation) ;
        animation = [anim retain] ;
    }
    animDuration = start ;
    animTarget = tar ;
    animBeforeAction = befAction ;
    animAfterAction = aftAction ;
    animPaused = NO ;
}

//UserInteraction
-(BOOL)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( self.nextSiblingR )
    {
        if( [self.nextSiblingR touchesBegan:touches withEvent:event] )
            return YES ;
    }
    if( userInteraction==ESNodeUserInteractionNone ) return NO;
    if( userInteraction==ESNodeUserInteractionSelfAndChildren || userInteraction==ESNodeUserInteractionChildrenOnly )
    {
        if( self.firstChildR )
        {
            if( [self.firstChildR touchesBegan:touches withEvent:event] )
                return YES ;
        }
    }
    if( userInteraction==ESNodeUserInteractionSelfOnly || userInteraction==ESNodeUserInteractionSelfAndChildren )
    {
        return [self overWriteTouchesBegan:touches withEvent:event] ;
    }
    return NO;
}
-(BOOL)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( self.nextSiblingR )
    {
        if( [self.nextSiblingR touchesMoved:touches withEvent:event] )
            return YES ;
    }
    if( userInteraction==ESNodeUserInteractionNone ) return NO;
    if( userInteraction==ESNodeUserInteractionSelfAndChildren || userInteraction==ESNodeUserInteractionChildrenOnly )
    {
        if( self.firstChildR )
        {
            if( [self.firstChildR touchesMoved:touches withEvent:event] )
                return YES ;
        }
    }
    if( userInteraction==ESNodeUserInteractionSelfOnly || userInteraction==ESNodeUserInteractionSelfAndChildren )
    {
        return [self overWriteTouchesMoved:touches withEvent:event] ;
    }
    return NO;
}
-(BOOL)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( self.nextSiblingR )
    {
        if( [self.nextSiblingR touchesEnded:touches withEvent:event] )
            return YES ;
    }
    if( userInteraction==ESNodeUserInteractionNone ) return NO;
    if( userInteraction==ESNodeUserInteractionSelfAndChildren || userInteraction==ESNodeUserInteractionChildrenOnly )
    {
        if( self.firstChildR )
        {
            if( [self.firstChildR touchesEnded:touches withEvent:event] )
                return YES ;
        }
    }
    if( userInteraction==ESNodeUserInteractionSelfOnly || userInteraction==ESNodeUserInteractionSelfAndChildren )
    {
        return [self overWriteTouchesEnded:touches withEvent:event] ;
    }
    return NO;
}
//for Overwrite.
-(BOOL)overWriteTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    return NO ;
}
-(BOOL)overWriteTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    return NO ;
}
-(BOOL)overWriteTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    return NO ;
}
//center location
-(CGPoint)centerInRoot 
{
    CGPoint pt = CGPointMake(0, 0) ;
    ESNode* c = self ;
    while (c.parentNodeA) {
        pt.x += c.center.x ;
        pt.y += c.center.y ;
        c = c.parentNodeA ;
    }
    return pt ;
}
@end


//=============================================================
#pragma mark - ESRoot what we started.
static ESRoot* s_currentESRoot = nil ;

@implementation ESRoot
@synthesize	lookTarget ,eyePosition ;
@synthesize widthpixel,heightpixel,deviceType,screenLandscape,isRetina ;
@synthesize _program2d,_program3d,orthoRoot ;


+(ESRoot*)currentRoot
{
	return s_currentESRoot ;
}
-(void)dealloc
{
	if( s_currentESRoot==self )
		s_currentESRoot = nil ;
    ESTOOLS_RELEASE(orthoRoot) ;
    ESTOOLS_RELEASE(_program2d) ;
    ESTOOLS_RELEASE(_program3d) ;
	[super dealloc] ;
}

-(id)initWithTag:(int)tag1 andEyePosi:(GLKVector4)veye andTarPosi:(GLKVector4)vtar andNear:(GLfloat)n andFar:(GLfloat)f
 screenLandscape:(BOOL)landscape 
{
	self = [super initWithTag:tag1] ;
	if( self )
	{
		// init camera projection .
		zfar = f ;
        znear = n ;
        self.eyePosition = veye ;
        self.lookTarget = vtar ;
        screenLandscape = landscape ;
        CGSize scrSize = [UIScreen mainScreen].bounds.size ;
        if( scrSize.height==480.0 )
            deviceType = ESRootDeviceTypeIPhone ;
        else if( scrSize.height==568.0 )
            deviceType = ESRootDeviceTypeIPhone5 ;
        else if( scrSize.height==1024.0 )
            deviceType = ESRootDeviceTypeIPad ;
        else deviceType = ESRootDeviceTypeUnknow ;
        
        if( [UIScreen mainScreen].scale == 1.0)
            isRetina = NO ;
        else isRetina = YES ;
        
        if( deviceType==ESRootDeviceTypeIPhone )
        {
            widthpixel = 480.0 ;
            heightpixel = 320.0 ;
        }else if( deviceType==ESRootDeviceTypeIPhone5 )
        {
            widthpixel = 568.0 ;
            heightpixel = 320.0 ;
        }else if( deviceType==ESRootDeviceTypeIPad)
        {
            widthpixel = 1024.0 ;
            heightpixel = 768.0 ;
        }
        if( screenLandscape == NO )
        {
            GLfloat t = widthpixel ;
            widthpixel = heightpixel ;
            heightpixel = t ;
        }
		s_currentESRoot = self ;
        
        //projection matrix
        rotMatrix = GLKMatrix4MakePerspective(1.04f, widthpixel/heightpixel, znear, zfar) ;
        
        NSArray* attrArray1 = [NSArray arrayWithObjects:@"a_position",@"a_color", nil] ;
        NSArray* unifArray1 = [NSArray arrayWithObjects:@"u_trans", nil] ;
        
        static GLchar strVertShader3d[] = "attribute vec4 a_position;attribute vec4 a_color;varying vec4 v_color;uniform mat4 u_trans;void main(){gl_Position=u_trans*a_position;v_color=a_color;}" ;
        static GLchar strFragShader3d[] = "varying lowp vec4 v_color;void main(){gl_FragColor=v_color;}" ;
        
        _program3d = [[esProgram alloc] initWithVshString:strVertShader3d andFshString:strFragShader3d andAttrnameArray:attrArray1 andUnifnameArray:unifArray1] ;
        
        static GLchar strVsh2d[]="attribute vec4 a_position;attribute vec4 a_color;attribute vec2 a_coor0;uniform mat4 u_transform;varying vec2 v_coor0;varying vec4 v_color;void main(){gl_Position = u_transform*a_position ;v_coor0 = a_coor0 ;v_color = a_color ;}";
        static GLchar strFsh2d[]="uniform sampler2D u_texture ;varying mediump vec2 v_coor0 ;varying lowp vec4 v_color ;void main(){gl_FragColor=texture2D(u_texture,v_coor0)*v_color;}";
        NSArray* attrs2 = [NSArray arrayWithObjects:@"a_position",@"a_color",@"a_coor0", nil] ;
        NSArray* unifs2 = [NSArray arrayWithObjects:@"u_transform",@"u_texture", nil] ;
        _program2d = [[esProgram alloc] initWithVshString:strVsh2d andFshString:strFsh2d andAttrnameArray:attrs2 andUnifnameArray:unifs2] ;
        
        
        //setup OpenGL
        glEnable(GL_CULL_FACE) ;
        glEnable(GL_BLEND) ;
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) ;
        
        //setup ortho root
        orthoRoot = [[ESNode alloc] initWithTag:0] ;
        GLKMatrix4 orthoMat4 = GLKMatrix4MakeOrtho(0, self.widthpixel, 0, self.heightpixel, 0.0f, 10.f) ;
        [orthoRoot satTransformMatrix:orthoMat4] ;
        
        //userinteraction
        self.userInteraction = ESNodeUserInteractionSelfAndChildren ;
	}
	return self ;
}
-(void)setLookTarget:(GLKVector4)lookTarget1
{
    if( memcmp(&lookTarget, &lookTarget1, sizeof(GLKVector4)) == 0)
        return ;
    needUpdateMatrix[0] = YES ;
    lookTarget = lookTarget1 ;
}
-(void)setEyePosition:(GLKVector4)eyePosition1
{
    if( memcmp(&eyePosition , &eyePosition1, sizeof(GLKVector4)) == 0)
        return ;
    needUpdateMatrix[0] = YES ;
    eyePosition = eyePosition1 ;
}

-(void)updateTransformMatrix
{
    if( needUpdateMatrix[0] )
    {   // use movMatrix as view Matrix
        movMatrix = GLKMatrix4MakeLookAt(eyePosition.x, eyePosition.y, eyePosition.z, lookTarget.x, lookTarget.y, lookTarget.z, 0.f, 1.f, 0.f) ;
        // rootMatrix = projectionMatrix x viewMatrix
        transformMatrix = GLKMatrix4Multiply(rotMatrix, movMatrix) ;
        NSLog(@"root update matrix"); 
    }
}

-(void)updateMeAndChildren:(GLfloat)timeinter
{
    [super updateMeAndChildren:timeinter] ;
    if( orthoRoot.firstChildR )
        [orthoRoot.firstChildR update:timeinter] ;
}

-(void)draw
{
	// use perspective projection for 3D world.
	glEnable(GL_DEPTH_TEST) ;
	[self updateTransformMatrix] ;
	if( firstChildR )
		[firstChildR draw] ;
	
	// use ortho projection for 2D UI Scence.
	glDisable(GL_DEPTH_TEST) ;
    if( orthoRoot.firstChildR )
        [orthoRoot.firstChildR draw] ;
    
    //
    needUpdateMatrix[0]=NO ;
}
//UserInteraction
-(BOOL)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( userInteraction==ESNodeUserInteractionSelfAndChildren || userInteraction==ESNodeUserInteractionChildrenOnly )
    {
        if( self.firstChildR )
        {
            if( [self.firstChildR touchesBegan:touches withEvent:event] )
                return YES ;
        }
        if( self.orthoRoot.firstChildR )
            if( [self.orthoRoot.firstChildR touchesBegan:touches withEvent:event])
                return YES ;
    }
    if( userInteraction==ESNodeUserInteractionSelfOnly || userInteraction==ESNodeUserInteractionSelfAndChildren )
    {
        return [self overWriteTouchesBegan:touches withEvent:event] ;
    }
    return NO;
}
-(BOOL)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( userInteraction==ESNodeUserInteractionSelfAndChildren || userInteraction==ESNodeUserInteractionChildrenOnly )
    {
        if( self.firstChildR )
        {
            if( [self.firstChildR touchesMoved:touches withEvent:event] )
                return YES ;
        }
        if( self.orthoRoot.firstChildR )
            if( [self.orthoRoot.firstChildR touchesMoved:touches withEvent:event])
                return YES ;
    }
    if( userInteraction==ESNodeUserInteractionSelfOnly || userInteraction==ESNodeUserInteractionSelfAndChildren )
    {
        return [self overWriteTouchesMoved:touches withEvent:event] ;
    }
    return NO;
}
-(BOOL)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( userInteraction==ESNodeUserInteractionSelfAndChildren || userInteraction==ESNodeUserInteractionChildrenOnly )
    {
        if( self.firstChildR )
        {
            if( [self.firstChildR touchesEnded:touches withEvent:event] )
                return YES ;
        }
        if( self.orthoRoot.firstChildR )
            if( [self.orthoRoot.firstChildR touchesEnded:touches withEvent:event])
                return YES ;
    }
    if( userInteraction==ESNodeUserInteractionSelfOnly || userInteraction==ESNodeUserInteractionSelfAndChildren )
    {
        return [self overWriteTouchesEnded:touches withEvent:event] ;
    }
    return NO;
}
@end


//=============================================================
#pragma mark - ES3dCube
const GLfloat c_cubeVertices[72] =
{
	1,1,1,		1,-1,1,		1,1,-1,		1,-1,-1,//+x
	-1,1,-1,	-1,-1,-1,	-1,1,1,		-1,-1,1,//-x
	-1,1,1,		1,1,1,		-1,1,-1,	1,1,-1,//+y
	1,-1,1,		-1,-1,1,	1,-1,-1,	-1,-1,-1,//-y
	-1,1,1,		-1,-1,1,	1,1,1,		1,-1,1,//+z
	1,1,-1,		1,-1,-1,	-1,1,-1,	-1,-1,-1//-z
} ;
const GLubyte c_cubeIndices[36] = 
{
	0,1,2,    1,3,2,      4,5,6, 5,7,6,
	8,9,10,   9,11,10,    12,13,14, 13,15,14,
	16,17,18, 17,19,18,   20,21,22, 21,23,22
};
@implementation ES3dCube
-(id)initWithTag:(int)tag1 andSize:(GLfloat)sz singleColor:(GLKVector4)color1 
{
    GLKVector4 tempcolor[24] ;
    for (int i = 0; i<24; i++)
        tempcolor[i] = color1 ;
    return [self initWithTag:tag1 andSize:sz colors:tempcolor] ;
}
-(id)initWithTag:(int)tag1 andSize:(GLfloat)sz colors:(GLKVector4*)color24
{
    self = [super initWithTag:tag1] ;
    if( self )
    {
        GLfloat hsz = sz/2.f ;
        for (int i = 0; i<24 ; i++) {
            vertices[i].x = c_cubeVertices[i*3+0]*hsz ;
            vertices[i].y = c_cubeVertices[i*3+1]*hsz ;
            vertices[i].z = c_cubeVertices[i*3+2]*hsz ;
            vertices[i].r = color24[i].r ;
            vertices[i].g = color24[i].g ;
            vertices[i].b = color24[i].b ;
            vertices[i].a = color24[i].a ;
        }
    }
    return self ;
}

-(void)drawMeAndChildren
{
    esProgram* program1 = [ESRoot currentRoot]._program3d ;
    if( program1 )
	{
		[program1 useProgram] ;
		[program1 updateUniform:0 byMat4:&transformMatrix] ;
        [program1 updateAttribute:0 size:3 type:GL_FLOAT normalize:0 stride:7*sizeof(GLfloat) pointer:vertices] ;
		[program1 updateAttribute:1 size:4 type:GL_FLOAT normalize:0 stride:7*sizeof(GLfloat) pointer:&(vertices[0].r)] ;
		glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_BYTE, c_cubeIndices) ;
	}
    
    [super drawMeAndChildren] ;
}
-(void)setAlpha:(GLfloat)alpha1
{
    alpha = alpha1 ;
    for (int i = 0; i<24 ; i++) {
        vertices[i].a = alpha ;
    }
}
@end

//=============================================================
#pragma mark - ESSimpleSprite
@implementation ESSimpleSprite
@synthesize estexture ;
-(void)dealloc
{
    ESTOOLS_RELEASE(estexture) ;
    [super dealloc] ;
}
-(id)initWithTag:(int)tag1 frame:(CGRect)frm texture:(esTexture*)estexture1 
{
    self = [super initWithTag:tag1] ;
    if( self )
    {
        vertices[0].x = -frm.size.width/2.f ;
        vertices[0].y = -frm.size.height/2.f ;
        vertices[1].x =  frm.size.width/2.f ;
        vertices[1].y = vertices[0].y ;
        vertices[2].x = vertices[0].x ;
        vertices[2].y = frm.size.height/2.f ;
        vertices[3].x = vertices[1].x ;
        vertices[3].y = vertices[2].y ;
        self.estexture = estexture1 ;
        for (int i = 0; i<4; i++) {
            vertices[i].z = 0.f ;
            vertices[i].r=vertices[i].g=vertices[i].b=vertices[i].a=1.f;
        }
        self.center = GLKVector4Make(frm.origin.x+frm.size.width/2.f, frm.origin.y+frm.size.height/2.f, 0.f, 1.f) ;
    }
    return self ;
}
-(void)setEstexture:(esTexture *)estexture1
{
    if( estexture == estexture1 ) return ;
    ESTOOLS_RELEASE(estexture) ;
    if( estexture1 )
    {
        estexture = [estexture1 retain] ;
        GLfloat* c8 = [estexture getCoords8] ;
        vertices[0].s = c8[0] ;
        vertices[0].t = c8[1] ;
        vertices[1].s = c8[2] ;
        vertices[1].t = c8[3] ;
        vertices[2].s = c8[4] ;
        vertices[2].t = c8[5] ;
        vertices[3].s = c8[6] ;
        vertices[3].t = c8[7] ;
    }
}
-(void)drawMeAndChildren
{
    if( self.estexture )
    {
        esProgram* program1 = [ESRoot currentRoot]._program2d ;
        if( program1 )
        {
            [program1 useProgram] ;
            [program1 updateUniform:0 byMat4:&transformMatrix] ;
            [program1 bindTexture0ByTextureId:self.estexture.etexture.textureid uniformIndex:1] ;
            [program1 updateAttribute:0 size:3 type:GL_FLOAT normalize:0 stride:9*sizeof(GLfloat) pointer:vertices] ;
            [program1 updateAttribute:1 size:4 type:GL_FLOAT normalize:0 stride:9*sizeof(GLfloat) pointer:&(vertices[0].r)] ;
            [program1 updateAttribute:2 size:2 type:GL_FLOAT normalize:0 stride:9*sizeof(GLfloat) pointer:&(vertices[0].s)] ;
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4) ;
        }
    }
    [super drawMeAndChildren] ;
}
-(void)setAlpha:(GLfloat)alpha1
{
    alpha = alpha1 ;
    for (int i = 0; i<4; i++) {
        vertices[i].a=alpha ;
    }
}
-(GLfloat)width
{
    return vertices[1].x-vertices[0].x ;
}
-(GLfloat)height
{
    return vertices[2].y - vertices[0].y ;
}
@end


//=============================================================
#pragma mark - ESSimpleButton
@implementation ESSimpleButton
-(id)initWithTag:(int)tag1 frame:(CGRect)frm texture:(esTexture*)estexture1 target:(id)tar action:(SEL)act
{
    self = [super initWithTag:tag1 frame:frm texture:estexture1] ;
    if( self )
    {
        tapTarget = tar ;
        tapAction = act ;
        self.userInteraction = ESNodeUserInteractionSelfOnly ;
    }
    return self ;
}
//for Overwrite.
-(BOOL)overWriteTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject] ;
    if( [self isTouchInSide:touch] )
    {
        //NSLog(@"touch began inside") ;
        hasTouchIn = YES ;
        for (int i = 0; i<4; i++) {
            vertices[i].r=vertices[i].g=vertices[i].b=0.25f;
            vertices[i].a=1.f;
        }
    }else
    {
        hasTouchIn = NO ;
        for (int i = 0; i<4; i++) {
            vertices[i].r=vertices[i].g=vertices[i].b=1.f;
            vertices[i].a=1.f;
        }
    }
    return NO ;
}
-(BOOL)overWriteTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( hasTouchIn==NO ) return NO ;
    UITouch* touch = [touches anyObject] ;
    if( [self isTouchInSide:touch] )
    {
        //NSLog(@"touch mov inside") ;
        for (int i = 0; i<4; i++) {
            vertices[i].r=vertices[i].g=vertices[i].b=0.25f;
            vertices[i].a=1.f;
        }
    }else
    {
        for (int i = 0; i<4; i++) {
            vertices[i].r=vertices[i].g=vertices[i].b=1.f;
            vertices[i].a=1.f;
        }
    }
    return NO ;
}
-(BOOL)overWriteTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( hasTouchIn==NO ) return NO ;
    hasTouchIn = NO ;
    UITouch* touch = [touches anyObject] ;
    if( [self isTouchInSide:touch] )
    {
        //NSLog(@"touch end inside") ;
        if( tapTarget )
        {
            [tapTarget performSelector:tapAction withObject:self] ;
            for (int i = 0; i<4; i++) {
                vertices[i].r=vertices[i].g=vertices[i].b=1.f;
                vertices[i].a=1.f;
            }
            return YES ;
        }
    }
    for (int i = 0; i<4; i++) {
        vertices[i].r=vertices[i].g=vertices[i].b=1.f;
        vertices[i].a=1.f;
    }
    return NO ;
}
-(BOOL)isTouchInSide:(UITouch*)touch
{
    CGPoint pt = [touch locationInView:nil] ;
    pt.y = 480.f - pt.y ;
    CGPoint ptr = [self centerInRoot] ;
    if( fabsf(pt.x - ptr.x) < [self width]/2.f && fabsf(pt.y-ptr.y) < [self height]/2.f )
        return YES ;
    else return NO ;
}

@end




