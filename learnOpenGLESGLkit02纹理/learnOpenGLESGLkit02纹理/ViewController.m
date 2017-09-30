//
//  ViewController.m
//  learnOpenGLESGLkit02纹理
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

typedef struct{
    GLKVector2 position;
} TextureCoord;

Vertex vertex[] = {
    
    {-0.5f, 0.5f, 0.0f}, // 左上
    {-0.5f, -0.5f, 0.0f}, // 左下
    {0.5f, -0.5f, 0.0f}, // 右下
    
    {-0.5f, 0.5f, 0.0f}, // 左上
    {0.5f, -0.5f, 0.0f}, // 右下
    {0.5f, 0.5f, 0.0f}, // 右上
};

TextureCoord textrueCoord[] = {
    
    {0.0f, 1.0f}, // 左上
    {0.0f, 0.0f}, // 左下
    {1.0f, 0.0f}, // 右下
    
    {0.0f, 1.0f}, // 左上
    {1.0f, 0.0f}, // 右下
    {1.0f, 1.0f}, // 右上
};

@interface ViewController ()

@property (nonatomic,strong)GLKBaseEffect * effect;

@end

@implementation ViewController

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
    
    // 加载纹理图片
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    NSError * error;
    
    CGImageRef image = [UIImage imageNamed:@"myImage"].CGImage;
    GLKTextureInfo * textureInfo = [GLKTextureLoader textureWithCGImage:image options:options error:&error];
    
    // 设置纹理可用
    self.effect.texture2d0.enabled = GL_TRUE;
    // 传递纹理信息
    self.effect.texture2d0.name = textureInfo.name;
    
    // 设置顶点
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, vertex);
    // 设置纹理坐标
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 2, textrueCoord);
    
    
    glClearColor(1.0, 1.0, 1.0, 1.0);
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
