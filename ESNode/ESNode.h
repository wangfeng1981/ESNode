//
//  ESNode.h
//  ESNode
//
//  Created by Wang Feng on 13-3-30.
//  Copyright (c) 2013年 jfwf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <GLKit/GLKMath.h>
#import "ESTools.h"

//=============================================================
#pragma mark - xxx


//=============================================================
#pragma mark - structures
union esVertexP3C4
{
    struct { float x, y, z, r, g, b, a ; };
    GLfloat v[7];
};
typedef union esVertexP3C4 esVertexP3C4;
union esVertexP3C4T2
{
    struct { float x, y, z, r, g, b, a,s,t ; };
    GLfloat v[9];
};
typedef union esVertexP3C4T2 esVertexP3C4T2;








//=============================================================
#pragma mark - ESNode the very beginning.
#define ESNODE_TIMER_INFINITE_CIRCLE -5
enum ESNodeUserInteractionType
{ 
    ESNodeUserInteractionNone,
    ESNodeUserInteractionSelfOnly,
    ESNodeUserInteractionChildrenOnly,
    ESNodeUserInteractionSelfAndChildren
};
typedef enum ESNodeUserInteractionType ESNodeUserInteractionType;
#define ESNODE_TIMER_NONE 0
#define ESNODE_TIMER_GOING 1
#define ESNODE_TIMER_PAUSE 2

@interface ESNode : NSObject {
	int tag ;
	BOOL displayed ;
	BOOL hasRemovedFromParent ;
    ESNodeUserInteractionType  userInteraction ;
	
    //relations properties A-Assign ; R-Retain
	ESNode* firstChildR ;
	ESNode* nextSiblingR ;
	ESNode* prevSiblingA ; 
    ESNode* parentNodeA ;
    
    //position,rotation,scaling properties
	GLKVector4 center  ;
	GLfloat rollDeg,yawDeg,pitchDeg  ;
    GLfloat xScale , yScale , zScale;
    GLfloat alpha ;
	    
	//Matrixs
	GLKMatrix4 rotMatrix,movMatrix,sclMatrix,
                modMatrix,transformMatrix ;
    //checking for update.
	BOOL needUpdateMatrix[4] ;//0 mov, 1 rot , 2 scl , 3 parent
	
    //Timer
    int     timerState ;
	GLfloat timerDuration ;
    int     timerCircles ; // ESNODE_TIMER_INFINITE_CIRCLE
	GLfloat timerSeconds ;
	id timerTarget ;
	SEL timerAction ;
    
    //esAnimation
    GLfloat animDuration ;
    esAnimation* animation ;
    id      animTarget ;
    SEL     animBeforeAction ;
    SEL     animAfterAction ;
    BOOL    animPaused ;
}

@property(assign,nonatomic)int tag ;
@property(assign,nonatomic)BOOL displayed;
@property(readonly,nonatomic)BOOL hasRemovedFromParent;
@property(assign,nonatomic)ESNodeUserInteractionType userInteraction ;

@property(assign,nonatomic)GLKVector4 center ;
@property(assign,nonatomic)GLfloat rollDeg,yawDeg,pitchDeg ;
@property(assign,nonatomic)GLfloat xScale,yScale,zScale ;
@property(assign,nonatomic)GLfloat alpha ;

@property(retain,nonatomic)ESNode* firstChildR ;
@property(retain,nonatomic)ESNode* nextSiblingR ;
@property(assign,nonatomic)ESNode* parentNodeA ;
@property(assign,nonatomic)ESNode* prevSiblingA ;

@property(readonly,nonatomic)int timerState ;
@property(readonly,nonatomic)int timerCircles ;

@property(assign,nonatomic)BOOL animPaused ;

