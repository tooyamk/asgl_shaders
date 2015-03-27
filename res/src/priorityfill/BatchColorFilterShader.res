include Base;

#name BatchColorFilterShader;

#compile each COLOR_FILTER<0 to 2>;

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
	color.w *= in.data.z;
	
#ifdef COLOR_FILTER 0;
#elseif COLOR_FILTER 1;
	color += ADD_COLOR;
#elseif COLOR_FILTER 2;
	color *= MUL_COLOR;
#endif COLOR_FILTER;
	
	return color;
}