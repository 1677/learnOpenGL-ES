//
//  ViewController.m
//  openGLESGLKit06
//
//  Created by 刘晓亮 on 2017/8/23.
//  Copyright © 2017年 刘晓亮. All rights reserved.
//


#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
@interface ViewController ()

@property(nonatomic, strong)EAGLContext * context;
@property(nonatomic, strong)GLKSkyboxEffect * skyboxEffect;
@property(nonatomic,assign)GLint degreeX;
@property(nonatomic,assign)GLint degreeY;

@end

@implementation ViewController{
    
    GLKMatrix4 _modelMatrix;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    GLKView * glView = (GLKView *)self.view;
    EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!context) {
        NSLog(@"创建context失败");
    }
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"设置当前context失败");
    }
    
    glView.context = context;
    glView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    

    self.skyboxEffect = [[GLKSkyboxEffect alloc] init];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"];
    NSError * error;
    GLKTextureInfo * textureInfo = [GLKTextureLoader cubeMapWithContentsOfFile:path options:nil error:&error];
    
    self.skyboxEffect.textureCubeMap.name = textureInfo.name;
    self.skyboxEffect.xSize = 0.3;
    self.skyboxEffect.ySize = 0.3;
    self.skyboxEffect.zSize = 0.3;
    
    
    glClearColor(1.0, 0.0, 0.0, 1.0);
    
    GLfloat aspect = self.view.frame.size.width / self.view.frame.size.height;
    
    self.skyboxEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), aspect, 0.1f, 400.0f);
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch * touch = touches.anyObject;
    CGPoint currentPoint = [touch locationInView:self.view];
    CGPoint previousPoint = [touch previousLocationInView:self.view];
    
    self.degreeX += previousPoint.x - currentPoint.x;
    self.degreeY += previousPoint.y - currentPoint.y;
}


- (void)update{
    
    _modelMatrix = GLKMatrix4RotateX(GLKMatrix4Identity, GLKMathDegreesToRadians(self.degreeY % 360));
    
    _modelMatrix = GLKMatrix4RotateY(_modelMatrix, GLKMathDegreesToRadians(self.degreeX % 360));
    
    self.skyboxEffect.transform.modelviewMatrix = _modelMatrix;
}



- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClear(GL_COLOR_BUFFER_BIT);
    [self.skyboxEffect prepareToDraw];
    [self.skyboxEffect draw];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
