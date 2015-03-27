include Base;
include Codec;

#name DepthShader;

program vertex vert;
program fragment frag;

struct InOut {
	float4 position;
}

float4 vert (InOut out) {
	float4 pos = m44(VERT_BUF, M44_L2P);
	pos /= pos.w;
	out.position = pos;
	return pos;
}

float4 frag (InOut in) {
	return encodeFloatToColor4(in.position.z);
}