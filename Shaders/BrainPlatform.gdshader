shader_type canvas_item;

// --- Uniforms --- //
uniform vec4 base_color: source_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform vec4 highlight_color: source_color = vec4(1.0, 1.0, 1.0, 0.25);

uniform float line_Width: hint_range(0.0, 2.0, 0.01) = 0.1;
uniform float angle: hint_range(0.0, 6.28318530718, 0.1308996939) = 0.785398163397;

uniform float speed: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float wait_cycles: hint_range(0.0, 10.0, 0.1) = 1.0;

// --- Functions --- //
vec2 RotatePrecalculated(vec2 _pos, float _sine, float _cosine) {
	return vec2(_pos.x * _cosine + _pos.y * -_sine, _pos.x * _sine + _pos.y * _cosine);
}

void fragment() {
	float sine = sin(angle);
	float cosine = cos(angle);
	float len = 1.5 - max(abs(sine), abs(cosine)) + line_Width;
		float line = smoothstep(-line_Width, line_Width, 
			RotatePrecalculated((UV - vec2(0.5)), sine, cosine).y - mod(TIME * speed, (len * 2.0) * wait_cycles) + len);
	
	// Apply the highlight effect
    vec3 highlight_effect = highlight_color.rgb * highlight_color.a * vec3(line * (1.0 - line) * 4.0);

    // Combine original color with highlight and emissive effects
    COLOR.rgb = base_color.rgb + highlight_effect;
	COLOR.a = base_color.a * highlight_color.a * (3.0*line);
}


