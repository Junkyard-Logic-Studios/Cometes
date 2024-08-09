//----- general settings -----//

shader_type spatial;
render_mode 
	depth_draw_always, 
	cull_front, 
	skip_vertex_transform, 
	shadows_disabled, 
	unshaded, 
	ambient_light_disabled;



//----- vertex shader -----//

// variables to be queried form vertex to fragment shader
varying flat vec3 rayOrigin;
varying vec3 rayDir;
varying vec3 vert;

// per vertex shader
void vertex()
{
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.)).xyz;
	rayOrigin = (INV_VIEW_MATRIX * vec4(0, 0, 0, 1)).xyz;
	rayDir = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz - rayOrigin;
}



//----- raytracing functions -----//

const float infinity = 1.0 / 0.0;

struct object_t {
	int type;
	vec3 pos;
	vec3 size;
};

const object_t objects[] = {
	//object_t(0, vec3(4, 5, 10), vec3(4)),
	object_t(0, vec3(4, 5, 10), vec3(4)),
	object_t(0, vec3(10, 2, -12), vec3(8)),
	object_t(0, vec3(-10, -12, 13), vec3(5, 3, 8))
};
const int n_objects = 3;

uniform vec3 worldSize = vec3(100, 100, 100);
uniform float maxDistance = 100.0;
uniform int maxSteps = 3;
uniform float minHitDistance = 0.001;


vec3 clampToWorld(vec3 pos)
{
	return mod(pos + worldSize * 1.5, worldSize) - worldSize * 0.5;
}

float intersectSphere(vec3 pos, vec3 dir, vec3 spherePos, float radius)
{
	//vec3 diff = clampToWorld(spherePos - pos);
	vec3 diff = spherePos - pos;
	float d = dot(diff, dir);
	if (d < 0.0)
		return infinity;
	
	vec3 pt = diff - d * dir;
	float t = dot(pt, pt);
	float r = radius * radius - t;
	
	return (d * d) < r || r < 0.0 ? infinity : d - sqrt(r);
}

float intersectObject(vec3 pos, vec3 dir, object_t obj)
{
	switch (obj.type)
	{
		case 0: return intersectSphere(pos, dir, obj.pos, obj.size.x);
	}
}

float intersectWorldBox(vec3 pos, vec3 dir)
{
	vec3 refPoint = 0.5 * dir / abs(dir) * worldSize;
	vec3 steps = (refPoint - pos) / dir;
	float minSteps = min(steps.x, min(steps.y, steps.z));
	return length(dir * minSteps);
}

struct RayHitInfo
{
	float dist;
	int objIndex;
	vec3 pos;
};

RayHitInfo rayTrace(vec3 pos, vec3 dir)
{
	float minDist = infinity;
	int objIndex = -1;
	
	float td = 0.0;
	for (int steps = 0; steps < maxSteps; steps++)
	{
		for (int i = 0; i < n_objects; i++)
		{
			float dist = intersectObject(pos, dir, objects[i]);
			if (dist < minDist)
			{
				minDist = dist;
				objIndex = i;
			}
		}
		if (objIndex != -1)
			break;
		
		float dist = intersectWorldBox(pos, dir);
		pos = clampToWorld(pos + dist * dir);
		pos += 0.01 * dir;
		td += dist;
	}
	
	return RayHitInfo(td + minDist, objIndex, pos + minDist * dir);
}



//----- fragment shader -----//

// per fragment shader
void fragment()
{
	vec3 rayDirection = normalize(rayDir);
	
	// find ray intersection with scene
	RayHitInfo hit = rayTrace(rayOrigin, rayDirection);
	float rayLength = hit.dist;
	
	// found no intersections with the scene
	if (rayLength > maxDistance)
		discard;
	
	// point of intersection
	//vec3 hitPoint = rayOrigin + rayDirection * rayLength;
	vec3 hitPoint = hit.pos;
	
	// basic shading
	vec3 hitPointNormal = normalize(hitPoint - objects[hit.objIndex].pos);
	ALBEDO = vec3(0.8, 0.4, 0.2) * dot(-rayDirection, hitPointNormal) / sqrt(rayLength);

	// calculate depth
	float depth = 1.0;
	vec4 viewSpaceHitPoint = VIEW_MATRIX * vec4(hitPoint, 1.0);
	vec4 clipSpaceHitPoint = PROJECTION_MATRIX * viewSpaceHitPoint;
	depth = clipSpaceHitPoint.z / clipSpaceHitPoint.w;

	DEPTH = depth < 0.0 ? 1.0 : depth;
	DEPTH = 0.0;
}



//----- light shader -----//

// per light source shader
void light() {}
