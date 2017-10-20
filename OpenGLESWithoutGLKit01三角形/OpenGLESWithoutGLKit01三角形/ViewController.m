//
//  ViewController.m
//  OpenGLESWithoutGLKit01三角形
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
    
    CAEAGLLayer * _myLayer; // 用于显示的layer
    EAGLContext * _myContext; // 用于管理状态的context
    
    GLuint _myFrameBuffer; // 帧缓存
    GLuint _myRenderBuffer; // 渲染缓存
    
    GLuint _myPrograme; // 用于链接着色器的程序
    GLuint _myPositionSlot; // 用于向着色器传递顶点数据的槽
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*** 创建显示的layer ***/
    _myLayer = [[CAEAGLLayer alloc] init];
    _myLayer.frame = self.view.frame;
    _myLayer.opaque = YES; // 设置为不透明
    // 设置kEAGLDrawablePropertyRetainedBacking为NO表示不维持上一次绘制的内容
    // kEAGLColorFormatRGBA8表示设置色彩空间为RGBA8
    _myLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@(NO), kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    // 将创建的layer添加到视图
    [self.view.layer addSublayer:_myLayer];
    
    /*** 创建和设置context ***/
    
    // 创建的context为OpenGL ES 2.0，因为2.0开始支持可编辑管线且大多数苹果设备都支持
    _myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (nil == _myContext) {
        NSLog(@"context 创建失败");
    }
    // 将创建的context设置为当前context
    if (![EAGLContext setCurrentContext:_myContext]) {
        NSLog(@"context 设置失败");
    }
    
    /*** 申请和绑定渲染缓存和帧缓存 ***/
    // 为renderbuffer申请一个id
    glGenRenderbuffers(1, &_myRenderBuffer);
    // 设置当前的renderbuffer为刚申请的
    glBindRenderbuffer(GL_RENDERBUFFER, _myRenderBuffer);
    // 为renderbuffer分配存储空间
    [_myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_myLayer];
    // 为framebuffer申请一个id
    glGenFramebuffers(1, &_myFrameBuffer);
    // 设置当前的framebuffer为刚申请的
    glBindFramebuffer(GL_FRAMEBUFFER, _myFrameBuffer);
    // 将renderbuffer关联到framebuffer上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _myRenderBuffer);
    
    /*** 编译链接着色器 ***/
    [self setupPrograme];
    
    /*** 设置顶点信息 ***/
    // 创建三角形的顶点
    GLfloat vertexes[] = {
        
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f, 0.5f, 0.0f
    };
    // 设置顶点数据的指针信息
    glVertexAttribPointer(_myPositionSlot, // 传入对应数据槽的位置
                          3, // 一组有多少数据，即3个一组
                          GL_FLOAT, // 数据类型
                          GL_FALSE, // 是否是正交视图
                          sizeof(GLfloat) * 3, // 数据跨度
                          vertexes // 顶点数据
                          );
    // 启用顶点数据
    glEnableVertexAttribArray(_myPositionSlot);
    
    /*** 渲染显示三角形 ***/
    // 设置显示区域
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    // 设置清屏颜色
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    // 绘制三角开
    glDrawArrays(GL_TRIANGLES, 0, 3);
    // 显示三角形
    [_myContext presentRenderbuffer:GL_RENDERBUFFER];
}

/**
 编译和链接程序
 */
- (void)setupPrograme{
    
    GLuint vertexShader = [self loadShader:GL_VERTEX_SHADER withFileName:@"vertexShader.glsl"];
    GLuint fragmentShader = [self loadShader:GL_FRAGMENT_SHADER withFileName:@"fragmentShader.glsl"];
    // 创建一个程序
    _myPrograme = glCreateProgram();
    
    if (!_myPrograme) {
        NSLog(@"创建programe失败");
    }
    // 添加着色器到程序中并链接
    glAttachShader(_myPrograme, vertexShader);
    glAttachShader(_myPrograme, fragmentShader);
    glLinkProgram(_myPrograme);
    
    GLint success = 0;
    // 获取程序信息
    glGetProgramiv(_myPrograme, GL_LINK_STATUS, &success);
    if (success == GL_FALSE) { // 程序链接失败
        
        GLint infoLen = 0;
        // 获取错误信息长度
        glGetProgramiv(_myPrograme, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 0) {
            // 申请内存存放错误信息
            GLchar * info = malloc(sizeof(GLchar) * infoLen);
            glGetProgramInfoLog(_myPrograme, sizeof(GLchar) * infoLen, &infoLen, info);
            
            NSLog(@"%s", info);
            free(info);
        }
        // 删除链接失败的程序
        glDeleteProgram(_myPrograme);
        _myPrograme = 0;
        return;
    }
    // 启用程序
    glUseProgram(_myPrograme);
    // 获取顶点着色器myPosition的内存地址
    _myPositionSlot = glGetAttribLocation(_myPrograme, "myPosition");
}


/**
 创建和编译着色器
 
 @param type 着色器类型
 @param fileName 着色器文件
 @return 返回创建好的着色器，创建失败则返回0
 */
- (GLuint)loadShader:(GLenum)type withFileName:(NSString *)fileName{
    // 获取文件路径
    NSString * path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    NSError * error;
    NSString * shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    // 转成C字符串
    const GLchar * shaderStringUTF8 = shaderString.UTF8String;
    
    if (error) {
        NSLog(@"文件读取错误:%@",error);
    }
    // 创建着色器程序
    GLuint shader = glCreateShader(type);
    // 给着色器程序传递着色器字符串
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);
    // 编译
    glCompileShader(shader);
    // 查看编译情况
    GLint compiled = 0;
    // 获取着色器信息
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (compiled == GL_FALSE) {
        
        GLint infoLen = 0;
        // 获取错误信息的长度
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 0) {
            
            GLchar * info = malloc(sizeof(GLchar) * infoLen);
            
            glGetShaderInfoLog(shader, // 对应的着色器
                               sizeof(GLchar) * infoLen, // buffer的大小
                               &infoLen, // 传入错误长度
                               info); // 存放错误信息的内存
            
            NSLog(@"着色器错误：%s", info);
            free(info); // 释放内存
        }
        // 移除创建失败的着色器
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
