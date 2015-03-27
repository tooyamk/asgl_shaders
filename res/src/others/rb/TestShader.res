include Base;

#name TestShader;

program vertex vert;
program fragment frag;

struct InOut {
	float4 texCoord;
}

float4 vert (InOut out) {
	out.texCoord = VERT_BUF.zwww;
	
	float4 pos = VERT_BUF.xyyy;
	pos.zw = 1;
	
	return pos;
}

float4 frag (InOut in) {
	float4 color = tex(in.texCoord.xy, SRC_TEX);
	float a = color.w == 1;
	float b = color.w > 0 && color.w < 1;
	float4 c = if(a, float4(1, 1, 1, 1), color);
	c = if(b, float4(1, 0, 0, 1), c);
	c = if(color.w == 0, float4(0, 0, 0, 1), c);
	
	return c;
}