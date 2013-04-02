//
//  ESTools.m
//  ESNode
//
//  Created by Wang Feng on 13-3-30.
//  Copyright (c) 2013年 jfwf. All rights reserved.
//

#import "ESTools.h"


unsigned int ccNextPOT(unsigned int x)
{
    x = x - 1;
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >>16);
    return x + 1;
}



//======================================================
#pragma mark - eTexture

@implementation eTexture
@synthesize textureid , fullwidth, fullheight ;

+(eTexture*)createByFilename:(NSString*)filename
{
	eTexture* tex = [[eTexture alloc] initWithFilename:filename] ;
	[tex autorelease] ;
	return tex ;
}

-(id)initWithFilename:(NSString*)filename
{
	self = [super init] ;
	if( self )
	{
		CGImageRef textureImage=NULL;
		CGContextRef textureContext=NULL;
		GLubyte *textureData=NULL;
		GLuint textureID = -1;
		unsigned int width = 0;
		unsigned int height = 0;
        

        UIImage* image = [UIImage imageNamed:filename] ;
        textureImage = image.CGImage ;
        width = CGImageGetWidth(textureImage);
        height = CGImageGetHeight(textureImage);
        fullwidth = width ;
        fullheight = height ;
        width = ccNextPOT(width);
        height = ccNextPOT(height);
        
        textureData = (GLubyte *) malloc(width * height * 4);
        textureContext = CGBitmapContextCreate(textureData, width, height, 8, width * 4, CGImageGetColorSpace(textureImage), kCGImageAlphaPremultipliedLast);
        
        CGContextClearRect(textureContext, CGRectMake(0.0, 0.0, (float)width, (float)height)) ;
        CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)width, (float)height), textureImage);
        
		/*if( esfOpenGLESVersionMajor() == 1 ) //used for ES1.0 20130402
		{
            glMatrixMode(GL_TEXTURE); //comment for ES2.0 20120820
            glLoadIdentity() ;
			glScalef(1, 1, 1);        //comment for ES2.0 20120820
			glEnable(GL_TEXTURE_2D);// comment for ES2.0 20120820
		}*/
		glGenTextures(1, &textureID);
		glBindTexture(GL_TEXTURE_2D, textureID);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE) ;
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE) ;
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
		
        /* used for ES1.0 20130402
        if( esfOpenGLESVersionMajor() == 1 )
		{
			glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE); //comment for ES2.0 20120820
		}*/
		
		free(textureData);
		textureData = NULL ;
		if(textureContext) CGContextRelease(textureContext);
		textureContext = NULL ;
		textureImage = NULL ;
		textureid = textureID ;
	}
	return self ;
}

-(void)dealloc
{
	glDeleteTextures(1, &textureid) ;
    NSLog(@"texture:%d is delete.",textureid) ;
	textureid = 0 ;
	[super dealloc] ;
}
@end


//======================================================
#pragma mark - esTexture
@implementation esTexture
@synthesize etexture ;
-(void)dealloc
{
	ESTOOLS_RELEASE(etexture) ;
	[super dealloc] ;
}

-(id)initByeTexture:(eTexture*)etex
{
    self = [super init] ;
	if( self )
	{
		etexture = [etex retain] ;
		coords8[0]=coords8[1]=0.f;coords8[2]=1.f;coords8[3]=0.f;
		coords8[4]=0.f;coords8[5]=1.f;coords8[6]=coords8[7]=1.f;
	}
	return self ;
}
-(id)initByName:(NSString*)filename
{
    self = [super init] ;
	if( self )
	{
		etexture = [[eTexture alloc] initWithFilename:filename] ;
		coords8[0]=coords8[1]=0.f;coords8[2]=1.f;coords8[3]=0.f;
		coords8[4]=0.f;coords8[5]=1.f;coords8[6]=coords8[7]=1.f;
	}
	return self ;
}
+(esTexture*)createByName:(NSString*)filename
{
    esTexture* t = [[[esTexture alloc] initByName:filename] autorelease] ;
    return t ;
}

-(void)setCoordsByFourCornerX0:(GLfloat)x0 Y0:(GLfloat)y0 X1:(GLfloat)x1 Y1:(GLfloat)y1
{
	coords8[0]=x0;coords8[1]=y0;coords8[2]=x1;coords8[3]=y0;
	coords8[4]=x0;coords8[5]=y1;coords8[6]=x1;coords8[7]=y1;
}

-(GLfloat*)getCoords8
{
    return coords8 ;
}

@end


//======================================================
#pragma mark - esAtlasTexture

#define EATLASTEXTURE_MAXSUBTEX 1024
@implementation esAtlasTexture
@synthesize etexture, numberOfSubtex ;

