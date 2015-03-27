include Base;
include Math;

#name BatchCoolDownShader;

program vertex vert;
program fragment frag;

property Buffer dataBuffer0 {name = "World Vertex (x, y, z)";}
property Buffer dataBuffer1 {name = "Tex Coord And Alpha (x, y, z)";}

property Texture diffuseTex {name = "Diffuse Texture";}

property Constants coolDownAtt {name = "Cool Down Attributes"; length = 3; values = [0, 0, 0, 0, 0.5, 0.5, 0.5, 1, 1, 1, 1, 1];}

struct InOut {
	float4 pos;
	float4 data;
}

float4 vert (InOut out) {
	out.data = attribute(dataBuffer1);
	
	float4 pos = m44(attribute(dataBuffer0), M44_W2P);
	out.pos = pos / pos.w;
	
	return pos;
}

float4 frag (InOut in) {
	float4 color = tex(in.data.xy, diffuseTex);
	color.w *= in.data.z;
	
	float2 dir = in.pos.xy - constant(coolDownAtt).xy;
	float a = atan2(dir.x, dir.y);
	a = if(a < 0, PI2 + a, a);
	
	float4 b = if(a >= constant(coolDownAtt).z, constant(coolDownAtt, 1), constant(coolDownAtt, 2));
	color *= b;
	
	return color;
}