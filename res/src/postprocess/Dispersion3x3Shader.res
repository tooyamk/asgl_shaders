include Base;
include Filter;

#name Dispersion3x3Shader;

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
	return dispersion33(SRC_TEX, in.texCoord.xy, SRC_TEX_ATT_CONST, FILTER_M33_CONST);
}