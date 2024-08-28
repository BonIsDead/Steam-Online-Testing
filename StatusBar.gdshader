shader_type canvas_item;

// Distance the outline is from each pixel
uniform int outlineDistance = 1;
// Enables a scanline flicker effect
uniform bool scanlineEnabled = false;


void fragment() {
	// Get the texel size
	vec2 _texel = TEXTURE_PIXEL_SIZE;
	
	if (scanlineEnabled) {
		// Makes only one row of pixels appear at a time
		ivec2 _textureSize = textureSize(TEXTURE, 0);
		int _position = int(UV.y * float(_textureSize.y) );
		int _frame = int(TIME * 24.0) % 2;
		
		// Discard every other row
		if ( (_position % 2) == _frame) {
			discard;
		}
	}
	
	// Create an outline for each pixel
	float _outline = texture(TEXTURE, UV - vec2( (_texel.x * float(outlineDistance) ), 0) ).a;
	_outline += texture(TEXTURE, UV).a;
	_outline += texture(TEXTURE, UV + vec2( (_texel.x * float(outlineDistance) ), 0) ).a;
	_outline = min(_outline, 1.0);
	
	// Mix the outline with the original texture
	vec4 _texture = texture(TEXTURE, UV);
	vec4 _modulate = COLOR - vec4(1, 1, 1, 0);
	_texture = mix(_texture, vec4(0.0, 0.0, 0.0, 1.0) + _modulate, _outline - _texture.a);
	
	// Set final output color
	COLOR = _texture;
}
