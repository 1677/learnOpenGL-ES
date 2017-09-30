//
//  ViewController.m
//  OpenGLESWithoutGLKit02纹理
//
//  Created by 刘晓亮 on 2017/9/30.
//  Copyright © 2017年 刘晓亮. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface ViewController ()

@end

@implementation ViewController{
    
    EAGLContext * _myContext; // 管理状态的context
    CAEAGLLayer * _myLayer; // 用于显示的layer
    
    GLuint _myFrameBuffer; // 帧缓存
    GLuint _myRenderBuffer; // 渲染缓存
    GLuint _myTextTure; // 纹理对象
    
    GLuint _myPrograme; // 用于链接着色器的程序
    
    GLuint _myPosintSlot; // 顶点数据对应的槽
    GLuint _myTextTureCoordSlot; // 纹理坐标对应的槽
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupGLLayer]; //
    [self setupGLContext];
    [self setupRenderAndFrameBuffer];
    [self setupShaders];
    [self setupTexture];
    [self render4Index];
}

/**
 设置纹理
 */
- (void)setupTexture {
    
    // 能实现图片翻转
    CGImageRef cgImageRef = [UIImage imageNamed:@"myImage"].CGImage;
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *data = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);
    
    
    glEnable(GL_TEXTURE_2D); // 开启2D纹理
    // 申请纹理id
    glGenTextures(1, &_myTextTure);
    // 绑定纹理id
    glBindTexture(GL_TEXTURE_2D, _myTextTure);
    
    // 设置图像拉伸变形时的处理方法
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    // 将图片数据传递给GL_TEXTURE_2D,因为上面已绑定纹理对象所以会把数据传递给_myTextTure
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    CGContextRelease(context);
    free(data);
}

/**
 使用顶点索引的渲染方法
 */
- (void)render4Index {
    
    GLfloat vertexes[] = {
        // 第一个三角形           // 纹理
        -0.5f, 0.5f, 0.0f,      0.0f, 1.0f, // 左上
        -0.5f, -0.5f, 0.0f,     0.0f, 0.0f, // 左下
        0.5f, -0.5f, 0.0f,      1.0f, 0.0f, // 右下
        0.5f, 0.5f, 0.0f,       1.0f, 1.0f // 右上
    };
    
    
    GLbyte indexes[] = {
        
        0, 1, 2,
        0, 2, 3
    };
    
    // 设置VBO（顶点缓存）
    GLuint bufferVBO;
    glGenBuffers(1, &bufferVBO);
    glBindBuffer(GL_ARRAY_BUFFER, bufferVBO);
    glBufferData(GL_ARRAY_BUFFER, // 目标
                 sizeof(vertexes), // 顶点数组数据大小
                 vertexes, // 顶点数组数据
                 GL_STATIC_DRAW); // 传入VBO数据的使用方式，这里一般设在表态
    // 设置索引缓存
    GLuint bufferIndex;
    glGenBuffers(1, &bufferIndex);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bufferIndex);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexes), indexes, GL_STATIC_DRAW);
    
    
    // 设置图形顶点指针数据(因为使用了VBO所以最后一个参数不用传)
    glVertexAttribPointer(_myPosintSlot, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    glEnableVertexAttribArray(_myPosintSlot);
    
    // 设置纹理顶点数据(因为使用了VBO所以最后一个参数不用传)
    glVertexAttribPointer(_myTextTureCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    glEnableVertexAttribArray(_myTextTureCoordSlot);
    
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    //    glDrawArrays(GL_TRIANGLES, 0, 6);
    // 用索引绘制顶点
    glDrawElements(GL_TRIANGLES, sizeof(indexes) / sizeof(indexes[0]), GL_UNSIGNED_BYTE, 0);
    [_myContext presentRenderbuffer:GL_RENDERBUFFER];
}


/**
 设置context
 */
- (void)setupGLContext {
    
    _myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (nil == _myContext) {
        NSLog(@"创建context失败");
    }
    if (![EAGLContext setCurrentContext:_myContext]) {
        NSLog(@"设置当前context失败");
    }
}


/**
 设置帧缓存和渲染缓存
 */
- (void)setupRenderAndFrameBuffer {
    
    glGenRenderbuffers(1, &_myRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _myRenderBuffer);
    [_myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_myLayer];
    
    glGenFramebuffers(1, &_myFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _myFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _myRenderBuffer);
}



/**
 设置显示的layer
 */
- (void)setupGLLayer{
    
    _myLayer = [[CAEAGLLayer alloc] init];
    _myLayer.frame = self.view.frame;
    _myLayer.opaque = YES; // 可不写，因为默认是YES
    _myLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@(NO), kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    [self.view.layer addSublayer:_myLayer];
}



/**
 编译和链接着色器程序
 */
- (void)setupShaders{
    
    GLuint vertexShader = [self loadShader:GL_VERTEX_SHADER withFileName:@"vertexShader.glsl"];
    GLuint fragmentShader = [self loadShader:GL_FRAGMENT_SHADER withFileName:@"fragmentShader.glsl"];
    
    _myPrograme = glCreateProgram();
    
    glAttachShader(_myPrograme, vertexShader);
    glAttachShader(_myPrograme, fragmentShader);
    
    glLinkProgram(_myPrograme);
    
    GLint linked = GL_FALSE;
    glGetProgramiv(_myPrograme, GL_LINK_STATUS, &linked);
    if (linked == GL_FALSE) {
        
        GLint infoLen;
        glGetProgramiv(_myPrograme, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 0) {
            
            GLchar * info = malloc(sizeof(GLchar) * infoLen);
            
            glGetProgramInfoLog(_myPrograme, sizeof(GLchar) * infoLen, &infoLen, info);
            NSLog(@"%s", info);
            free(info);
        }
        glDeleteProgram(_myPrograme);
        _myPrograme = 0;
        return;
    }
    glUseProgram(_myPrograme);
    // 获取顶点的槽
    _myPosintSlot = glGetAttribLocation(_myPrograme, "myPosition");
    // 获取纹理坐标的槽
    _myTextTureCoordSlot = glGetAttribLocation(_myPrograme, "textureCoord");
    
}


/**
 加载和编译着色器
 
 @param type 着色器类型
 @param fileName 着色器代码
 @return 返回编译好的着色器
 */
- (GLuint)loadShader:(GLenum)type withFileName:(NSString *)fileName{
    
    NSString * path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSError * error;
    NSString * shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"着色器文件读取失败");
        return 0;
    }
    
    const GLchar * shaderStringUTF8 = shaderString.UTF8String;
    
    GLuint shader = glCreateShader(type);
    
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);
    glCompileShader(shader);
    
    GLint compiled = GL_FALSE;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    
    if (compiled == GL_FALSE) {
        
        GLint infoLen = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 0) {
            
            GLchar * info = malloc(sizeof(GLchar) * infoLen);
            glGetShaderInfoLog(shader, sizeof(GLchar) * infoLen, &infoLen, info);
            
            NSLog(@"%s", info);
            free(info);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
