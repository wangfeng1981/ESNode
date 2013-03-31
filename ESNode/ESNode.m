//
//  ESNode.m
//  ESNode
//
//  Created by Wang Feng on 13-3-30.
//  Copyright (c) 2013年 jfwf. All rights reserved.
//

#import "ESNode.h"

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
@end





//=============================================================
#pragma mark - ESNode the very beginning.
@implementation ESNode

@end
