attribute vec4  myPosition;

uniform mat4 modelView;
uniform mat4 projection;

void main()
{
    gl_Position = projection * modelView * myPosition;
}



