include Base;

#name SkinnedMeshShader;

#compile each NUM_BLEND_BONE<0 to 4>;

program vertex vert;
program fragment frag;

property Constants boneData {name = "Bone Data"; length = *;}

struct InOut {
	float4 texCoord;
}

float4 vert (InOut out) {
	out.texCoord = TC_BUF;
	out.texCoord.xy = transformTexCoord(TC_BUF.xy, DIFF_TEX_MATRIX_CONST);
	
	float4 pos;
	
#ifdef NUM_BLEND_BONE 0;
	pos.xyz = VERT_BUF.xyz;
#elseif NUM_BLEND_BONE 1;
	pos.xyz = m34(VERT_BUF, constant(boneData, BONE_IDX_BUF.x)) * WT_BUF.x;
#elseif NUM_BLEND_BONE 2;
	pos.xyz = m34(VERT_BUF, constant(boneData, BONE_IDX_BUF.x)) * WT_BUF.x;
	pos.xyz += m34(VERT_BUF, constant(boneData, BONE_IDX_BUF.y)) * WT_BUF.y;
#elseif NUM_BLEND_BONE 3;
	pos.xyz = m34(VERT_BUF, constant(boneData, BONE_IDX_BUF.x)) * WT_BUF.x;
	pos.xyz += m34(VERT_BUF, constant(boneData, BONE_IDX_BUF.y)) * WT_BUF.y;
	pos.xyz += m34(VERT_BUF, constant(boneData, BONE_IDX_BUF.z)) * WT_BUF.z;
#elseif NUM_BLEND_BONE 4;
	pos.xyz = m34(VERT_BUF, constant(boneData, BONE_IDX_BUF.x)) * WT_BUF.x;
	pos.xyz += m34(VERT_BUF, constant(boneData, BONE_IDX_BUF.y)) * WT_BUF.y;
	pos.xyz += m34(VERT_BUF, constant(boneData, BONE_IDX_BUF.z)) * WT_BUF.z;
	pos.xyz += m34(VERT_BUF, constant(boneData, BONE_IDX_BUF.w)) * WT_BUF.w;
#endif NUM_BLEND_BONE;

	pos.w = 1;
	
	return m44(pos, M44_L2P);
}

float4 frag (InOut in) {
	return tex(in.texCoord.xy, DIFF_TEX) * COLOR_ATT;
}