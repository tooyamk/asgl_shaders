include Base;
include Codec;

#name GBufferShader;

program vertex vert;
program fragment frag;

property Constants specularAttributes {name = "Specular Attributes"; length = 1; values = [32, 0, 0, 0];}

struct InOut {
	float4 value;
	float4 texCoord;
}

struct MRT {
	float4 rt0 : COLOR0;
	float4 rt1 : COLOR1;
	float4 rt2 : COLOR2;
}

float4 vert (InOut out) {
	float4 pos = m44(VERT_BUF, M44_L2P);
	pos /= pos.w;
	out.value.xyz = m33(NRM_BUF.xyz, M34_L2W);
	out.value.w = pos.z;
	out.texCoord = transformTexCoord(TC_BUF, DIFF_TEX_MATRIX_CONST);
	return pos;
}

MRT frag (InOut in) {
	MRT mrt;
	mrt.rt0 = constant(specularAttributes).x / 255;
	mrt.rt0.xyz = encodeNormalToColor3(in.value.xyz);
	mrt.rt1.xyzw = encodeFloatToColor4(in.value.w);
	mrt.rt2 = tex(in.texCoord.xy, DIFF_TEX) * MUL_COLOR;
	return mrt;
}