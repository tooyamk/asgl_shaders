include Base;
include Codec;
include Geom;
include Lighting;

#name LightingNrmSpecMeshShader;

#compile each LIGHT0<0 to 3>, LIGHT1<0 to 3>, SHADOW0<0 to 1>, SHADOW1<0 to 1>;

program vertex vert;
program fragment frag;

property Texture shadowTex0 {name = "Shadow Texture";}
property Texture shadowTex1 {name = "Shadow Texture";}

property Constants specularAttributes {name = "Specular Attributes"; length = 1; values = [32, 0, 0, 0];}

/*
 ambient (x0), depth offset (y0)
*/
property Constants lightingGlobalFragAtt {name = "Lighting Global Fragment Attributes"; length = 1; values = [0.2, 0.2, 0.2, -0.005];}

/*
 (
 directional : 
 	world lightingDir (x0, y0, z0)
 )
 point :
 	world pos (x0, y0, z0), range (w0)
 spot :
 	world pos (x0, y0, z0), range (w0)
*/
property Constants lightingVertAtt0 {name = "Lighting Vertex Attributes0"; length = 1; values = [0, 0, 0, 0];}
property Constants lightingVertAtt1 {name = "Lighting Vertex Attributes1"; length = 1; values = [0, 0, 0, 0];}

/*
 global :
 	color * intensity (x0, y0, z0)
 [
 directional :
 	world lightingDir (x1, y1, z1)
 ]
 spot :
 	half angle (w0)
 	world lightingDir (x1, y1, z1)
*/
property Constants lightingFragAtt0 {name = "Lighting Fragment Attributes0"; length = 2; values = [1, 1, 1, 0, 0, 0, 0, 0];}
property Constants lightingFragAtt1 {name = "Lighting Fragment Attributes1"; length = 2; values = [1, 1, 1, 0, 0, 0, 0, 0];}

property Constants worldToLightMatrix0 {name = "World To Light Matrix0"; length = 4;}
property Constants worldToLightMatrix1 {name = "World To Light Matrix1"; length = 4;}

struct InOut {
	float4 texCoord;
	float4 pos;
	float4 lighting0Att0;
	float4 lighting0Att1;
	float4 lighting1Att0;
	float4 lighting1Att1;
}

#define LIGHTING_VERT(lightingType, worldVertex, t, b, n, lightingAtt, out, outLightingAtt0, outLightingAtt1) {
	float4 att = constant(lightingAtt);
	
#ifdef lightingType 0;
#elseif lightingType 1;
	float3 lihgtingDir = att.xyz;
	out.outLightingAtt0.x = dot(t, lihgtingDir);
	out.outLightingAtt0.y = dot(b, lihgtingDir);
	out.outLightingAtt0.z = dot(n, lihgtingDir);
	out.outLightingAtt0.w = 1;

	float3 eyeDir = VIEW_WPOS - worldVertex;
	out.outLightingAtt1.x = dot(t, eyeDir);
	out.outLightingAtt1.y = dot(b, eyeDir);
	out.outLightingAtt1.z = dot(n, eyeDir);
	out.outLightingAtt1.w = 1;
#elseif lightingType 2;
	float3 lihgtingDir = att.xyz - worldVertex.xyz;
	out.outLightingAtt0.x = dot(t, lihgtingDir);
	out.outLightingAtt0.y = dot(b, lihgtingDir);
	out.outLightingAtt0.z = dot(n, lihgtingDir);
	out.outLightingAtt0.w = 1 - min(length(lihgtingDir) / att.w, 1);
	
	float3 eyeDir = VIEW_WPOS - worldVertex;
	out.outLightingAtt1.x = dot(t, eyeDir);
	out.outLightingAtt1.y = dot(b, eyeDir);
	out.outLightingAtt1.z = dot(n, eyeDir);
	out.outLightingAtt1.w = 1;
#elseif lightingType 3;
	float3 lihgtingDir = att.xyz - worldVertex.xyz;
	out.outLightingAtt0.x = dot(t, lihgtingDir);
	out.outLightingAtt0.y = dot(b, lihgtingDir);
	out.outLightingAtt0.z = dot(n, lihgtingDir);
	out.outLightingAtt0.w = 1 - min(length(lihgtingDir) / att.w, 1);
	
	float3 eyeDir = VIEW_WPOS - worldVertex;
	out.outLightingAtt1.x = dot(t, eyeDir);
	out.outLightingAtt1.y = dot(b, eyeDir);
	out.outLightingAtt1.z = dot(n, eyeDir);
	out.outLightingAtt1.w = 1;
