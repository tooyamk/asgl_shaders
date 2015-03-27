include Base;
include Geom;

#name LightingMeshShader;

program vertex vert;
program fragment frag;

property Buffer vertexBuffer {name = "Local Vertex (x, y z)";}
property Buffer texCoordBuffer {name = "TexCoord (x, y)";}

property Texture diffuseTex {name = "Diffuse Texture";}
property Texture lightingTex {name = "Lighting Texture";}

struct InOut {
	float4 value;
}

float4 vert (InOut out) {
	out.value.xyzw = attribute(texCoordBuffer).xyxy;
	
	float4 pos = m44(attribute(vertexBuffer), M44_L2P);
	pos /= pos.w;
	
	out.value.xy = projPosToTexcoord(pos.xy / pos.w);
	
	return pos;
}

float4 frag (InOut in) {
	float4 color = tex(in.value.zw, diffuseTex) * MUL_COLOR;
	float4 lighting = tex(in.value.xy, lightingTex);
	//color.xyz = lighting.w;
	lighting.xyz += lighting.w;
	color.xyz *= lighting.xyz;
	
	return color;
}