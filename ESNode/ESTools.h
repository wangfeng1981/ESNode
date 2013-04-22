//
//  ESTools.h
//  ESNode
//
//  Created by Wang Feng on 13-3-30.
//  Copyright (c) 2013年 jfwf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


#define ESTOOLS_RELEASE(p) if(p){[p release];p=nil;}
int esfDict2int(NSDictionary* dict,NSString* key) ;
NSString* esfDict2String(NSDictionary* dict,NSString* key) ;
int esfArray2int(NSArray* array,int index) ;
NSString* esfArray2String(NSArray* array,int index) ;

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


//======================================================
#pragma mark - eTexture
@interface eTexture : NSObject
{
	GLuint textureid ;
	int fullwidth ;
	int fullheight ;
}
@property(readonly,nonatomic) GLuint textureid ;
@property(readonly,nonatomic) int fullwidth ;
@property(readonly,nonatomic) int fullheight ;
+(eTexture*)createByFilename:(NSString*)filename ;
-(id)initWithFilename:(NSString*)filename ;

@end


//======================================================
#pragma mark - esTexture
@interface esTexture : NSObject {
	eTexture* etexture ;
	GLfloat coords8[8] ;
}
@property(readonly,nonatomic) eTexture* etexture ;
-(void)setCoordsByFourCornerX0:(GLfloat)x0 Y0:(GLfloat)y0 X1:(GLfloat)x1 Y1:(GLfloat)y1 ;
-(void)setCoordsByC8:(GLfloat*)c8;
-(GLfloat*)getCoords8 ;
-(id)initByName:(NSString*)filename ;
-(id)initByeTexture:(eTexture*)etex ;
+(esTexture*)createByName:(NSString*)filename ;

@end

//======================================================
#pragma mark - esAtlasTexture
@interface esAtlasTexture : NSObject
{
	eTexture* etexture ;
	int       numberOfSubtex ;
	int*      subtexIdArray ;
	GLfloat*    subtexUV01Array ;
	GLfloat     coords8[8] ;
}
/* the filename inside image.txt must be XXXX.png (X is only number.)
 e.g.
 0100.png ok;
 1199.png ok;
 11187.png / 11.png bad (five number / two number);
 a101.png bad (have character).
 */
@property(readonly,nonatomic) int numberOfSubtex ;
@property(readonly,nonatomic) eTexture* etexture ;
-(id)initWithResName:(NSString*)filenameWithoutExtension ;// image.png and image.txt!
+(esAtlasTexture*)create:(NSString*)filenameWithoutExtension ;
-(esTexture*)buildESTextureById:(int)subtexid ;
-(GLfloat*)getCoords8ById:(int)subtexid ;
-(int)getSubidByIndex:(int)index ;
@end

//======================================================
#pragma mark - esAnimKeyFrame
@interface esAnimKeyFrame : NSObject
{
	GLfloat x1,y1,z1,xs1,ys1,zs1,alpha1,roll1,yaw1,pitch1 ;
	CFTimeInterval duration ;
}
@property(readonly,nonatomic) GLfloat x1,y1,z1,xs1,ys1,zs1,alpha1,roll1,yaw1,pitch1 ;
@property(readonly,nonatomic) CFTimeInterval duration ;
-(id)initx:(GLfloat)x y:(GLfloat)y z:(GLfloat)z xs:(GLfloat)xs ys:(GLfloat)ys zs:(GLfloat)zs alpha:(GLfloat)alpha roll:(GLfloat)roll yaw:(GLfloat)yaw pitch:(GLfloat)pitch duration:(CFTimeInterval)dura ;
+(esAnimKeyFrame*)createx:(GLfloat)x y:(GLfloat)y z:(GLfloat)z xs:(GLfloat)xs ys:(GLfloat)ys zs:(GLfloat)zs alpha:(GLfloat)alpha roll:(GLfloat)roll yaw:(GLfloat)yaw pitch:(GLfloat)pitch duration:(CFTimeInterval)dura ;

@end


//======================================================
#pragma mark - esAnimation
@interface esAnimation : NSObject
{
	NSMutableArray* keysArray ;//the first keyframe's duration is ignored! keysArray must have 2 keyframes at least!
    GLfloat x,y,z,xs,ys,zs,alpha,roll,yaw,pitch ;
}
@property(readonly,nonatomic) GLfloat x,y,z,xs,ys,zs,alpha,roll,yaw,pitch ;
@property(readonly,nonatomic) NSMutableArray* keysArray ;
-(id)init ;
-(void)update:(GLfloat)dura finished:(BOOL*)isFinished ;
//private
-(void)interptx:(GLfloat)dt time0:(GLfloat)t0 time1:(GLfloat)t1 key0:(esAnimKeyFrame*)key0 key1:(esAnimKeyFrame*)key1 ;
@end



