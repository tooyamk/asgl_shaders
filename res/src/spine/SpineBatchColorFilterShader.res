include Base;

#name SpineBatchColorFilterShader;

#compile each COLOR_FILTER<0 to 2>;

program vertex vert;
program fragment frag;

property Buffer dataBuffer0 {name = "World Vertex(x, y, z)";}
property Buffer dataBuffer1 {name = "Tex Coord(x, y)";}
property Buffer dataBuffer2 {name = "Color (r, g, b, a)";}

struct InOut {
	float4 uv;
	float4 color;
}

float4 vert (InOut out) {
	out.uv = attribute(dataBuffer1).xyxy;
	out.color = attribute(dataBuffer2);
	
	return m44(attribute(dataBuffer0), M44_W2P);
}

float4 frag (InOut in) {
	float4 color = tex(in.uv.xy, DIFF_TEX);
	color *= in.color;
	
#ifdef COLOR_FILTER 0;
#elseif COLOR_FILTER 1;
	color += ADD_COLOR;
#elseif COLOR_FILTER 2;
	color *= MUL_COLOR;
#endif COLOR_FILTER;

	return color;
}