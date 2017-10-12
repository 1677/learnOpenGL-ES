precision mediump float;

uniform sampler2D myTexture;
uniform sampler2D samplerUV;

varying vec2 myTextureCoordsOut;

void main()
{
    // 用一个矩阵来简化后面YUV转GRB的计算公式
    mat3 conversionColor = mat3(1.164, 1.164, 1.164,
                                0.0, -0.213, 2.112,
                                1.793, -0.533, 0.0);

    mediump vec3 yuv;
    lowp vec3 rgb;

    yuv.x = texture2D(myTexture, myTextureCoordsOut).r - (16.0/255.0);
    yuv.yz = texture2D(samplerUV, myTextureCoordsOut).rg - vec2(0.5, 0.5);

    rgb = conversionColor * yuv;
    
    
    gl_FragColor = vec4(rgb, 1.0);
//    gl_FragColor = vec4(texture2D(myTexture, myTextureCoordsOut).rgb, 1.0);
}





