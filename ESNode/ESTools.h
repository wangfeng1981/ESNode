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



