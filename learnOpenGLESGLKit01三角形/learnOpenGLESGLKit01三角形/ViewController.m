//
//  ViewController.m
//  learnOpenGLESGLKit01三角形
//
//  Created by 刘晓亮 on 2017/9/30.
//  Copyright © 2017年 刘晓亮. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef struct{
    GLKVector3 position;
} Vertex;


Vertex vertexs[] = {
    {-0.5f, -0.5f, 0.0f},
    {0.5f, -0.5f, 0.0f},
    {-0.5f, 0.5f, 0.0f},
    {-0.5f, 0.5f, 0.0f},
    {0.5f, -0.5f, 0.0f},
    {0.5f, 0.5f, 0.0f},
};

GLfloat vertexes[] = {
    
    -0.5f, -0.5f, 0.0f,
    0.5f, -0.5f, 0.0f,
    0.0f, 0.5f, 0.0f
};

@interface ViewController ()

@property (nonatomic,strong)GLKBaseEffect * effect;
@property (nonatomic,strong)EAGLContext * context;

@end

@implementation ViewController{
    
    GLuint _vertexBuffber;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 获取控制器的view
    GLKView * glView = (GLKView *)self.view;
    // 设置当前的context
    EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (nil == context) {
        NSLog(@"context create failed");
    }
    self.context = context;
    glView.context = context;
    
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"set currentContext failed");
    }
    // 创建GLKBaseEffect
    self.effect = [[GLKBaseEffect alloc] init];
    // 设置使用的颜色
    self.effect.useConstantColor = GL_TRUE;
    self.effect.constantColor = GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f);
    // 设置清屏颜色
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    
    //    glGenBuffers(1, &_vertexBuffber);
    //    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffber);
    //    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_STATIC_DRAW);
    
    // 开启顶点
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    // 设置数据指针
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, vertexes);
    //    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), NULL);
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
