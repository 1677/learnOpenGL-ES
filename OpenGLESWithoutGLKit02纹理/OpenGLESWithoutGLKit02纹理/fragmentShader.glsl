precision mediump float; // 声明精度
// 声明色彩变量
varying vec2 outTextTureCoord;
// 传递图片数据
uniform sampler2D myTexture;

void main()
{
    vec4 color = texture2D(myTexture, outTextTureCoord);
    // 通过纹理坐标数据来获取对应坐标色值并传递
    gl_FragColor = vec4(color.rgb, 1.0);
    
}