-(id)initWithTag:(int)tag1 ;
//nodes
-(void)addChild:(ESNode*)node ;
-(void)insertChild:(ESNode*)node afterNode:(ESNode*)anode ;
-(void)insertChild:(ESNode *)node beforeNode:(ESNode*)bnode ;
-(BOOL)removeChild:(ESNode*)node ;
-(ESNode*)locateChildByTag:(int)tag1 ;
-(void)removeFromParent ;
//update and draw
-(void)update:(GLfloat)timeinter ;
-(void)updateMeAndChildren:(GLfloat)timeinter ;
-(void)draw ;
-(void)drawMeAndChildren ;
-(void)updateTransformMatrix ;
-(void)satTimerDuration:(GLfloat)dura1circ circles:(int)ncirc target:(id)tar action:(SEL)act ;
-(GLKMatrix4*)gatTransformMatrix ;
-(BOOL)isTransformMatrixChanged ;
-(void)satTransformMatrix:(GLKMatrix4)mat4 ;
//timer
-(void)deleteTimer ;
-(void)pauseTimer ;
-(void)resumeTimer ;
//animation
-(void)satAnim:(esAnimation*)anim target:(id)tar beforeAnimStartAction:(SEL)befAction afterAnimEndAction:(SEL)aftAction start:(GLfloat)start;


//UserInteraction 返回YES不再传递Event,返回NO继续传递event.
-(BOOL)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(BOOL)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(BOOL)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
//for Overwrite.
-(BOOL)overWriteTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(BOOL)overWriteTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(BOOL)overWriteTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
//center location
-(CGPoint)centerInRoot ;

@end


//=============================================================
#pragma mark - ESRoot what we started.

enum ESRootDeviceType
{
    ESRootDeviceTypeIPhone,
    ESRootDeviceTypeIPhone5,
    ESRootDeviceTypeIPad,
    ESRootDeviceTypeUnknow 
};
typedef enum ESRootDeviceType ESRootDeviceType ;

@interface ESRoot : ESNode
{
    GLKVector4 lookTarget ;
    GLKVector4 eyePosition ;
	
	GLfloat    znear,zfar ;
    GLfloat        widthpixel,heightpixel ;
    BOOL       screenLandscape ;
    BOOL       isRetina ;
    ESRootDeviceType deviceType ;
	//Use rotMatrix as ProjectionMatrix, use movMatrix as LookatMatrix.
    
    //Shaders
    esProgram* _program3d ;
    esProgram* _program2d ;
    
    //Ortho root
    ESNode* orthoRoot ;
}
@property(assign,nonatomic)GLKVector4 lookTarget ;
@property(assign,nonatomic)GLKVector4 eyePosition ;
@property(readonly,nonatomic)GLfloat widthpixel ;
@property(readonly,nonatomic)GLfloat heightpixel ;
@property(readonly,nonatomic)BOOL screenLandscape ;
@property(readonly,nonatomic)ESRootDeviceType deviceType ;
@property(readonly,nonatomic)BOOL       isRetina ;
@property(readonly,nonatomic)esProgram* _program3d ;
@property(readonly,nonatomic)esProgram* _program2d ;
@property(readonly,nonatomic)ESNode* orthoRoot ;

+(ESRoot*)currentRoot ;
-(id)initWithTag:(int)tag1 andEyePosi:(GLKVector4)veye andTarPosi:(GLKVector4)vtar andNear:(GLfloat)n andFar:(GLfloat)f
screenLandscape:(BOOL)landscape ;


@end

//=============================================================
#pragma mark - ES3dCube
@interface ES3dCube:ESNode
{
    esVertexP3C4 vertices[24] ;
}
-(id)initWithTag:(int)tag1 andSize:(GLfloat)sz singleColor:(GLKVector4)color1 ;
-(id)initWithTag:(int)tag1 andSize:(GLfloat)sz colors:(GLKVector4*)color24 ;

@end

//=============================================================
#pragma mark - ESSimpleSprite
enum ESSimpleSpriteFlipType{
    ESSimpleSpriteFlipTypeLeftRight ,
    ESSimpleSpriteFlipTypeRightLeft 
};
typedef enum ESSimpleSpriteFlipType ESSimpleSpriteFlipType;
@interface ESSimpleSprite:ESNode
{
    esVertexP3C4T2 vertices[4] ;
    esTexture* estexture ;
    ESSimpleSpriteFlipType flipType ;
}
@property(retain,nonatomic)esTexture* estexture ;
-(id)initWithTag:(int)tag1 frame:(CGRect)frm texture:(esTexture*)estexture1 ;
-(GLfloat)width ;
-(GLfloat)height ;
-(void)flip:(ESSimpleSpriteFlipType)ft ;

@end

