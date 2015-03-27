include Base;

#name BufferQuadShader;

#compile each COLOR_FILTER<0 to 2>;

program vertex vert;
program fragment frag;

property Buffer dataBuffer0 {name = "World Vertex (x, y, z)";}
property Buffer dataBuffer1 {name = "Tex Coord And Alpha (x, y, z)";}

property Texture diffuseTex {name = "Diffuse Texture";}

struct InOut {
	float4 data;
}

float4 vert (InOut out) {
	out.data = attribute(dataBuffer1);
	
	return m44(attribute(dataBuffer0), M44_L2P);
}

float4 frag (InOut in) {
	float4 color = tex(in.data.xy, diffuseTex) * COLOR_ATT;
	
#ifdef COLOR_FILTER 0;
#elseif COLOR_FILTER 1;
	color += ADD_COLOR;
#elseif COLOR_FILTER 2;
	color *= MUL_COLOR;
#endif COLOR_FILTER;
	
	return color;
}