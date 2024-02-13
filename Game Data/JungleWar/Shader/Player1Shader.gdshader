shader_type canvas_item;

uniform vec4 newColorBody : source_color;
uniform vec4 oldColorBody : source_color;
uniform vec4 newColorEyes : source_color;
uniform vec4 oldColorEyes : source_color;
uniform vec4 newColor1 : source_color;
uniform vec4 oldColor1 : source_color;
uniform vec4 newColor2 : source_color;
uniform vec4 oldColor2 : source_color;


uniform float precision : hint_range (0.0, 1.0, 0.1);
uniform float onlyPickMainColor : hint_range (0.0, 1.0, 1.0);

float when_lt (float x, float y) {
	return max(sign(y - x), 0.0);
}

float and (float a, float b) {
	return a * b;
}

float not1 (float a) {
	return 1.0 - a;
}

float diff (float a, float b) {
	return a - b;
}

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec4 currentColor = texture(TEXTURE, UV);

	vec3 currentHSV = rgb2hsv(oldColorBody.rgb);
	float currentV = currentHSV.z;
	vec3 newBodyHSV = rgb2hsv (newColorBody.rgb);
	float newBodyV = newBodyHSV.z;
	float diffV = diff(newBodyV, currentV);

	vec3 newColor1HSV = rgb2hsv(oldColor1.rgb);
	float newColor1V = newColor1HSV.z + diffV;
	newColor1HSV = vec3(newColor1HSV.x, newColor1HSV.y, newColor1V);
	vec3 newColor1RGB = hsv2rgb(newColor1HSV);

	vec3 newColor2HSV = rgb2hsv(oldColor2.rgb); 
	float newColor2V = newColor2HSV.z + diffV;
	newColor2HSV = vec3(newColor2HSV.x, newColor2HSV.y, newColor2V);
	vec3 newColor2RGB = hsv2rgb(newColor2HSV);


	COLOR = vec4 (0.0, 0.0, 0.0, 0.0);

	COLOR += newColorBody * when_lt(distance(currentColor, oldColorBody), precision);
	COLOR += newColorEyes * when_lt(distance(currentColor, oldColorEyes), precision);


	COLOR  += newColor1 * and(not1(onlyPickMainColor), when_lt(distance(currentColor, oldColor1), precision));
	COLOR  += newColor2 * and(not1(onlyPickMainColor), when_lt(distance(currentColor, oldColor2), precision));

	COLOR += vec4(newColor1RGB.r, newColor1RGB.g, newColor1RGB.b, newColor1.a) *
	and (onlyPickMainColor, when_lt(distance(currentColor, oldColor1), precision));
	COLOR += vec4(newColor2RGB.r, newColor2RGB.g, newColor2RGB.b, newColor2.a) *
	and (onlyPickMainColor, when_lt(distance(currentColor, oldColor2), precision));

	vec4 currentColorMod = COLOR;

	COLOR += currentColor * when_lt(distance(vec4(0.0, 0.0, 0.0, 0.0), currentColorMod), precision);
}
