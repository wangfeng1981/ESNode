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


//=============================================================
#pragma mark - GL program and shader

@implementation esProgram
@synthesize iprogram ;
-(void)dealloc
{
	if( iprogram )
	{
		glDeleteProgram(iprogram) ;
		iprogram = 0 ;
	}
	if( attrNameArray )
	{
		[attrNameArray release] ;
		attrNameArray =nil ;
	}
	if( unifNameArray )
	{
		[unifNameArray release] ;
		unifNameArray = nil ;
	}
	[super dealloc] ;
}

// fshfilename and vshfilename are none have extname.
-(id)initWithVsh:(NSString*)vshfilename andFsh:(NSString*)fshfilename andAttrnameArray:(NSArray*)attrArr andUnifnameArray:(NSArray*)unifArr
{
	self = [super init] ;
	if( self )
	{
		iprogram = glCreateProgram() ;
		NSString* vfullname = [[NSBundle mainBundle] pathForResource:vshfilename ofType:@"vsh"] ;
		NSString* ffullname = [[NSBundle mainBundle] pathForResource:fshfilename ofType:@"fsh"] ;
		GLuint ivsh,ifsh ;
		if( [self compileShader:&ivsh type:GL_VERTEX_SHADER file:vfullname] )
		{
			if( [self compileShader:&ifsh type:GL_FRAGMENT_SHADER file:ffullname] )
			{
				glAttachShader(iprogram, ivsh) ;
				glAttachShader(iprogram, ifsh) ;
				
				attrNameArray = [attrArr retain] ;
				unifNameArray = [unifArr retain] ;
				
				for (GLuint i = 0 ; i<[attrNameArray count]; i++) {
					glBindAttribLocation(iprogram, i, [(NSString*)[attrNameArray objectAtIndex:i] UTF8String] ) ;
				}
				
				//link program.
				if( [self linkProgram] )
				{
					numUniform   = MIN(8,[unifNameArray count]) ;
					for (GLint i = 0 ; i<numUniform ; i++) {
						unifLocation[i] = glGetUniformLocation(iprogram,[(NSString*)[unifNameArray objectAtIndex:i] UTF8String]) ;
					}
				}else
				{
					if( iprogram )
					{
						glDeleteProgram(iprogram) ;
						iprogram = 0 ;
                        NSLog(@"link program failed.");
					}
				}
				if( ivsh )
					glDeleteShader(ivsh) ;
				if( ifsh )
					glDeleteShader(ifsh) ;
			}else {
				NSLog(@"Failed compile frag shader:%@",ffullname) ;
			}
		}else {
			NSLog(@"Failed compile vert shader:%@",vfullname) ;
		}
	}
	return self ;
}

