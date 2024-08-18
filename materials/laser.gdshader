//----- general settings -----//

shader_type spatial;
render_mode 
	depth_draw_always, 
	skip_vertex_transform, 
	shadows_disabled, 
	unshaded, 
	ambient_light_disabled;



//----- vertex shader -----//

uniform int warps = 5;
uniform vec3 world_size = vec3(0, 0, 0);

vec3 instanceOffset(int id)
{
	ivec3 v = ivec3(
		id % warps,
		id / warps % warps,
		id / (warps * warps)
	) - ivec3(warps / 2);
	return vec3(v) * world_size;
}

// variables to be queried form vertex to fragment shader
varying flat vec3 rayOrigin;
varying vec3 rayDir;
varying flat vec3 p1;
varying flat vec3 p2;

// per vertex shader
void vertex()
{
	// prepare offset model matrix
	mat4 model_matrix = MODEL_MATRIX;
	model_matrix[3] += vec4(instanceOffset(INSTANCE_ID), 0.);
	
	// vertex local to worldspace transform
	VERTEX.y += .1;
	VERTEX = (model_matrix * vec4(VERTEX, 1.)).xyz;
	
	// calculate ray parameters
	rayOrigin = INV_VIEW_MATRIX[3].xyz;
	rayDir = VERTEX - rayOrigin;
	
	// vertex worldspace to viewspace transform
	VERTEX = (VIEW_MATRIX * vec4(VERTEX, 1.)).xyz;
	
	// calculate laser line segment parameters
	p1 = (model_matrix[2] * -.35 + model_matrix[3]).xyz;
	p2 = (model_matrix[2] * .35 + model_matrix[3]).xyz;
}



//----- fragment shader -----//

uniform vec3 color = vec3(1.);
uniform float innerRadius = .1;
uniform float outerRadius = .2;


// function by bloxard (https://www.shadertoy.com/view/tslXRj)
float rayLineSegmentDistance(inout vec3 rP, vec3 rD, vec3 lS, vec3 lE)
{
	float bL = length(lE - lS);
	vec3 bD = (lE - lS) / bL;
	vec3 tD = lS - rP;
	float aDb = dot(rD, bD);
	float aDt = dot(rD, tD);
	float bDt = dot(bD, tD);
	float u = (aDt - bDt * aDb) / (1. - aDb * aDb);
	float v = max(min(u * aDb - bDt, bL), 0.);
	u = max(min(v * aDb + aDt, 1e6), 0.);
	rP += rD * u;
	return distance(rP, lS + bD * v);
}

float distanceToBrightness(float d, float minD, float maxD)
{
	d = (d - minD) / (maxD - minD);
	float f = pow(2.71828182846, -6. * d) - .00247875217;
	return max(f, .0);
}

// per fragment shader
void fragment()
{
	// calculate transparency from distance to laser line segment
	vec3 rayDirection = normalize(rayDir);
	vec3 rayPoint = rayOrigin;
	float d = rayLineSegmentDistance(rayPoint, rayDirection, p1, p2);
	ALPHA = distanceToBrightness(d, innerRadius, outerRadius);
	ALBEDO = color;
	
	// calculate depth
	float depth = DEPTH;
	vec4 clipSpaceHitPoint = PROJECTION_MATRIX * VIEW_MATRIX * vec4(rayPoint, 1.0);
	depth = clipSpaceHitPoint.z / clipSpaceHitPoint.w;
	DEPTH = depth < 0.0 ? 1.0 : depth;
}
