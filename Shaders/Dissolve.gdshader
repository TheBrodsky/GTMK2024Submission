shader_type canvas_item;

// --- Uniforms --- //
uniform float progress: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform sampler2D noise_texture;

group_uniforms color_1;
uniform vec4 color_1: source_color = vec4(0.192, 0.075, 0.129, 1.0);
uniform float size_1 = 0.05;

group_uniforms color_2;
uniform vec4 color_2: source_color = vec4(0.298, 0.188, 0.204, 1.0);
uniform float size_2 = 0.05;

group_uniforms color_3;
uniform vec4 color_3: source_color = vec4(0.49, 0.333, 0.333, 1.0);
uniform float size_3 = 0.05;

// --- Functions --- //
void fragment() {
	float noise = texture(noise_texture, UV).r * (1.0 - (size_1 + size_2 + size_3 + 0.01));

	COLOR.a -= step(progress, noise);
	COLOR.rgb = mix(COLOR.rgb, color_3.rgb, step(progress, noise + size_1 + size_2 + size_3));
	COLOR.rgb = mix(COLOR.rgb, color_2.rgb, step(progress, noise + size_1 + size_2));
	COLOR.rgb = mix(COLOR.rgb, color_1.rgb, step(progress, noise + size_1));
}
