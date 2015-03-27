include Base;

#name MeshShader;

program vertex vert;
program fragment frag;

struct InOut {
	float4 texCoord;
}

float4 vert (InOut out) {
	out.texCoord = TC_BUF;
	out.texCoord.xy = transformTexCoord(TC_BUF.xy, DIFF_TEX_MATRIX_CONST);
	return m44(VERT_BUF, M44_L2P);
}

float4 frag (InOut in) {
	return tex(in.texCoord.xy, DIFF_TEX) * COLOR_ATT;
}