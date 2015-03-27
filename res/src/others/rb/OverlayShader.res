include Base;
include Filter;

#name OverlayShader;

program vertex vert;
program fragment frag;

property Constants blendColor {name = "Blend Color"; length = 1; values = [1, 1, 1, 1];}

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
	return overlay(tex(in.texCoord.xy, SRC_TEX), constant(blendColor));
}