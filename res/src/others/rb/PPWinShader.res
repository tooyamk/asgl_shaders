include Base;

#name PPWinShader;

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
	color = if(color.w == 0, 0, color + ADD_COLOR);
	color.xyz *= color.w;
	
	return color;
}