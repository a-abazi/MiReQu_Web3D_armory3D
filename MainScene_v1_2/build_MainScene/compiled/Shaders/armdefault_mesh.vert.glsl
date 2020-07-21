#version 450
in vec4 pos;
in vec2 nor;
out vec3 wnormal;
out vec4 lightPosition;
out vec4 wvpposition;
out vec3 eyeDir;
out vec3 wposition;
uniform mat3 N;
uniform mat4 WVP;
uniform mat4 LWVP;
uniform vec3 eye;
uniform mat4 W;
void main() {
vec4 spos = vec4(pos.xyz, 1.0);
wposition = vec4(W * spos).xyz;
	wnormal = normalize(N * vec3(nor.xy, pos.w));
	gl_Position = WVP * spos;
	lightPosition = LWVP * spos;
	wvpposition = gl_Position;
	eyeDir = eye - wposition;
}
