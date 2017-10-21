//
//  ViewController.m
//  learnOpenGLESGLKit03
//
//  Created by 刘晓亮 on 2017/8/17.
//  Copyright © 2017年 刘晓亮. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define kLimitDegree 35.0f

typedef struct {
    
    GLKVector3 position;
    GLKVector2 texturePosition;
} Vertex;


@interface ViewController ()

@property(nonatomic, strong)GLKBaseEffect * effect;

@property(nonatomic, assign)CGFloat degreeY;
@property(nonatomic, assign)CGFloat degreeX;

@property(nonatomic, assign)CGFloat scale;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scale = self.view.frame.size.width / self.view.frame.size.height;
    [self setupViewAndContext];
    
    self.effect = [[GLKBaseEffect alloc] init];
    // 想画只有线绘成的立方体就下面注释的代码打开，并将相同的代码注释掉和将纹理的代码也注释掉就可以了，下面注释的代码也做这样的操作
//    self.effect.useConstantColor = GL_TRUE;
//    self.effect.constantColor = GLKVector4Make(1.0, 0.0, 0.0, 1.0);
    
    [self setupVertex];
    [self setupTexture2D];
    
    glClearColor(1.0, 1.0, 1.0, 1.0);
    
    // 添加深度测试，别忘了在glClear里添加GL_DEPTH_BUFFER_BIT，不然会造成无法显示
    glEnable(GL_DEPTH_TEST);
    
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self setupBaseTransform];
    
}


/**
 设置GLKView和context
 */
- (void)setupViewAndContext {
    
    GLKView * glView = (GLKView *)self.view;
    glView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    
    EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"context 创建失败");
    }
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"设置当前context失败");
    }
    
    glView.context = context;
}


/**
 设置顶点数据
 */
- (void)setupVertex {
    
    // 设置顶点数据
    GLfloat vertexes[] = {
        // 前面
        -0.5f, 0.5f, 0.5f,      0.0f, 1.0f, // 前左上 0
        -0.5f, -0.5f, 0.5f,     0.0f, 0.0f, // 前左下 1
        0.5f, -0.5f, 0.5f,      1.0f, 0.0f, // 前右下 2
        0.5f, 0.5f, 0.5f,       1.0f, 1.0f, // 前右上 3
        // 后面
        -0.5f, 0.5f, -0.5f,     1.0f, 1.0f, // 后左上 4
        -0.5f, -0.5f, -0.5f,    1.0f, 0.0f, // 后左下 5
        0.5f, -0.5f, -0.5f,     0.0f, 0.0f, // 后右下 6
        0.5f, 0.5f, -0.5f,      0.0f, 1.0f, // 后右上 7
        // 左面
        -0.5f, 0.5f, -0.5f,     0.0f, 1.0f, // 后左上 8
        -0.5f, -0.5f, -0.5f,    0.0f, 0.0f, // 后左下 9
        -0.5f, 0.5f, 0.5f,      1.0f, 1.0f, // 前左上 10
        -0.5f, -0.5f, 0.5f,     1.0f, 0.0f, // 前左下 11
        // 右面
        0.5f, 0.5f, 0.5f,       0.0f, 1.0f, // 前右上 12
        0.5f, -0.5f, 0.5f,      0.0f, 0.0f, // 前右下 13
        0.5f, -0.5f, -0.5f,     1.0f, 0.0f, // 后右下 14
        0.5f, 0.5f, -0.5f,      1.0f, 1.0f, // 后右上 15
        // 上面
        -0.5f, 0.5f, 0.5f,      0.0f, 0.0f, // 前左上 16
        0.5f, 0.5f, 0.5f,       1.0f, 0.0f, // 前右上 17
        -0.5f, 0.5f, -0.5f,     0.0f, 1.0f, // 后左上 18
        0.5f, 0.5f, -0.5f,      1.0f, 1.0f, // 后右上 19
        // 下面
        -0.5f, -0.5f, 0.5f,     0.0f, 1.0f, // 前左下 20
        0.5f, -0.5f, 0.5f,      1.0f, 1.0f, // 前右下 21
        -0.5f, -0.5f, -0.5f,    0.0f, 0.0f, // 后左下 22
        0.5f, -0.5f, -0.5f,     1.0f, 0.0f, // 后右下 23
    };

    // 索引
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
        18, 16, 17,
        18, 17, 19,
        // 下面
        20, 22, 23,
        20, 23, 21
    };
    
    
