attribute vec4 myPosition; // 顶点位置
// 输入的色彩
attribute vec2 textureCoord;
// 输出的色彩
varying vec2 outTextTureCoord;

void main()
{
    gl_Position = myPosition; // 传递顶点位置数据
    outTextTureCoord = textureCoord; // 传递色彩数据
}
