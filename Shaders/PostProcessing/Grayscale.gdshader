shader_type canvas_item;

//uniform bool isOn = false;
//uniform float brightness: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec3 grayScale = vec3(0.2126, 0.7152, 0.0722);
	COLOR = vec4( vec3(dot(color.rgb , grayScale)), color.a);
}