-(id)initWithVshString:(const GLchar*)vstring andFshString:(const GLchar*)fstring andAttrnameArray:(NSArray*)attrArr andUnifnameArray:(NSArray*)unifArr
{
	self = [super init] ;
	if( self )
	{
		iprogram = glCreateProgram() ;
		GLuint ivsh,ifsh ;
		if( [self compileShader:&ivsh type:GL_VERTEX_SHADER text:vstring] )
		{
			if( [self compileShader:&ifsh type:GL_FRAGMENT_SHADER text:fstring] )
			{
				glAttachShader(iprogram, ivsh) ;
				glAttachShader(iprogram, ifsh) ;
				
				attrNameArray = [attrArr retain] ;
				unifNameArray = [unifArr retain] ;
				
				for (GLuint i = 0 ; i<[attrNameArray count]; i++) {
					glBindAttribLocation(iprogram, i, [(NSString*)[attrNameArray objectAtIndex:i] UTF8String] ) ;
				}
				
				//link program.
				if( [self linkProgram] )
				{
					numUniform   = MIN(8,[unifNameArray count]) ;
					for (GLint i = 0 ; i<numUniform ; i++) {
						unifLocation[i] = glGetUniformLocation(iprogram,[(NSString*)[unifNameArray objectAtIndex:i] UTF8String]) ;
					}
				}else
				{
					if( iprogram )
					{
						glDeleteProgram(iprogram) ;
						iprogram = 0 ;
                        NSLog(@"link program failed.");
					}
				}
				if( ivsh )
					glDeleteShader(ivsh) ;
				if( ifsh )
					glDeleteShader(ifsh) ;
			}else {
				NSLog(@"Failed compile frag shader:%@",@"file in memory.") ;
			}
		}else {
			NSLog(@"Failed compile vert shader:%@",@"file in memory.") ;
		}
	}
	return self ;
}
-(BOOL)compileShader:(GLuint*)ish type:(GLenum)type text:(const GLchar*)carr
{
	const GLchar* source= carr ;
	if( source==NULL )
	{
		NSLog(@"Failed to load shader file:%@.",@"file in memory.") ;
		return NO ;
	}
	*ish = glCreateShader(type) ;
	glShaderSource(*ish, 1, &source, NULL) ;
	glCompileShader(*ish) ;
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*ish, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*ish, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
	GLint status  ;
	glGetShaderiv(*ish, GL_COMPILE_STATUS, &status) ;
	if( status==0 )
	{
		glDeleteShader(*ish) ;
		NSLog(@"Failed to compile shader:%@.",@"file in memory.") ;
		return NO ;
	}
	return YES ;
}
-(BOOL)compileShader:(GLuint*)ish type:(GLenum)type file:(NSString*)file
{
	return [self compileShader:ish type:type text:(GLchar*)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String]] ;
}
-(BOOL)linkProgram
{
	GLint status ;
	glLinkProgram(iprogram) ;
	glGetProgramiv(iprogram, GL_LINK_STATUS, &status) ;
	if( status==0 )
	{
		NSLog(@"Failed to Link Program.") ;
		return NO ;
	}
	return YES ;
}
-(void)useProgram
{
	glUseProgram(iprogram);
}
//-(void)updateUniform:(short)iu byMat4:(es2Matrix4*)m
//{
//	glUniformMatrix4fv(unifLocation[iu], 1, GL_FALSE, m->mat) ;
//}
-(void)updateAttribute:(GLuint)index size:(GLint)sz type:(GLenum)t normalize:(GLboolean)n stride:(GLsizei)stride1 pointer:(GLvoid*)ptr
{
	glEnableVertexAttribArray(index) ;
	glVertexAttribPointer(index, sz, t, n, stride1, ptr) ;
}
-(GLint)uniformLocation:(int)index
{
	return unifLocation[index] ;
}
-(void)updateUniform:(short)iu byMat4:(GLKMatrix4*)mat4
{
	glUniformMatrix4fv(unifLocation[iu], 1, GL_FALSE, mat4->m) ;
}
-(void)bindTexture0ByTextureId:(GLuint)texid uniformIndex:(short)iu
{
    glActiveTexture(GL_TEXTURE0) ;
    glBindTexture(GL_TEXTURE_2D, texid) ;
    glUniform1i([self uniformLocation:iu], 0) ;
}
@end

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
				fscanf(pf, "%d%*5c%d:%d:%d:%d\n",&ttid,&ttu0,&ttv0,&ttu1,&ttv1) ;
				tidArr[numberOfSubtex] = ttid ;
				tu0Arr[numberOfSubtex*4+0] = ttu0/fwid ;
				tu0Arr[numberOfSubtex*4+1] = (ttv0+ttv1)/fhei ;//tu0Arr[numberOfSubtex*4+1]+ttv1/fhei ; What a big bug!! Corrected on 2012-04-25.
				tu0Arr[numberOfSubtex*4+2] = tu0Arr[numberOfSubtex*4+0]+ttu1/fwid ;
				tu0Arr[numberOfSubtex*4+3] = ttv0/fhei ;
				numberOfSubtex++ ;
				if( numberOfSubtex == EATLASTEXTURE_MAXSUBTEX )
					break ;
                //if( ieof2==-1 ) break ;
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


