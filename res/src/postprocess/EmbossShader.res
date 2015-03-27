include Base;
include Filter;

#name EmbossShader;

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
	return emboss(SRC_TEX, in.texCoord.xy, SRC_TEX_ATT_CONST, BG_COLOR);
}