//
//  GLView.m
//  OpenGLDemo
//
//  Created by fmj on 14-6-20.
//  Copyright (c) 2014年 fmj. All rights reserved.
//

#import "GLView.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3  positionCoords;
}
SceneVertex;

static const SceneVertex vertices[] =
{
    {{-0.5f, -0.5f, 0.0}}, // lower left corner
    {{ 0.5f, -0.5f, 0.0}}, // lower right corner
    {{-0.5f,  0.5f, 0.0}}  // upper left corner
};


@implementation GLView
{
    CAEAGLLayer * _eaglLayer;
    EAGLContext * _context;
    GLuint vertexBufferID;
    GLuint _colorRenderBuffer;
    GLKBaseEffect * _baseEffect;
}

+ (Class)layerClass
/* To set up a view display OpenGL content, you need to set it's default layer to sepcial kind of layer caller CAEAGLLayer. The way you set the default layer is to simply overwrite the layerClass mehod. The returned CAEAGLLayer object is a wrapper for a Core Animation surface that is fully compatible with OpenGL ES function calls. */
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initGLView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if((self = [super initWithCoder:coder])) {
        [self initGLView];
    }
    return self;
}

-(void)initGLView
{
    [self initLayer];
    [self initGLContext];
    [self initRenderBuffer];
    [self initFrameBuffer];
    [self initBuffers];
    [self initEffect];
    [self initDisplayLink];
    
}

-(void)initEffect
{
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.useConstantColor = GL_TRUE;
    _baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f,1.0f);
}

-(void)initLayer
{
    _eaglLayer = (CAEAGLLayer *) self.layer;
    [_eaglLayer setOpaque: YES];
}

-(void)initGLContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

-(void)initRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

-(void)initFrameBuffer
{
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    //glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer)
}

-(void)initBuffers
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f); // background color
    
    // Generate, bind, and initialize contents of a buffer to be
    // stored in GPU memory
    glGenBuffers(1,                // STEP 1
                 &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
                 vertexBufferID);
    glBufferData(                  // STEP 3
                 GL_ARRAY_BUFFER,  // Initialize buffer contents
                 sizeof(vertices), // Number of bytes to copy
                 vertices,         // Address of bytes to copy
                 GL_STATIC_DRAW);  // Hint: cache in GPU memory
    
}

-(void)initDisplayLink
{
    CADisplayLink * displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


- (void)render:(CADisplayLink *)displayLink
{
    [EAGLContext setCurrentContext:_context];
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    [_baseEffect prepareToDraw];
    
    glClear(GL_COLOR_BUFFER_BIT);

    
    // Enable use of positions from bound vertex buffer
    glEnableVertexAttribArray(      // STEP 4
                              GLKVertexAttribPosition);
    
    glVertexAttribPointer(          // STEP 5
                          GLKVertexAttribPosition,
                          3,                   // three components per vertex
                          GL_FLOAT,            // data is floating point
                          GL_FALSE,            // no fixed point scaling
                          sizeof(SceneVertex), // no gaps in data
                          NULL);               // NULL tells GPU to start at
    // beginning of bound buffer
    
    // Draw triangles using the first three vertices in the
    // currently bound vertex buffer
    glDrawArrays(GL_TRIANGLES,      // STEP 6
                 0,  // Start with first vertex in currently bound buffer
                 3); // Use three vertices from currently bound buffer
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
