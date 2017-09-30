attribute vec4 myPosition;

uniform mat4 modelView;
uniform mat4 projection;

attribute vec2 textureCoordsIn;

varying vec2 textureCoordsOut;



void main()
{
    gl_Position = projection * modelView * myPosition;
    textureCoordsOut = textureCoordsIn;
}




