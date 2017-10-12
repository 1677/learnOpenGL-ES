attribute vec4 myPosition;

attribute vec2 myTextureCoordsIn;

varying vec2 myTextureCoordsOut;

uniform mat4 modelView;
uniform mat4 projection;

void main()
{
    gl_Position = projection * modelView * myPosition;
    myTextureCoordsOut = myTextureCoordsIn;
}