#endif lightingType;
}

#define SHADOW_FRAG(shadowEnable, totalFactor, curFactor, depthTex, worldToLightMatrix) {
#ifdef shadowEnable 0;
#elseif shadowEnable 1;
	float4 pos = m44(in.pos, constant(worldToLightMatrix));
	pos /= pos.w;
	float2 tc = projPosToTexcoord(pos.xy);
	float depth = decodeFloatFromColor4(tex(tc, depthTex));
	float hasShadow = (pos.z + constant(lightingGlobalFragAtt).w) > depth;
	curFactor = if(hasShadow, 0, curFactor);
#endif shadowEnable;

	totalFactor += curFactor;
}

#define LIGHTING_FRAG(lightingType, factor, normal, specFactor, lightingAtt, inLightingAtt0, inLightingAtt1, shadowEnable, depthTex, worldToLightMatrix) {
	//float3 lightingColor = constant(lightingAtt).xyz;
	//float4 specAtt = constant(specularAttributes);

#ifdef lightingType 0;
#elseif lightingType 1;
	float3 lightingDir = normalize(in.inLightingAtt0.xyz);
	float df = diffuseFactor(normal, lightingDir);
	float sf = specFactor * blinnPhoneSpecularFactor(normal, lightingDir, normalize(in.inLightingAtt1.xyz), constant(specularAttributes).x);
	float3 curFactor = constant(lightingAtt).xyz * (df + sf);
	
	SHADOW_FRAG(shadowEnable, factor, curFactor, depthTex, worldToLightMatrix);
#elseif lightingType 2;
	float3 lightingDir = normalize(in.inLightingAtt0.xyz);
	float df = diffuseFactor(normal, lightingDir);
	float sf = specFactor * blinnPhoneSpecularFactor(normal, lightingDir, normalize(in.inLightingAtt1.xyz), constant(specularAttributes).x);
	float3 curFactor = constant(lightingAtt).xyz * in.inLightingAtt0.w * (df + sf);
	
	SHADOW_FRAG(shadowEnable, factor, curFactor, depthTex, worldToLightMatrix);
#elseif lightingType 3;
	float3 lightingDir = normalize(in.inLightingAtt0.xyz);
	float inRange = acos(dot(constant(lightingAtt, 1).xyz, lightingDir)) <= constant(lightingAtt).w;
	float df = diffuseFactor(normal, lightingDir);
	float sf = specFactor * blinnPhoneSpecularFactor(normal, lightingDir, normalize(in.inLightingAtt1.xyz), constant(specularAttributes).x);
	float3 curFactor = (constant(lightingAtt).xyz * in.inLightingAtt0.w * (df + sf)) * inRange;
	
	SHADOW_FRAG(shadowEnable, factor, curFactor, depthTex, worldToLightMatrix);
#endif lightingType;
}

float4 vert (InOut out) {
	out.texCoord = transformTexCoord(TC_BUF, DIFF_TEX_MATRIX_CONST);
	
	float3 normal = m33(NRM_BUF.xyz, M34_L2W);
	float3 tangent = m33(TAN_BUF.xyz, M34_L2W);
	float3 binormal = cross(normal, tangent);
	
	float4 pos.xyz = m34(VERT_BUF, M34_L2W);
	pos.w = 1;
	
	out.pos = pos;
	
	LIGHTING_VERT(LIGHT0, pos, tangent, binormal, normal, lightingVertAtt0, out, lighting0Att0, lighting0Att1)
	LIGHTING_VERT(LIGHT1, pos, tangent, binormal, normal, lightingVertAtt1, out, lighting1Att0, lighting1Att1)
	
	return m44(pos, M44_W2P);
}

float4 frag (InOut in) {
	float4 color = tex(in.texCoord.xy, DIFF_TEX) * COLOR_ATT;
	
	float4 nrmColor = tex(in.texCoord.xy, NRM_TEX);
	float3 nrm = decodeNormalFromColor3(nrmColor.xyz);
	float specFactor = nrmColor.w;
	
	float3 factor = constant(lightingGlobalFragAtt).xyz;
	
	LIGHTING_FRAG(LIGHT0, factor, nrm, specFactor, lightingFragAtt0, lighting0Att0, lighting0Att1, SHADOW0, shadowTex0, worldToLightMatrix0)
	LIGHTING_FRAG(LIGHT1, factor, nrm, specFactor, lightingFragAtt1, lighting1Att0, lighting1Att1, SHADOW1, shadowTex1, worldToLightMatrix1)
	
	color.xyz *= factor;
	
	return color;
}