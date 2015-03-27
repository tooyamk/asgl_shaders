include Base;
include Math;

#name ColorParticleShader;

#compile each PARTICLE_ROTATE<0 to 1>, BILLBOARD<0 to 1>, MULTIPLIED_ALPHA<0 to 1>;

program vertex vert;
program fragment frag;

/*
 pos (x0, y0, z0), life cycle (w0)
*/
property Buffer vertexBuffer {name = "Local Vertex (x, y, z, w)";}

/*
 v0 (x0, y0, z0), start time (w0)
*/
property Buffer attributeBuffer0 {name = "Attribute0 (x, y, z, w)";}

/*
 area (x0, y0, z0), size (w0)
*/
property Buffer attributeBuffer1 {name = "Attribute1 (x, y, z, w)";}

/*
 rotation (x0, y0, z0)
*/
property Buffer attributeBuffer2 {name = "Attribute2 (x, y, z)";}

/*
 color (x0, y0, z0, w0)
*/
property Buffer colorBuffer0 {name = "Color1 (x, y, z, w)";}

/*
 color (x0, y0, z0, w0)
*/
property Buffer colorBuffer1 {name = "Color2 (x, y, z, w)";}

property Texture diffuseTex {name = "Diffuse Texture";}

/*
 total time (x0), isLoop(y0)
 a (x1, y1, z1)
*/
property Constants particleAttribute {name = "Particle Attribute"; length = 2;}
property Constants billboardMatrix {name = "Billboard Matrix"; length = 3;}

struct InOut {
	float4 color;
}

float4 vert (InOut out) {
	float t = constant(particleAttribute).x - attribute(attributeBuffer0).w;
	
#ifdef PARTICLE_ROTATE 0;
#elseif PARTICLE_ROTATE 1;
	float3 rotate = attribute(attributeBuffer2).xyz * t;
	float3 sinRotate = sin(rotate);
	float3 cosRotate = cos(rotate);
	float4 tempRotate;
	tempRotate.x = sinRotate.x * cosRotate.y;
	tempRotate.y = sinRotate.y * cosRotate.x;
	tempRotate.z = cosRotate.x * cosRotate.y;
	tempRotate.w = sinRotate.x * sinRotate.y;
	float4 quatRotate;
	quatRotate.x = tempRotate.x * cosRotate.z - tempRotate.y * sinRotate.z;
	quatRotate.y = tempRotate.y * cosRotate.z + tempRotate.x * sinRotate.z;
	quatRotate.z = tempRotate.z * sinRotate.z - tempRotate.w * cosRotate.z;
	quatRotate.w = tempRotate.z * cosRotate.z + tempRotate.w * sinRotate.z;
#endif PARTICLE_ROTATE;
	
	float once = t <= attribute(vertexBuffer).w;
	float active = t >= 0 && if(constant(particleAttribute).y, 1, once);
	
	t = frac(t / attribute(vertexBuffer).w);
	
	out.color = lerp(attribute(colorBuffer0), attribute(colorBuffer1), t);
	float lerpValue = lerp(1, attribute(attributeBuffer1).w, t);
	
	t = t * attribute(vertexBuffer).w;
	
#ifdef BILLBOARD 0;
	float4 lpos.xyz = attribute(attributeBuffer1).xyz * lerpValue;
#elseif BILLBOARD 1;
	float4 lpos.xyz = m33(attribute(attributeBuffer1).xyz * lerpValue, constant(billboardMatrix));
#endif BILLBOARD;
	
#ifdef PARTICLE_ROTATE 0;
#elseif PARTICLE_ROTATE 1;
	tempRotate.x = dot(quatRotate.wy, lpos.xz) - quatRotate.z * lpos.y;
	tempRotate.y = dot(quatRotate.wz, lpos.yx) - quatRotate.x * lpos.z;
	tempRotate.z = dot(quatRotate.wx, lpos.zy) - quatRotate.y * lpos.x;
	tempRotate.w = -dot(quatRotate.xyz, lpos.xyz);
	lpos.x = dot(quatRotate.wy, tempRotate.xz) - dot(quatRotate.xz, tempRotate.wy);
	lpos.y = dot(quatRotate.zw, tempRotate.xy) - dot(quatRotate.yx, tempRotate.wz);
	lpos.z = dot(quatRotate.xw, tempRotate.yz) - dot(quatRotate.zy, tempRotate.wx);
#endif PARTICLE_ROTATE;
	
	lpos.xyz += attribute(vertexBuffer).xyz + (attribute(attributeBuffer0).xyz + constant(particleAttribute, 1).xyz * t) * t;
	lpos.w = 1;
	
	float4 ppos = m44(lpos, M44_L2P);
	ppos.z = if(active, ppos.z, -1);
	
	return ppos;
}

float4 frag (InOut in) {
	float4 color = in.color * COLOR_ATT;
	
#ifdef MULTIPLIED_ALPHA 0;
#elseif MULTIPLIED_ALPHA 1;
	color.xyz *= color.w;
#endif MULTIPLIED_ALPHA;
	
	return color;
}