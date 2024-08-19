shader_type canvas_item;

uniform bool isOn = false;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec3 gray_scale = vec3(0.2126, 0.7152, 0.0722);
	
	if(isOn) {
		COLOR = vec4( vec3(dot(color.rgb , gray_scale)), color.a);
	}
	else {
		COLOR = color;
	}
}