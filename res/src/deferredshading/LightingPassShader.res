include Base;
include Codec;
include Lighting;

#name LightingPassShader;

#compile each LIGHT0<0 to 3>, LIGHT1<0 to 3>;
//#compile each LIGHT0<2>;

program vertex vert;
program fragment frag;

property Texture GBufferTex0 {name = "GBuffer Texture0";}
property Texture GBufferTex1 {name = "GBuffer Texture1";}

/*
 global :
 	color * intensity (x0, y0, z0)
 directional :
 	world lightingDir (x1, y1, z1)
 point :
 	world pos (x1, y1, z1), range (w1)
 spot :
 	half angle (w0)
 	world lightingDir (x1, y1, z1)
 	world pos (x2, y2, z2), range (w2)
*/
property Constants lightingFragAtt0 {name = "Lighting0 Fragment Attributes0"; length = 3; values = [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0];}
property Constants lightingFragAtt1 {name = "Lighting0 Fragment Attributes1"; length = 3; values = [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0];}

struct InOut {
	float4 value;
}

#define LIGHTING_FRAG(lightingType, factor, worldNormal, lightingAtt, worldVertex, shininess) {
	//float3 lightingColor = constant(lightingAtt).xyz;
	//float4 specAtt = constant(specularAttributes);

#ifdef lightingType 0;	
#elseif lightingType 1;
	float3 lightingDir = constant(lightingAtt, 1).xyz;
	float df = diffuseFactor(worldNormal, lightingDir);
	factor.xyz += constant(lightingAtt).xyz * df;
	float3 viewDir = normalize(VIEW_WPOS.xyz - worldVertex.xyz);
	factor.w += blinnPhoneSpecularFactor(worldNormal, lightingDir, viewDir, shininess);
#elseif lightingType 2;
	float3 lightingDir = constant(lightingAtt, 1).xyz - worldVertex.xyz;
	float intensity = 1 - min(length(lightingDir) / constant(lightingAtt, 1).w, 1);
	lightingDir = normalize(lightingDir);
	float df = diffuseFactor(worldNormal, lightingDir);
	factor.xyz += constant(lightingAtt).xyz * df * intensity;
	float3 viewDir = normalize(VIEW_WPOS.xyz - worldVertex.xyz);
	factor.w += intensity * blinnPhoneSpecularFactor(worldNormal, lightingDir, viewDir, shininess);
#elseif lightingType 3;
	float3 lightingDir = constant(lightingAtt, 2).xyz - worldVertex.xyz;
	float intensity = 1 - min(length(lightingDir) / constant(lightingAtt, 1).w, 1);
	lightingDir = normalize(lightingDir);
	float inRange = acos(dot(constant(lightingAtt, 1).xyz, lightingDir)) <= constant(lightingAtt).w;
	intensity *= inRange;
	float df = diffuseFactor(worldNormal, lightingDir);
	factor.xyz += constant(lightingAtt).xyz * df * intensity;
	float3 viewDir = normalize(VIEW_WPOS.xyz - worldVertex.xyz);
	factor.w += intensity * blinnPhoneSpecularFactor(worldNormal, lightingDir, viewDir, shininess));
#endif lightingType;
}

float4 vert (InOut out) {
	float4 data = VERT_BUF;
	out.value = data;
	
	float4 pos = data.xyyy;
	pos.zw = 1;
	
	return pos;
}

float4 frag (InOut in) {
	float4 color = tex(in.value.zw, GBufferTex0);
	
	float3 nrm = normalize(decodeNormalFromColor3(color.xyz));
	float shininess = color.w * 255;
	float4 factor = 0;
	
	float4 pos = 1;
	pos.xy = in.value.xy;
	pos.z = decodeFloatFromColor4(tex(in.value.zw, GBufferTex1));
	pos = m44(pos, M44_P2W);
	pos /= pos.w;
	
	LIGHTING_FRAG(LIGHT0, factor, nrm, lightingFragAtt0, pos, shininess)
	LIGHTING_FRAG(LIGHT1, factor, nrm, lightingFragAtt1, pos, shininess)
	//factor.xyz = nrm;
	//factor.w = 1;
	return factor;
}