//
//  ViewController.m
//  OpenGLESWithoutGLKIt03立方体
//
//  Created by 刘晓亮 on 2017/9/30.
//  Copyright © 2017年 刘晓亮. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "ksMatrix.h"

// 限制上下转动的角度
#define kLimitDegreeUpDown 40.0

// 顶点结构体
typedef struct{
    
    GLfloat position[3];
    GLfloat texturePosion[2];
} Vertex;


const Vertex vertexes[] = {
    // 顶点                   纹理
    // 前面
    {{-0.5f, 0.5f, 0.5f},   {0.0f, 0.0f}}, // 前左上 0
    {{-0.5f, -0.5f, 0.5f},  {0.0f, 1.0f}}, // 前左下 1
    {{0.5f, -0.5f, 0.5f},   {1.0f, 1.0f}}, // 前右下 2
    {{0.5f, 0.5f, 0.5f},    {1.0f, 0.0f}}, // 前右上 3
    // 后面
    {{-0.5f, 0.5f, -0.5f},   {1.0f, 0.0f}}, // 后左上 4
    {{-0.5f, -0.5f, -0.5f},  {1.0f, 1.0f}}, // 后左下 5
    {{0.5f, -0.5f, -0.5f},   {0.0f, 1.0f}}, // 后右下 6
    {{0.5f, 0.5f, -0.5f},    {0.0f, 0.0f}}, // 后右上 7
    // 左面
    {{-0.5f, 0.5f, -0.5f},   {0.0f, 0.0f}}, // 后左上 8
    {{-0.5f, -0.5f, -0.5f},  {0.0f, 1.0f}}, // 后左下 9
    {{-0.5f, 0.5f, 0.5f},   {1.0f, 0.0f}}, // 前左上 10
    {{-0.5f, -0.5f, 0.5f},  {1.0f, 1.0f}}, // 前左下 11
    // 右面
    {{0.5f, 0.5f, 0.5f},    {0.0f, 0.0f}}, // 前右上 12
    {{0.5f, -0.5f, 0.5f},   {0.0f, 1.0f}}, // 前右下 13
    {{0.5f, -0.5f, -0.5f},   {1.0f, 1.0f}}, // 后右下 14
    {{0.5f, 0.5f, -0.5f},    {1.0f, 0.0f}}, // 后右上 15
    // 上面
    {{-0.5f, 0.5f, -0.5f},   {0.0f, 0.0f}}, // 后左上 16
    {{-0.5f, 0.5f, 0.5f},   {0.0f, 1.0f}}, // 前左上 17
    {{0.5f, 0.5f, 0.5f},    {1.0f, 1.0f}}, // 前右上 18
    {{0.5f, 0.5f, -0.5f},    {1.0f, 0.0f}}, // 后右上 19
    // 下面
    {{-0.5f, -0.5f, 0.5f},  {0.0f, 0.0f}}, // 前左下 20
    {{0.5f, -0.5f, 0.5f},   {1.0f, 0.0f}}, // 前右下 21
    {{-0.5f, -0.5f, -0.5f},  {0.0f, 1.0f}}, // 后左下 22
    {{0.5f, -0.5f, -0.5f},   {1.0f, 1.0f}}, // 后右下 23
};

const GLbyte indexes[] = {
    // 前面
    0, 1, 2,
    0, 2, 3,
    // 后面
    4, 5, 6,
    4, 6, 7,
    // 左面
    8, 9, 11,
    8, 11, 10,
    // 右面
    12, 13, 14,
    12, 14, 15,
    // 上面
    16, 17, 18,
    16, 18, 19,
    // 下面
    20, 22, 23,
    20, 23, 21,
};

// 想画只有线绘成的立方体就下面注释的代码打开，并将相同的代码注释掉就可以了，下面注释的代码也做这样的操作
//const GLfloat vertexes[] = {
//
//    -0.5f, 0.5f, 0.5f, // 前左上 0
//    -0.5f, -0.5f, 0.5f, // 前左下 1
//    0.5f, -0.5f, 0.5f, // 前右下 2
//    0.5f, 0.5f, 0.5f, // 前右上 3
//    // 后面
//    -0.5f, 0.5f, -0.5f, // 后左上 4
//    -0.5f, -0.5f, -0.5f, // 后左下 5
//    0.5f, -0.5f, -0.5f, // 后右下 6
//    0.5f, 0.5f, -0.5f // 后右上 7
//};
//
//
//const GLbyte indexes[] = {
//    0, 1,
//    1, 2,
//    2, 3,
//    3, 0,
//
//    4, 5,
//    5, 6,
//    6, 7,
//    7, 4,
//
//    0, 4,
//    1, 5,
//    2, 6,
//    3, 7
//};



