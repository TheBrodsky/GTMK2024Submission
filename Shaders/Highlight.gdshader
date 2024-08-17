shader_type canvas_item;

// --- Uniforms --- //
uniform vec4 highlightColor: source_color = vec4(1.0, 1.0, 1.0, 0.25);

uniform float lineWidth: hint_range(0.0, 2.0, 0.01) = 0.1;
uniform float angle: hint_range(0.0, 6.28318530718, 0.1308996939) = 0.785398163397;

uniform float speed: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float waitCycles: hint_range(0.0, 10.0, 0.1) = 1.0;

// --- Functions --- //
vec2 RotatePrecalculated(vec2 _pos, float _sine, float _cosine) {
	return vec2(_pos.x * _cosine + _pos.y * -_sine, _pos.x * _sine + _pos.y * _cosine);
}

void fragment() {
	float sine = sin(angle);
	float cosine = cos(angle);
	float len = 1.5 - max(abs(sine), abs(cosine)) + lineWidth;
		float line = smoothstep(-lineWidth, lineWidth, 
			RotatePrecalculated((UV - vec2(0.5)), sine, cosine).y - mod(TIME * speed, (len * 2.0) * waitCycles) + len);
	COLOR.rgb += highlightColor.rgb * highlightColor.a * vec3(line * (1.0 - line) * 4.0);
}
