include Base;

#name AAA;

program vertex vert;
program fragment frag;

struct InOut {
	float4 texCoord;
}

struct MRT {
	float4 rt0 : COLOR0;
	float4 rt1 : COLOR1;
}

float4 vert (InOut out) {
	out.texCoord = TC_BUF;
	
	return VERT_BUF;
}

MRT frag (InOut in) {
	float4 color = tex(in.texCoord.xy, DIFF_TEX);
	
	MRT mrt;
	mrt.rt0 = float4(1, 0, 1, 1);
	mrt.rt1 = float4(1, 0, 0, 1);
	
	return mrt;
}