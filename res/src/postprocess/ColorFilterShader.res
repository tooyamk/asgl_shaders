include Base;

#name ColorFilterShader;

#compile each COLOR_FILTER<0 to 2>;

program vertex vert;
program fragment frag;

struct InOut {
	float4 texCoord;
}

float4 vert (InOut out) {
	out.texCoord = VERT_BUF.zwww;
	
	float4 pos = VERT_BUF.xyyy;
	pos.zw = 1;
	
	return pos;
}

float4 frag (InOut in) {
	float4 color = tex(in.texCoord.xy, SRC_TEX);
	
#ifdef COLOR_FILTER 0;
#elseif COLOR_FILTER 1;
	color += ADD_COLOR;
#elseif COLOR_FILTER 2;
	color *= MUL_COLOR;
#endif COLOR_FILTER;
	
	return color;
}