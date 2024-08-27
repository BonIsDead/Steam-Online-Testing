shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//ivec2 _textureSize = textureSize(TEXTURE, 0);
	vec2 _texel = TEXTURE_PIXEL_SIZE;
	//
	//int _position = int(UV.y * float(_textureSize.y) );
	//int _frame = int(TIME * 24.0) % 2;
	//
	//if ( (_position % 2) == _frame) {
		//discard;
	//}
	
	// Get the size of the pixels on screen, and create a variable for out outline
	vec2 size = _texel;
	
	float outline = texture(TEXTURE, UV - vec2(size.x, 0) ).a;
	outline += texture(TEXTURE, UV).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0) ).a;
	outline = min(outline, 1.0);
	
	// Get the texture from the screen
	vec4 tex = texture(TEXTURE, UV);
	vec4 modulate = COLOR - vec4(1, 1, 1, 0);
	tex = mix(tex, vec4(0.0, 0.0, 0.0, 1.0) + modulate, outline - tex.a);
	
	COLOR = tex;
}
