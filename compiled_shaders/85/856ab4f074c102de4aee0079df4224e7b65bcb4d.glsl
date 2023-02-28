#define POSTPROCESSING_ENABLED
#define _ANDROID


#if defined(TEXTURE) || defined(VIDEO)
	uniform lowp sampler2D Texture0;
	varying mediump vec4 uv0Varying;
#endif
#ifdef VIDEO
	uniform sampler2D Texture1; // Y
	uniform sampler2D Texture2; // U
	uniform sampler2D Texture3; // V
#endif


varying lowp vec4 colorVarying;

#ifdef TEXTURE_ANIMATION
	uniform lowp vec4 AnimatedTextureFrameFactor;
#endif

void main()
{
	lowp vec4 color=colorVarying;

#ifdef VIDEO
	lowp float videoColorY = texture2D( Texture1, uv0Varying.xy ).x;
	lowp float videoColorU = texture2D( Texture2, uv0Varying.xy ).x;
	lowp float videoColorV = texture2D( Texture3, uv0Varying.xy ).x;

	videoColorY = 1.1643 * ( videoColorY - 0.0625 );
	videoColorU -= 0.5;
	videoColorV -= 0.5;

	// YUV to RGB color conversion
	lowp vec3 videoColor;
	videoColor.x = videoColorY + videoColorV * 1.5958;
	videoColor.y = videoColorY - videoColorU * 0.39173 - videoColorV * 0.81290;
	videoColor.z = videoColorY + videoColorU * 2.017;

	videoColor = clamp( videoColor, 0., 1. );
	color.xyz *= videoColor;
#endif

#ifdef TEXTURE
	lowp vec4 txt=texture2D(Texture0,uv0Varying.xy);
	#ifdef TEXTURE_ANIMATION
		lowp vec4 txt2=texture2D(Texture0,uv0Varying.zw);
		txt=mix(txt,txt2,AnimatedTextureFrameFactor.x);		
	#endif

	#ifdef ALPHA_ONLY_TEXTURE
		color.w*=txt.w;
	#elif defined(COLOR_ONLY_TEXTURE)
		color.xyz*=txt.xyz;
	#else
		color*=txt;
	#endif
#endif
	gl_FragColor=color;
}
