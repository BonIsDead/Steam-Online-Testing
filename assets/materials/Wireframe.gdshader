shader_type spatial;
render_mode unshaded, wireframe;

// Color of the wireframe
uniform vec4 color:source_color = vec4(1.0);


void fragment() {
	ALBEDO = color.rgb;
	ALPHA = color.a;
}