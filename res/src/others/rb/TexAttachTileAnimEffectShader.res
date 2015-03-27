include Base;
include Math;

#name TexAttachTileAnimEffectShader;

#compile each COLOR_FILTER<0 to 2>;

program vertex vert;
program fragment frag;

property Buffer dataBuffer0 {name = "World Vertex (x, y, z)";}
property Buffer dataBuffer1 {name = "Tex Coord And Alpha (x, y, z)";}

property Texture diffuseTex {name = "Diffuse Texture";}
property Texture effectTex {name = "Effect Texture";}

property Constants effectTexRegion {name = "Effect Texture Region"; length = 1; values = [0, 0, 1, 1];}

struct InOut {
	float4 data;
	float4 effectUV;
}

float4 vert (InOut out) {
	out.data = attribute(dataBuffer1);
	
	out.effectUV = attribute(dataBuffer1).w;
	float2 uv = invertTransformTexCoord(attribute(dataBuffer1).xy , DIFF_TEX_REGION);
	out.effectUV.xy = transformTexCoord(uv, constant(effectTexRegion));
	
	return m44(attribute(dataBuffer0), M44_W2P);
}

float4 frag (InOut in) {
	float4 color = tex(in.data.xy, diffuseTex);
	float4 color2 = tex(in.effectUV.xy, effectTex);
	color.w *= in.data.z;
	color2.w *= in.data.z;
	
	color = color2 * color2.w + color * (1 - color2.w);
	
#ifdef COLOR_FILTER 0;
#elseif COLOR_FILTER 1;
	color += ADD_COLOR;
#elseif COLOR_FILTER 2;
	color *= MUL_COLOR;
#endif COLOR_FILTER;
	
	return color;
}