//=============================================================
#pragma mark - ESSimpleButton
@interface ESSimpleButton:ESSimpleSprite
{
    id tapTarget ;
    SEL tapAction ;
    BOOL hasTouchIn ;
    id touchEventTarget ;
    SEL touchBeginAction ;
    SEL touchMoveAction ;
    SEL touchEndAction ;
}
-(id)initWithTag:(int)tag1 frame:(CGRect)frm texture:(esTexture*)estexture1 target:(id)tar action:(SEL)act ;
-(BOOL)isTouchInSide:(UITouch*)touch ;
-(void)setTouchEventTarget:(id)tar begin:(SEL)bact move:(SEL)mact end:(SEL)eact ;
@end

//=============================================================
#pragma mark - eAnimationSprites
enum eAnimationSpritesQuadAlign
{
    eAnimationSpritesQuadAlignTopLeft ,
    eAnimationSpritesQuadAlignTopCenter ,
    eAnimationSpritesQuadAlignTopRight ,
    eAnimationSpritesQuadAlignMidLeft ,
    eAnimationSpritesQuadAlignMidCenter ,
    eAnimationSpritesQuadAlignMidRight ,
    eAnimationSpritesQuadAlignBottomLeft ,
    eAnimationSpritesQuadAlignBottomCenter ,
    eAnimationSpritesQuadAlignBottomRight 
};
typedef enum eAnimationSpritesQuadAlign eAnimationSpritesQuadAlign ;

@interface eAnimationSprites:NSObject
{
	eTexture* etexture ;
	GLfloat* coords8Array ;
    GLfloat* coordsWidth ;
    GLfloat* coordsHeight ;
    GLfloat  maxWidth ;
    GLfloat  maxHeight ;
    
    int numberOfFrames ;
    int currentFrameIndex ;
    eAnimationSpritesQuadAlign align ;
    
    esVertexP3C4T2 vertices[4] ;
}
@property(readonly,nonatomic) eTexture* etexture ;
@property(readonly,nonatomic)eAnimationSpritesQuadAlign align ;
@property(readonly,nonatomic) int currentFrameIndex ;
@property(readonly,nonatomic) int numberOfFrames ;

-(id)initWithAtlas:(esAtlasTexture*)atlas numOfFrames:(int)nof frameIdArray:(int*)fidArr align:(eAnimationSpritesQuadAlign)align1 ;
-(esVertexP3C4T2*)getQuadVertices ;
-(void)update:(GLfloat)currenttime frameinterval:(GLfloat)frameinter maxwidth:(GLfloat)maxwid maxheight:(GLfloat)maxhei ;
@end


//=============================================================
#pragma mark - ESAnimationSprites
@interface ESAnimationSprites : ESNode
{
	eAnimationSprites* eanimSprites ;
	GLfloat eanimCurrentTime ;
	GLfloat eanimFrameInterval;
    GLfloat eanimCircleTime ;
	BOOL     eanimPaused ;
	BOOL     eanimLooped ;
    int      eanimStopFrame ;
	//..
	id eanimEndTarget ;
	SEL eanimEndAction ;
    //..
    GLfloat spriteMaxWidth , spriteMaxHeight ;
	
}
@property(assign,nonatomic) GLfloat eanimFrameInterval ;
@property(assign,nonatomic) BOOL eanimPaused ;

-(id)initWithTag:(int)tag1 frame:(CGRect)frm eAnimSprites:(eAnimationSprites*)eas frameinter:(GLfloat)fi ;
-(void)playToEnd:(id)tar action:(SEL)act ;
-(void)playFrom:(int)ifrm0 to:(int)ifrm1 target:(id)tar action:(SEL)act ;
-(void)playLoop ;
@end

//=============================================================
#pragma mark - ESTileMap
@interface ESTileMap:ESNode
{
    short tileWidthNumber , tileHeightNumber ;
    short tileCellWidth , tileCellHeight ;
    int validCellNumber ;
    esVertexP3C4T2* vertices ;
    GLushort*       indices ;
    short* tileData ;
    esAtlasTexture* tileAtlas ;
}
@property(readonly,nonatomic)short tileWidthNumber,tileHeightNumber ;
@property(readonly,nonatomic)short tileCellWidth,tileCellHeight ;

-(id)initWithTag:(int)tag1 resfile:(NSString*)resfile ;//xxx.png xxx.txt xxx.json
-(short)cellDatax:(int)ix y:(int)iy ;
-(short*)gatTileData ;
@end





