//
//  ViewController.m
//  learnOpenGLESGLKit05球体
//
//  Created by 刘晓亮 on 2017/9/30.
//  Copyright © 2017年 刘晓亮. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define kDevidCount 80

#define kLimitDegreeUpDown 80.0


typedef struct{
    GLfloat position[3];
    GLfloat texturePosition[2];
} Vertex;


@interface ViewController ()

@property (nonatomic,strong)GLKBaseEffect * effect;

@property(nonatomic,assign)GLint degreeX;
@property(nonatomic,assign)GLint degreeY;

@end

@implementation ViewController{
    
    Vertex * _cirleVertex;
    GLuint * _vertextIndex;
    
    GLKMatrix4 _modelMatrix;
    
    GLuint _bufferVBO;
    GLuint _bufferIndexVBO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    GLKView * glView = (GLKView *)self.view;
    
    EAGLContext * contex = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!contex) {
        NSLog(@"context创建失败");
    }
    if (![EAGLContext setCurrentContext:contex]) {
        NSLog(@"设置当前context失败");
    }
    
    glView.context = contex;
    glView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.useConstantColor = GL_TRUE;
    self.effect.constantColor = GLKVector4Make(0.8, 0.8, 0.8, 1.0);
    
    glEnable(GL_DEPTH_TEST);
    [self setupLighting];
    [self setupTexture];
    [self setupBufferVBO];
    
    glClearColor(0.3, 0.3, 0.3, 1.0);
    
    // 设置视角和物体的矩阵变换
    GLfloat aspect = self.view.frame.size.width / self.view.frame.size.height;
    
    self.effect.transform.modelviewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0, 0.0, -3);
    
    self.effect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), aspect, 0.1f, 10.0f);
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch * touch = touches.anyObject;
    CGPoint currentPoint = [touch locationInView:self.view];
    CGPoint previousPoint = [touch previousLocationInView:self.view];
    
    self.degreeX += currentPoint.x - previousPoint.x;
    self.degreeY += currentPoint.y - previousPoint.y;
    
    // 限制上下转动的角度
    if (self.degreeY > kLimitDegreeUpDown) {
        self.degreeY = kLimitDegreeUpDown;
    }
    
    if (self.degreeY < -kLimitDegreeUpDown) {
        self.degreeY = -kLimitDegreeUpDown;
    }
    
}



/**
 设置纹理
 */
- (void)setupTexture{
    
    // 加载纹理图片
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    NSError * error;
    
    CGImageRef image = [UIImage imageNamed:@"timg"].CGImage;
    GLKTextureInfo * textureInfo = [GLKTextureLoader textureWithCGImage:image options:options error:&error];
    
    // 设置纹理可用
    self.effect.texture2d0.enabled = GL_TRUE;
    // 传递纹理信息
    self.effect.texture2d0.name = textureInfo.name;
    self.effect.texture2d0.target = textureInfo.target;
}


/**
 设置顶点缓存VBO
 */
- (void)setupBufferVBO {
    
    // 获取球的顶点和索引
    _cirleVertex = [self getBallDevidNum:kDevidCount];
    _vertextIndex = [self getBallVertexIndex:kDevidCount];
    
    // 设置VBO
    glGenBuffers(1, &_bufferVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _bufferVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * (kDevidCount + 1) * (kDevidCount / 2 + 1), _cirleVertex, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_bufferIndexVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufferIndexVBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint) * kDevidCount * (kDevidCount + 1), _vertextIndex, GL_STATIC_DRAW);
    
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)NULL);
    // 设置法线
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)NULL);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    
    
    // 设置纹理坐标
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLfloat *)NULL + 3);
    // 释放顶点数据
    free(_cirleVertex);
    free(_vertextIndex);
}

/**
 设置光照
 */
- (void)setupLighting{
    
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.position = GLKVector4Make(1.0, 0.8, 0.8, 0.0);
    
    self.effect.light0.ambientColor = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
    self.effect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
}


/**
 绘制一个圆环的顶点数组
 
 @param num 要多少个顶点
 @return 返回顶点数组
 */
- (Vertex *)getCirleDevidNum:(GLint) num{
    
    float delta = 2 * M_PI / num;
    float myScale = 0.5; // 半径
    float tempY;
    float tempX;
    
    Vertex * cirleVertex = malloc(sizeof(Vertex) * num);
    memset(cirleVertex, 0x00, sizeof(Vertex) * num);
    
    for (int i = 0; i < num; i++) {
        
        tempY = myScale * sin(delta * i);
        tempX = myScale * cos(delta * i);
        
        cirleVertex[i] = (Vertex){tempX, tempY, 0.0f};
    }
    return cirleVertex;
}



