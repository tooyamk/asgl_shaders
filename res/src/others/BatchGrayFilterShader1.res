include Base;
include Filter;

#name BatchGrayFilterShader1;

program vertex vert;
program fragment frag;

property Buffer dataBuffer0 {name = "World Vertex (x, y, z)";}
property Buffer dataBuffer1 {name = "Tex Coord And Alpha (x, y, z)";}

struct InOut {
	float4 data;
}

float4 vert (InOut out) {
	out.data = attribute(dataBuffer1);
	
	return m44(attribute(dataBuffer0), M44_W2P);
}

float4 frag (InOut in) {
	float4 color = tex(in.data.xy, DIFF_TEX);
	color.xyz = color.x / 3 + color.y / 3 + color.z / 3;
	color.w *= in.data.z;
	
	return color;
}