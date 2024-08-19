shader_type canvas_item;

// --- Uniforms --- //
uniform vec4 bar_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float progress : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float opacity : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform bool is_horizontal = false;

void fragment() {
	vec4 tint_color = texture(TEXTURE, UV);
	
	if(is_horizontal) {
		if (1.0 - UV.x >= progress && tint_color.a != 0.0) {
		tint_color.rgb = mix(tint_color.rgb, bar_color.rgb, opacity);
		tint_color.a = COLOR.a;
		
		COLOR = tint_color;
		}
	}
	else {
		if (1.0 - UV.y <= progress && tint_color.a != 0.0) {
			tint_color.rgb = mix(tint_color.rgb, bar_color.rgb, opacity);
			tint_color.a = COLOR.a;
			
			COLOR = tint_color;
		}
	}
}