-(void)dealloc
{
	ESTOOLS_RELEASE(etexture) ;
	if( subtexIdArray )
	{
		free(subtexIdArray) ;
		subtexIdArray = NULL ;
		free(subtexUV01Array) ;
		subtexUV01Array = NULL ;
	}
	numberOfSubtex = 0 ;
	[super dealloc] ;
}

-(id)initWithResName:(NSString*)filenameWithoutExtension // image.png and image.txt!
{
	self = [super init] ;
	if( self )
	{
		// load texture.
		NSString* pngFilename = [NSString stringWithFormat:@"%@.png",filenameWithoutExtension] ;
		etexture = [[eTexture alloc] initWithFilename:pngFilename];
		GLfloat fwid = etexture.fullwidth*1.f ;
		GLfloat fhei = etexture.fullheight*1.f;
		// load subtexture coords.
		NSString* fulltxtPath = [[NSBundle mainBundle] pathForResource:filenameWithoutExtension ofType:@"txt"] ;
		FILE* pf = fopen([fulltxtPath UTF8String], "r") ;
		if( pf )
		{
			numberOfSubtex = 0 ;
			int   tidArr[EATLASTEXTURE_MAXSUBTEX];
			GLfloat tu0Arr[EATLASTEXTURE_MAXSUBTEX*4];
			int   ttid,ttu0,ttv0,ttu1,ttv1 ;
			while (!feof(pf)) {
				fscanf(pf, "%d%*5c%d:%d:%d:%d",&ttid,&ttu0,&ttv0,&ttu1,&ttv1) ;
				tidArr[numberOfSubtex] = ttid ;
				tu0Arr[numberOfSubtex*4+0] = ttu0/fwid ;
				tu0Arr[numberOfSubtex*4+1] = (ttv0+ttv1)/fhei ;//tu0Arr[numberOfSubtex*4+1]+ttv1/fhei ; What a big bug!! Corrected on 2012-04-25.
				tu0Arr[numberOfSubtex*4+2] = tu0Arr[numberOfSubtex*4+0]+ttu1/fwid ;
				tu0Arr[numberOfSubtex*4+3] = ttv0/fhei ;
				numberOfSubtex++ ;
				if( numberOfSubtex == EATLASTEXTURE_MAXSUBTEX )
					break ;
			}
			fclose(pf) ;
			pf = NULL ;
            
			subtexIdArray = (int*)malloc(sizeof(int)*numberOfSubtex) ;
			subtexUV01Array = (GLfloat*)malloc(sizeof(GLfloat)*numberOfSubtex*4) ;
            
			memcpy(subtexIdArray,tidArr,sizeof(int)*numberOfSubtex) ;
			memcpy(subtexUV01Array,tu0Arr,sizeof(GLfloat)*numberOfSubtex*4);
		}else
		{
			printf("error:esAtlasTexture initWithResName Failed to load subtexture coords!\n");
			exit(1) ;
		}
	}
	return self ;
}

+(esAtlasTexture*)create:(NSString*)filenameWithoutExtension
{
	esAtlasTexture* atlas = [[esAtlasTexture alloc] initWithResName:filenameWithoutExtension];
	[atlas autorelease] ;
	return atlas ;
}

-(esTexture*)buildESTextureById:(int)subtexid
{
	int tindex = -1 ;
	for (int i = 0; i<numberOfSubtex; i++) {
		if( subtexIdArray[i] == subtexid )
		{
            tindex = i ;
            break ;
        }
	}
	if( tindex < 0 ) return nil ;
	esTexture* subtex = [[esTexture alloc] initByeTexture:self.etexture] ;
	[subtex autorelease] ;
	[subtex setCoordsByFourCornerX0:subtexUV01Array[tindex*4+0] Y0:subtexUV01Array[tindex*4+1] X1:subtexUV01Array[tindex*4+2] Y1:subtexUV01Array[tindex*4+3] ];
	return subtex ;
}
-(int)getSubidByIndex:(int)index
{
	if( index>=0 && index <self.numberOfSubtex )
		return subtexIdArray[index] ;
    else return -1 ;
}

-(GLfloat*)getCoords8ById:(int)subtexid
{
    GLfloat* c4 = NULL ;
    for (int i = 0 ; i<self.numberOfSubtex ; i++) {
        if( i== subtexid )
        {
            c4 = &(subtexUV01Array[i*4]) ;
            break ;
        }
    }
    if( c4==NULL ) return NULL ;
	coords8[0]=c4[0];coords8[1]=c4[1];
	coords8[2]=c4[2];coords8[3]=c4[1];
	coords8[4]=c4[0];coords8[5]=c4[3];
	coords8[6]=c4[2];coords8[7]=c4[3];
	return coords8 ;
}
@end


//-------- End EAtlasTexture --------------





