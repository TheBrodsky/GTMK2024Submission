shader_type canvas_item;

// --- Uniforms --- //
uniform vec4 barColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float progress : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float opacity : hint_range(0.0, 1.0, 0.01) = 0.3;
//uniform float angle: hint_range(0.0, 6.28318530718, 0.1308996939) = 0.785398163397;

void fragment() {
	vec4 tintColor = texture(TEXTURE, UV);
	
	if (1.0 - UV.y <= progress && tintColor.a != 0.0) {
		tintColor.rgb = mix(tintColor.rgb, barColor.rgb, opacity);
		tintColor.a = COLOR.a;
		
		COLOR = tintColor;
	}
}