@interface ViewController ()

@property(nonatomic,assign)GLfloat degreeX;

@property(nonatomic,assign)GLfloat degreeY;

@property (nonatomic,strong)CADisplayLink * link;

@end

@implementation ViewController{
    
    EAGLContext * _context;
    CAEAGLLayer * _glLayer;
    
    GLuint _renderBuffer; // 渲染缓存
    GLuint _depthRenderBuffer; // 深度测试渲染
    GLuint _frameBuffer; // 帧缓存
    
    GLuint _program; // 链接着色器的程序
    GLuint _vertexSlot; // 图形顶点的槽
    GLuint _textureCoordsSlot; // 纹理顶点坐标的槽
    GLuint _modelViewSlot; // 物体变换的槽
    GLuint _projectionSlot; // 摄像机的槽
    
    ksMatrix4 _matrix4; // 物体变换矩阵
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupGLLayer]; // 设置显示的layer
    [self setupGLContext]; // 设置context
    [self setupFrameAndRenderBuffer]; // 设置渲染缓存和帧缓存
    [self setupGLProgram]; // 编译链接着色器
    [self setupVBO]; // 设置顶点缓存
    [self setupTexture2D]; // 设置纹理图片
    [self setupPerspactive]; // 设置视锥体
    
    // 设置视图刷新
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch * touch = touches.anyObject;
    
    CGPoint currentPoint = [touch locationInView:self.view];
    CGPoint previousPoint = [touch previousLocationInView:self.view];
    
    self.degreeX += previousPoint.y - currentPoint.y;
    
    // 限制上下转动的角度
    if (self.degreeX > kLimitDegreeUpDown) {
        self.degreeX = kLimitDegreeUpDown;
    }
    
    if (self.degreeX < -kLimitDegreeUpDown) {
        self.degreeX = -kLimitDegreeUpDown;
    }
    
    self.degreeY += previousPoint.x - currentPoint.x;
}


/**
 设置纹理
 */
- (void)setupTexture2D {
    
    CGImageRef image = [UIImage imageNamed:@"timg"].CGImage;
    
    CGFloat width = CGImageGetWidth(image);
    CGFloat height = CGImageGetHeight(image);
    
    CGDataProviderRef dataProvider = CGImageGetDataProvider(image);
    
    void * data = (void *)CFDataGetBytePtr(CGDataProviderCopyData(dataProvider));
    
    // 启用2D纹理
    glEnable(GL_TEXTURE_2D);
    // 申请纹理
    GLuint myTexture;
    glGenTextures(1, &myTexture);
    glBindTexture(GL_TEXTURE_2D, myTexture);
    
    // 设置纹理拉伸时的填充方法
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
}



/**
 设置CAEAGLLayer
 */
- (void)setupGLLayer {
    
    _glLayer = [[CAEAGLLayer alloc] init];
    _glLayer.frame = self.view.frame;
    _glLayer.opaque = YES;
    _glLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@(NO), kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    [self.view.layer addSublayer:_glLayer];
}


/**
 设置context
 */
- (void)setupGLContext {
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"创建context失败");
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"设置当前context失败");
    }
}


/**
 设置帧缓存和渲染缓存
 */
- (void)setupFrameAndRenderBuffer {
    
    // 申请渲染缓存
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    // 该方法最好在绑定渲染后立即设置，不然后面会被绑定为深度渲染缓存
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_glLayer];
    
    // 设置深度调试
    GLint width;
    GLint height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    // 申请深度渲染缓存
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    // 设置深度测试的存储信息
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    
    // 申请帧缓存
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    // 将渲染缓存挂载到GL_DEPTH_ATTACHMENT这个挂载点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
    // GL_RENDERBUFFER绑定的是深度测试渲染缓存，所以要绑定回色彩渲染缓存
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    // 检查帧缓存状态
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Error: Frame buffer is not completed.");
        exit(1);
    }
}


/**
 设置程序并链接着色器
 */