//    const GLfloat vertexes[] = {
//
//        -0.5f, 0.5f, 0.5f, // 前左上 0
//        -0.5f, -0.5f, 0.5f, // 前左下 1
//        0.5f, -0.5f, 0.5f, // 前右下 2
//        0.5f, 0.5f, 0.5f, // 前右上 3
//        // 后面
//        -0.5f, 0.5f, -0.5f, // 后左上 4
//        -0.5f, -0.5f, -0.5f, // 后左下 5
//        0.5f, -0.5f, -0.5f, // 后右下 6
//        0.5f, 0.5f, -0.5f // 后右上 7
//    };
//
//    const GLbyte indexes[] = {
//        0, 1,
//        1, 2,
//        2, 3,
//        3, 0,
//
//        4, 5,
//        5, 6,
//        6, 7,
//        7, 4,
//
//        0, 4,
//        1, 5,
//        2, 6,
//        3, 7
//    };
    
    
    // 创建VBO并传递顶点数据
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexes), vertexes, GL_STATIC_DRAW);
    
    // 创建VBO并传递顶点索引（顶点索引不用设置指针参数）
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexes), indexes, GL_STATIC_DRAW);
    
    // 设置顶点指针数据参数
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, NULL);
    
    // 启用顶点数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    // 设置纹理指针坐标信息
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
}



/**
 设置纹理
 */
- (void)setupTexture2D{
    
    UIImage * image = [UIImage imageNamed:@"timg"];
    
    NSDictionary * option = [NSDictionary dictionaryWithObjectsAndKeys:@(YES),GLKTextureLoaderOriginBottomLeft, nil];
    NSError * error;
    GLKTextureInfo * textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:option error:&error];
    
    if (error) {
        NSLog(@"%@",error);
    }
    
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = textureInfo.name;
}


/**
 设置初始的视图变换
 */
- (void)setupBaseTransform{
    
    // 设置基础变换
    GLKMatrix4 mat = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -3.0f);
    
    mat = GLKMatrix4RotateY(mat, GLKMathDegreesToRadians(0));
    
    GLKMatrix4 temMat = GLKMatrix4RotateX(mat, GLKMathDegreesToRadians(0));
    
    self.effect.transform.modelviewMatrix = temMat;
    
    // 设置视角变换（添加该方法后可解决图形因屏幕而被拉伸的问题）
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    
    GLKMatrix4 matPersPective = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = matPersPective;
}



- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch * touch = touches.anyObject;
    CGPoint currentPoint = [touch locationInView:self.view];
    CGPoint previousPoint = [touch previousLocationInView:self.view];
    
    self.degreeY += currentPoint.y - previousPoint.y;
    self.degreeX += currentPoint.x - previousPoint.x;
    if (self.degreeY > kLimitDegree) {
        self.degreeY = kLimitDegree;
    }
    if (self.degreeY < -kLimitDegree) {
        self.degreeY = -kLimitDegree;
    }
}


/**
 系统会调用些方法
 */
- (void)update{
    
    // 设置物体变换 （让物体远离是为了能看全，因为摄像机默认在0，0，0点，即在物体内部）
    GLKMatrix4 mat = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -3.0f);
    
    mat = GLKMatrix4RotateX(mat, GLKMathDegreesToRadians(self.degreeY));
    
    GLKMatrix4 temMat = GLKMatrix4RotateY(mat, GLKMathDegreesToRadians(self.degreeX));
    
    self.effect.transform.modelviewMatrix = temMat;
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    // 清屏和清除深度缓存
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    
    glDrawElements(GL_TRIANGLES, // 绘制顶点的模式
                   36, // 索引的个数
                   GL_UNSIGNED_BYTE, // 索引的数据类型
                   0); // 索引从第几个开始
    
//    glDrawElements(GL_LINES, // 绘制顶点的模式
//                   24, // 索引的个数
//                   GL_UNSIGNED_BYTE, // 索引的数据类型
//                   0); // 索引从第几个开始
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
