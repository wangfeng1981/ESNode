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
#pragma mark - GL program and shader

@interface esProgram : NSObject
{
	NSString* fshFilename ;
	NSString* vshFilename ;
	NSArray*  attrNameArray ;
	NSArray*  unifNameArray ;
	GLuint iprogram ;
	
	GLint unifLocation[8] ;
	short numUniform ;
	
}
@property(readonly,nonatomic)GLuint iprogram ;
// fshfilename and vshfilename are none have extname.
-(id)initWithVsh:(NSString*)vshfilename andFsh:(NSString*)fshfilename andAttrnameArray:(NSArray*)attrArr andUnifnameArray:(NSArray*)unifArr;
-(id)initWithVshString:(const GLchar*)vstring andFshString:(const GLchar*)fstring andAttrnameArray:(NSArray*)attrArr andUnifnameArray:(NSArray*)unifArr ;

-(BOOL)compileShader:(GLuint*)ish type:(GLenum)type text:(const GLchar*)carr ;
-(BOOL)compileShader:(GLuint*)ish type:(GLenum)type file:(NSString*)file ;
-(BOOL)linkProgram ;
-(void)useProgram ;
//-(void)updateUniform:(short)iu byMat4:(es2Matrix4*)m ;
-(void)updateAttribute:(GLuint)index size:(GLint)sz type:(GLenum)t normalize:(GLboolean)n stride:(GLsizei)stride1 pointer:(GLvoid*)ptr ;
-(GLint)uniformLocation:(int)index ;
-(void)updateUniform:(short)iu byMat4:(GLKMatrix4*)mat4 ;
-(void)bindTexture0ByTextureId:(GLuint)texid uniformIndex:(short)iu ;
@end



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
}

@property(assign,nonatomic)int tag ;
@property(assign,nonatomic)BOOL displayed;
@property(readonly,nonatomic)BOOL hasRemovedFromParent;
@property(assign,nonatomic)ESNodeUserInteractionType userInteraction ;

@property(assign,nonatomic)GLKVector4 center ;
@property(assign,nonatomic)GLfloat rollDeg,yawDeg,pitchDeg ;
@property(assign,nonatomic)GLfloat xScale,yScale,zScale ;

@property(retain,nonatomic)ESNode* firstChildR ;
@property(retain,nonatomic)ESNode* nextSiblingR ;
@property(assign,nonatomic)ESNode* parentNodeA ;
@property(assign,nonatomic)ESNode* prevSiblingA ;

@property(readonly,nonatomic)int timerState ;
@property(readonly,nonatomic)int timerCircles ;

-(id)initWithTag:(int)tag1 ;
-(void)addChild:(ESNode*)node ;
-(void)insertChild:(ESNode*)node afterNode:(ESNode*)anode ;
-(void)insertChild:(ESNode *)node beforeNode:(ESNode*)bnode ;
-(BOOL)removeChild:(ESNode*)node ;
-(ESNode*)locateChildByTag:(int)tag1 ;
-(void)removeFromParent ;
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

//UserInteraction 返回YES不再传递Event,返回NO继续传递event.
-(BOOL)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(BOOL)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(BOOL)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
//for Overwrite.
-(BOOL)overWriteTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(BOOL)overWriteTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(BOOL)overWriteTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

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
@interface ESSimpleSprite:ESNode
{
    esVertexP3C4T2 vertices[4] ;
    esTexture* estexture ;
}
@property(retain,nonatomic)esTexture* estexture ;
-(id)initWithTag:(int)tag1 frame:(CGRect)frm texture:(esTexture*)estexture1 ;
@end