//======================================================
#pragma mark - esAnimKeyFrame
@implementation esAnimKeyFrame
@synthesize x1,y1,z1,xs1,ys1,zs1,alpha1,roll1,yaw1,pitch1,duration;
-(id)initx:(GLfloat)x y:(GLfloat)y z:(GLfloat)z xs:(GLfloat)xs ys:(GLfloat)ys zs:(GLfloat)zs alpha:(GLfloat)alpha roll:(GLfloat)roll yaw:(GLfloat)yaw pitch:(GLfloat)pitch duration:(CFTimeInterval)dura
{
    self = [super init] ;
    if( self )
    {
        x1 = x ; y1 = y ; z1 = z ; xs1 = xs ; ys1 = ys ; zs1 = zs ; alpha1 = alpha ; roll1 = roll ;yaw1 = yaw ; pitch1 = pitch ; duration =dura ;
    }
    return self ;
}
+(esAnimKeyFrame*)createx:(GLfloat)x y:(GLfloat)y z:(GLfloat)z xs:(GLfloat)xs ys:(GLfloat)ys zs:(GLfloat)zs alpha:(GLfloat)alpha roll:(GLfloat)roll yaw:(GLfloat)yaw pitch:(GLfloat)pitch duration:(CFTimeInterval)dura
{
    return [[[esAnimKeyFrame alloc] initx:x y:y z:z xs:xs ys:ys zs:zs alpha:alpha roll:roll yaw:yaw pitch:pitch duration:dura] autorelease] ;
}
@end

//======================================================
#pragma mark - esAnimation
@implementation esAnimation
@synthesize x,y,z,xs,ys,zs,alpha,roll,yaw,pitch ;
@synthesize keysArray ;
-(void)dealloc
{
    ESTOOLS_RELEASE(keysArray) ;
    [super dealloc] ;
}
-(id)init
{
    self = [super init] ;
    if( self )
    {
        keysArray = [[NSMutableArray alloc] init] ;
    }
    return self ;
}
-(void)update:(GLfloat)dura finished:(BOOL*)isFinished
{
    *isFinished = YES ;
    NSEnumerator* e = [keysArray objectEnumerator] ;
    CFTimeInterval time0 = 0.0 ;
    CFTimeInterval time1 = 0.0 ;
    esAnimKeyFrame* key = (esAnimKeyFrame*)[e nextObject] ;
    esAnimKeyFrame* lastkey = key; 
    while (key = (esAnimKeyFrame*)[e nextObject]) {
        time1 +=key.duration ;
        if( dura < time1 )
        {
            *isFinished = NO ;
            [self interptx:dura time0:time0 time1:time1 key0:lastkey key1:key] ;
            return ;
        }
        lastkey = key ;
        time0 = time1 ;
    }
    x = lastkey.x1 ;
    y = lastkey.y1 ;
    z = lastkey.z1 ;
    xs = lastkey.xs1 ;
    ys = lastkey.ys1 ;
    zs = lastkey.zs1 ;
    alpha = lastkey.alpha1 ;
    roll = lastkey.roll1 ;
    yaw = lastkey.yaw1 ;
    pitch = lastkey.pitch1 ;
}
//private
-(void)interptx:(GLfloat)dt time0:(GLfloat)t0 time1:(GLfloat)t1 key0:(esAnimKeyFrame*)key0 key1:(esAnimKeyFrame*)key1
{
    GLfloat k = 1.f ;
    if( t1-t0 > 0.001f )
        k = (dt - t0)/(t1-t0) ;
    x = key0.x1 + k*( key1.x1 - key0.x1 ) ;
    y = key0.y1 + k*( key1.y1 - key0.y1 ) ;
    z = key0.z1 + k*( key1.z1 - key0.z1 ) ;
    xs = key0.xs1 + k*( key1.xs1 - key0.xs1 ) ;
    ys = key0.ys1 + k*( key1.ys1 - key0.ys1 ) ;
    zs = key0.zs1 + k*( key1.zs1 - key0.zs1 ) ;
    alpha = key0.alpha1+ k*(key1.alpha1 - key0.alpha1) ;
    roll = key0.roll1 + k*(key1.roll1 - key0.roll1) ;
    yaw = key0.yaw1 + k*(key1.yaw1 - key0.yaw1) ;
    pitch = key0.pitch1+ k*(key1.pitch1 - key0.pitch1) ;
    
}
@end 