/**
 绘制一个球的顶点
 
 @param num 传入要生成的顶点的一层的个数（最后生成的顶点个数为 num * num）
 @return 返回生成后的顶点
 */
- (Vertex *)getBallDevidNum:(GLint) num{
    
    if (num % 2 == 1) {
        return 0;
    }
    
    GLfloat delta = 2 * M_PI / num; // 分割的份数
    GLfloat ballRaduis = 0.8; // 球的半径
    GLfloat pointZ;
    GLfloat pointX;
    GLfloat pointY;
    GLfloat textureY;
    GLfloat textureX;
    GLfloat textureYdelta = 1.0 / (num / 2);
    GLfloat textureXdelta = 1.0 / num;
    GLint layerNum = num / 2.0 + 1; // 层数
    GLint perLayerNum = num + 1; // 要让点再加到起点所以num + 1
    
    Vertex * cirleVertex = malloc(sizeof(Vertex) * perLayerNum * layerNum);
    memset(cirleVertex, 0x00, sizeof(Vertex) * perLayerNum * layerNum);
    
    // 层数
    for (int i = 0; i < layerNum; i++) {
        // 每层的高度(即pointY)，为负数让其从下向上创建
        pointY = -ballRaduis * cos(delta * i);
        
        // 每层的半径
        GLfloat layerRaduis = ballRaduis * sin(delta * i);
        // 每层圆的点,
        for (int j = 0; j < perLayerNum; j++) {
            // 计算
            pointX = layerRaduis * cos(delta * j);
            pointZ = layerRaduis * sin(delta * j);
            textureX = textureXdelta * j;
            textureY = textureYdelta * i;
            
            cirleVertex[i * perLayerNum + j] = (Vertex){pointX, pointY, pointZ, textureX, textureY};
        }
    }
    
    return cirleVertex;
}



- (GLuint *)getBallVertexIndex:(GLint)num{
    
    // 每层要多原点两次
    GLint sizeNum = sizeof(GLuint) * (num + 1) * (num + 1);
    
    GLuint * ballVertexIndex = malloc(sizeNum);
    memset(ballVertexIndex, 0x00, sizeNum);
    GLint layerNum = num / 2 + 1;
    GLint perLayerNum = num + 1; // 要让点再加到起点所以num + 1
    
    for (int i = 0; i < layerNum; i++) {
        
        
        if (i + 1 < layerNum) {
            
            for (int j = 0; j < perLayerNum; j++) {
                
                // i * perLayerNum * 2每层的下标是原来的2倍
                ballVertexIndex[(i * perLayerNum * 2) + (j * 2)] = i * perLayerNum + j;
                // 后一层数据
                ballVertexIndex[(i * perLayerNum * 2) + (j * 2 + 1)] = (i + 1) * perLayerNum + j;
            }
        } else {
            
            for (int j = 0; j < perLayerNum; j++) {
                // 后最一层数据单独处理
                ballVertexIndex[i * perLayerNum * 2 + j] = i * perLayerNum + j;
            }
        }
    }
    
    return ballVertexIndex;
}



- (void)update{
    
    _modelMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0, 0.0, -3);
    
    _modelMatrix = GLKMatrix4RotateX(_modelMatrix, GLKMathDegreesToRadians(self.degreeY % 360));
    
    _modelMatrix = GLKMatrix4RotateY(_modelMatrix, GLKMathDegreesToRadians(self.degreeX % 360));
    
    self.effect.transform.modelviewMatrix = _modelMatrix;
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    
    // 绘制一个圆环
    //    glDrawArrays(GL_LINE_LOOP, 0, kDevidCount * (kDevidCount / 2));
    // 绘制一个圆
    //    glDrawArrays(GL_TRIANGLE_FAN, 0, kDevidCount * (kDevidCount / 2));
    
    // 绘制一个球（用层表示）
    //    glDrawArrays(GL_LINE_LOOP, 0, (kDevidCount + 1) * (kDevidCount / 2 + 1));
    
    // 绘制一个球
    glDrawElements(GL_TRIANGLE_STRIP, kDevidCount * (kDevidCount + 1), GL_UNSIGNED_INT, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
