#import "GPUImageView.h"
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/QuartzCore.h>
#import "GPUImageOpenGLESContext.h"
#import "GPUImageFilter.h"
#import <AVFoundation/AVFoundation.h>

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

NSString *const kGPUImageDisplayFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
);

#pragma mark -
#pragma mark Private methods and instance variables

@interface GPUImageView () 
{
    GLuint inputTextureForDisplay;
    GLint backingWidth, backingHeight;
    GLuint displayRenderbuffer, displayFramebuffer;
    
    GLProgram *displayProgram;
    GLint displayPositionAttribute, displayTextureCoordinateAttribute;
    GLint displayInputTextureUniform;
    
    CGSize inputImageSize;
    GLfloat imageVertices[8];
}

// Initialization and teardown
- (void)commonInit;

// Managing the display FBOs
- (void)createDisplayFramebuffer;
- (void)destroyDisplayFramebuffer;

@end

@implementation GPUImageView

#pragma mark -
#pragma mark Initialization and teardown

+ (Class)layerClass 
{
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
    {
		return nil;
    }
    
    [self commonInit];
    
    return self;
}

-(id)initWithCoder:(NSCoder *)coder
{
	if (!(self = [super initWithCoder:coder])) 
    {
        return nil;
	}

    [self commonInit];

	return self;
}

- (void)commonInit;
{
    // Set scaling to account for Retina display	
    if ([self respondsToSelector:@selector(setContentScaleFactor:)])
    {
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
    }

    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;    
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];		

    [GPUImageOpenGLESContext useImageProcessingContext];
    displayProgram = [[GLProgram alloc] initWithVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImageDisplayFragmentShaderString];

    [displayProgram addAttribute:@"position"];
	[displayProgram addAttribute:@"inputTextureCoordinate"];
    
    if (![displayProgram link])
	{
		NSString *progLog = [displayProgram programLog];
		NSLog(@"Program link log: %@", progLog); 
		NSString *fragLog = [displayProgram fragmentShaderLog];
		NSLog(@"Fragment shader compile log: %@", fragLog);
		NSString *vertLog = [displayProgram vertexShaderLog];
		NSLog(@"Vertex shader compile log: %@", vertLog);
		displayProgram = nil;
        NSAssert(NO, @"Filter shader link failed");
	}
    
    displayPositionAttribute = [displayProgram attributeIndex:@"position"];
    displayTextureCoordinateAttribute = [displayProgram attributeIndex:@"inputTextureCoordinate"];
    displayInputTextureUniform = [displayProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputTexture" for the fragment shader
    
    [displayProgram use];    
	glEnableVertexAttribArray(displayPositionAttribute);
	glEnableVertexAttribArray(displayTextureCoordinateAttribute);


}

- (void)dealloc
{
    [self destroyDisplayFramebuffer];
}

#pragma mark -
#pragma mark Managing the display FBOs

- (void)createDisplayFramebuffer;
{
	glGenFramebuffers(1, &displayFramebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
	
	glGenRenderbuffers(1, &displayRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
	
	[[[GPUImageOpenGLESContext sharedImageProcessingOpenGLESContext] context] renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
	
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
//	NSLog(@"Backing width: %d, height: %d", backingWidth, backingHeight);

	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, displayRenderbuffer);
	
    GLuint framebufferCreationStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(framebufferCreationStatus == GL_FRAMEBUFFER_COMPLETE, @"Failure with display framebuffer generation");
}

- (void)destroyDisplayFramebuffer;
{
    if (displayFramebuffer)
	{
		glDeleteFramebuffers(1, &displayFramebuffer);
		displayFramebuffer = 0;
	}
	
	if (displayRenderbuffer)
	{
		glDeleteRenderbuffers(1, &displayRenderbuffer);
		displayRenderbuffer = 0;
	}
}

- (void)setDisplayFramebuffer;
{
    if (!displayFramebuffer)
    {
        [self createDisplayFramebuffer];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
    
    glViewport(0, 0, backingWidth, backingHeight);
}

- (void)presentFramebuffer;
{
    glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
    [[GPUImageOpenGLESContext sharedImageProcessingOpenGLESContext] presentBufferForDisplay];
}

#pragma mark -
#pragma mark GPUInput protocol

- (void)newFrameReady;
{
    [GPUImageOpenGLESContext useImageProcessingContext];
    [self setDisplayFramebuffer];
    
    [displayProgram use];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
//    static const GLfloat squareVertices[] = {
//        -1.0f, -1.0f,
//        1.0f, -1.0f,
//        -1.0f,  1.0f,
//        1.0f,  1.0f,
//    };
    
    static const GLfloat textureCoordinates[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };

	glActiveTexture(GL_TEXTURE4);
	glBindTexture(GL_TEXTURE_2D, inputTextureForDisplay);
	glUniform1i(displayInputTextureUniform, 4);	
    
    glVertexAttribPointer(displayPositionAttribute, 2, GL_FLOAT, 0, 0, imageVertices);
	glVertexAttribPointer(displayTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [self presentFramebuffer];
}

- (NSInteger)nextAvailableTextureIndex;
{
    return 0;
}

- (void)setInputTexture:(GLuint)newInputTexture atIndex:(NSInteger)textureIndex;
{
    inputTextureForDisplay = newInputTexture;
}

- (void)setInputSize:(CGSize)newSize;
{

}


- (CGSize)maximumOutputSize;
{
    if ([self respondsToSelector:@selector(setContentScaleFactor:)])
    {
        CGSize pointSize = self.bounds.size;
        return CGSizeMake(self.contentScaleFactor * pointSize.width, self.contentScaleFactor * pointSize.height);
    }
    else
    {
        return self.bounds.size;
    }
}

- (void)setFillMode:(GPUImageFillModeType)newValue;
{
    _fillMode = newValue;
    [self recalculateViewGeometry];
}

#pragma mark -
#pragma mark Handling fill mode

- (void)recalculateViewGeometry;
{
//    runSynchronouslyOnVideoProcessingQueue(^{
        CGFloat heightScaling, widthScaling;
        
        CGSize currentViewSize = self.bounds.size;
        inputImageSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH);
        //    CGFloat imageAspectRatio = inputImageSize.width / inputImageSize.height;
        //    CGFloat viewAspectRatio = currentViewSize.width / currentViewSize.height;
        
        CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(inputImageSize, self.bounds);
    
        switch(_fillMode)
        {
            case kGPUImageFillModeStretch:
            {
                widthScaling = 1.0;
                heightScaling = 1.0;
            }; break;
            case kGPUImageFillModePreserveAspectRatio:
            {
                widthScaling = insetRect.size.width / currentViewSize.width;
                heightScaling = insetRect.size.height / currentViewSize.height;
            }; break;
            case kGPUImageFillModePreserveAspectRatioAndFill:
            {
                //            CGFloat widthHolder = insetRect.size.width / currentViewSize.width;
                widthScaling = currentViewSize.height / insetRect.size.height;
                heightScaling = currentViewSize.width / insetRect.size.width;
            }; break;
        }
        
        imageVertices[0] = -widthScaling;
        imageVertices[1] = -heightScaling;
        imageVertices[2] = widthScaling;
        imageVertices[3] = -heightScaling;
        imageVertices[4] = -widthScaling;
        imageVertices[5] = heightScaling;
        imageVertices[6] = widthScaling;
        imageVertices[7] = heightScaling;
//    });
    
    //    static const GLfloat imageVertices[] = {
    //        -1.0f, -1.0f,
    //        1.0f, -1.0f,
    //        -1.0f,  1.0f,
    //        1.0f,  1.0f,
    //    };
}


@end
