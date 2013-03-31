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

//=============================================================
#pragma mark - xxx


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
@end



//=============================================================
#pragma mark - ESNode the very beginning.


@interface ESNode : NSObject {
	int tag ;
	BOOL displayed ;
	BOOL hasRemovedFromParent ;
	
	ESNode* firstChildR ;
	ESNode* nextSiblingR ;
    
	ESNode* prevSiblingA ; //A-Assign ; R-Retain
    ESNode* parentNodeA ;
    
	GLKVector4 center ;
	GLfloat rollDeg,yawDeg,pitchDeg ;
	
    
    
	//checking for update.
	//es2Matrix4 rotTransform,movTransform,modelTransform ;
	BOOL needUpdateTransformMatrix ;
	GLfloat nuRoll,nuYaw,nuPitch ;
	//es2Vector4 nuCenter ;
	//
	
	BOOL timerUse ;
	GLfloat timerSecondCount ;
	GLfloat timerSecondInCircle ;
	id timerTarget ;
	SEL timerAction ;
}
@property(assign,nonatomic)GLfloat rollDeg,yawDeg,pitchDeg ;
//@property(assign,nonatomic)es2Vector4 center ;
@property(assign,nonatomic)BOOL displayed;
@property(readonly,nonatomic)BOOL hasRemovedFromParent;
@property(assign,nonatomic)int tag ;
@property(assign,nonatomic)ESNode* parentNode ;
@property(retain,nonatomic)ESNode* firstChild ;
@property(retain,nonatomic)ESNode* nextSibling ;
@property(assign,nonatomic)ESNode* prevSibling ;

-(id)initWithTag:(int)tag1 ;
-(BOOL)addChild:(ESNode*)node ;
-(BOOL)insertChild:(ESNode*)node afterNode:(ESNode*)anode ;
-(BOOL)insertChild:(ESNode *)node beforeNode:(ESNode*)bnode ;
-(BOOL)removeChild:(ESNode*)node ;
-(ESNode*)locateChildByTag:(int)tag1 ;
-(void)removeFromParent ;
-(void)update:(GLfloat)timeinter ;
-(void)updateMeAndChildren:(GLfloat)timeinter ;
-(void)draw ;
-(void)drawMeAndChildren ;
-(void)satTimer:(GLfloat)dura withTarget:(id)tar andAction:(SEL)act ;
-(int)numberOfChildren ;
//-(es2Matrix4*)gatTransformMatrix ;
//-(void)copyTransformMatrix:(es2Matrix4*)mat4 ;
-(void)updateModelTransformMatrix ;
@end
