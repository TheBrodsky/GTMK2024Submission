shader_type canvas_item;

// --- Uniforms --- //
uniform float shake_power : hint_range( 0.0, 0.01, 0.001 ) = 0.003;
uniform float shake_rate : hint_range( 0.0, 1.0, 0.01) = 0.2;
uniform float shake_speed = 5.0;
uniform float shake_block_size = 30.5;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

float random( float seed )
{
	return fract( 543.2543 * sin( dot( vec2( seed, seed ), vec2( 3525.46, -54.3415 ) ) ) );
}

void fragment( )
{
	float enable_shift = float(
		random( trunc( TIME * shake_speed ) )
	<	shake_rate
	);

	vec2 fixed_uv = SCREEN_UV;
	fixed_uv.x += (
		random(
			( trunc( SCREEN_UV.y * shake_block_size ) / shake_block_size )
		+	TIME
		) - 0.5
	) * shake_power * enable_shift;

	vec4 pixel_color = textureLod( SCREEN_TEXTURE, fixed_uv, 0.0 );
	COLOR = pixel_color;
}
