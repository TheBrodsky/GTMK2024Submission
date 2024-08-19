shader_type canvas_item;

// --- Uniforms --- //
uniform float shake_power : hint_range( 0.0, 0.01, 0.001 ) = 0.003;
uniform float shake_block_size = 25;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// --- Functions --- //

// generate a random number based on a seed
float random( float seed ) {
	return fract( 245.25 * sin( dot( vec2( seed, seed ), vec2( 3333.33, -54.54 ) ) ) );
}

void fragment( ) {
	vec2 fixed_uv = SCREEN_UV;
	// applies horizontal shake effect
	fixed_uv.x += ( random( (trunc( SCREEN_UV.y * shake_block_size ) / shake_block_size) + TIME) - 0.5) * shake_power;

	vec4 pixel_color = textureLod( SCREEN_TEXTURE, fixed_uv, 0.0 );
	COLOR = pixel_color;
}
