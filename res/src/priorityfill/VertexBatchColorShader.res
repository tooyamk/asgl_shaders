include Base;

#name VertexBatchColorShader;

program vertex vert;
program fragment frag;

property Buffer dataBuffer0 {name = "World Vertex (x, y, z)";}
property Buffer dataBuffer1 {name = "Color (x, y, z, w)";}

struct InOut {
	float4 data;
}

float4 vert (InOut out) {
	out.data = attribute(dataBuffer1);
	
	return m44(attribute(dataBuffer0), M44_W2P);
}

float4 frag (InOut in) {
	return in.data;
}