include Base;
include Geom;

#name ShadingPassShader;

program vertex vert;
program fragment frag;

property Texture GBufferTex2 {name = "GBuffer Texture2";}
property Texture lightingTex {name = "Lighting Texture";}

/*
 ambient (x0, y0, z0), depth offset (w0)
*/
property Constants lightingGlobalFragAtt {name = "Lighting Global Fragment Attributes"; length = 1; values = [0.2, 0.2, 0.2, -0.005];}

struct InOut {
	float4 value;
}

float4 vert (InOut out) {
	float4 data = VERT_BUF;
	out.value = data;
	
	float4 pos = data.xyyy;
	pos.zw = 1;
	
	return pos;
}

float4 frag (InOut in) {
	float4 color = tex(in.value.zw, GBufferTex2);
	float4 lighting = tex(in.value.zw, lightingTex);
	//color.xyz = lighting.w;
	lighting.xyz += lighting.w * color.w;
	lighting.xyz += constant(lightingGlobalFragAtt).xyz;
	color.xyz *= lighting.xyz;
	color.w = 1;
	
	return color;
}