- (void)setupGLProgram {
    
    GLuint vertexShader = [self loadShader:GL_VERTEX_SHADER withFileName:@"vertexShader.glsl"];
    GLuint fragmentShader = [self loadShader:GL_FRAGMENT_SHADER withFileName:@"fragmentShader.glsl"];
    
//    GLuint vertexShader = [self loadShader:GL_VERTEX_SHADER withFileName:@"lineVertexShader.glsl"];
//    GLuint fragmentShader = [self loadShader:GL_FRAGMENT_SHADER withFileName:@"lineFragmentShader.glsl"];
    
    _program = glCreateProgram();
    glAttachShader(_program, vertexShader);
    glAttachShader(_program, fragmentShader);
    glLinkProgram(_program);
    
    GLint linked = GL_FALSE;
    glGetProgramiv(_program, GL_LINK_STATUS, &linked);
    if (linked == GL_FALSE) {
        
        GLint infoLen = 0;
        glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 0) {
            
            GLchar * info = malloc(sizeof(GLchar) * infoLen);
            glGetProgramInfoLog(_program, sizeof(GLchar) * infoLen, NULL, info);
            NSLog(@"%s",info);
            free(info);
        }
        glDeleteProgram(_program);
        _program = 0;
    }
    glUseProgram(_program);
    
    _vertexSlot = glGetAttribLocation(_program, "myPosition");
    // 如果modelView没有使用是获取失败，这是opengles的优化
    _modelViewSlot = glGetUniformLocation(_program, "modelView");
    _projectionSlot = glGetUniformLocation(_program, "projection");
    _textureCoordsSlot = glGetAttribLocation(_program, "textureCoordsIn");
}



/**
 设置顶点缓存（VBO）
 */
- (void)setupVBO {
    
    GLuint bufferVBO;
    glGenBuffers(1, &bufferVBO);
    glBindBuffer(GL_ARRAY_BUFFER, bufferVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexes), vertexes, GL_STATIC_DRAW);
    
    GLuint bufferIndex;
    glGenBuffers(1, &bufferIndex);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bufferIndex);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexes), indexes, GL_STATIC_DRAW);
    
    glVertexAttribPointer(_vertexSlot, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
//    glVertexAttribPointer(_vertexSlot, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, NULL);
    glEnableVertexAttribArray(_vertexSlot);

    glVertexAttribPointer(_textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    glEnableVertexAttribArray(_textureCoordsSlot);
    
}


/**
 设置视锥体
 */
- (void)setupPerspactive{
    
    GLfloat aspect = self.view.frame.size.width / self.view.frame.size.height;
    
    ksMatrix4 tempMatrix;
    
    ksMatrixLoadIdentity(&tempMatrix);
    
    ksPerspective(&tempMatrix, 60, aspect, 0.1f, 10.0f);
    
    glUniformMatrix4fv(_projectionSlot, 1 , GL_FALSE, (GLfloat *)&tempMatrix.m[0][0]);
}


/**
 渲染
 */
- (void)render {
    
    // 设置物体的变换
    ksMatrixLoadIdentity(&_matrix4);
    // 远离视野，不然是在
    ksMatrixTranslate(&_matrix4, 0, 0, -3);
    // x方向旋转
    ksMatrixRotate(&_matrix4, self.degreeX, 1, 0, 0);
    // y方向旋转
    ksMatrixRotate(&_matrix4, self.degreeY, 0, 1, 0);
    
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat *)&_matrix4.m[0][0]);
    
    
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    glClearColor(1.0, 1.0, 1.0, 1.0);
    
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glDrawElements(GL_TRIANGLES, sizeof(indexes)/sizeof(indexes[0]), GL_UNSIGNED_BYTE, 0);
    
//    glDrawElements(GL_LINES, sizeof(indexes) / sizeof(indexes[0]), GL_UNSIGNED_BYTE, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}



/**
 加载和编译着色器
 
 @param type 传入要生成的着色器
 @param fileName 传入着色器代码的文件名
 @return 返回创建好的着色器
 */
- (GLuint)loadShader:(GLenum)type withFileName:(NSString *)fileName{
    
    NSString * path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    NSError * error;
    NSString * shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    
    const GLchar * CString = shaderString.UTF8String;
    
    GLuint shader = glCreateShader(type);
    
    glShaderSource(shader,
                   1, // 文件个数
                   &CString,
                   NULL);
    
    glCompileShader(shader);
    
    GLint compiled = GL_FALSE;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (compiled == GL_FALSE) {
        
        GLint infoLen;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 0) {
            
            GLchar * info = malloc(sizeof(GLchar) * infoLen);
            
            glGetShaderInfoLog(shader, sizeof(GLchar) * infoLen, &infoLen, info);
            NSLog(@"%s",info);
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
