include Base;

#name ConstantBatchShader;

program vertex vert;
program fragment frag;

property Buffer dataBuffer0 {name = "Index (x is vertex, y is texCoord And Alpha)";}

property Constants batchData {name = "Batch Data"; length = *;}

struct InOut {
	float4 data;
}

float4 vert (InOut out) {
	out.data = constant(batchData, attribute(dataBuffer0).x, 1);
	
	return m44(constant(batchData, attribute(dataBuffer0).x), M44_W2P);
}

float4 frag (InOut in) {
	float4 color = tex(in.data.xy, DIFF_TEX);
	color.w *= in.data.z;
	return color;
}