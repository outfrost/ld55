shader_type canvas_item;
render_mode unshaded;

uniform float border_width = 1.0;
uniform vec2 rect_size;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment() {
	vec4 color = textureLod(screen_texture, SCREEN_UV, 3.0);
	color -= vec4(color.rgb * color.rgb * 0.25, 0.0);

	color = mix(color, vec4(0.078, 0.133, 0.251, 1.0), 0.5);

	vec4 vignette_color = vec4(1.0, 1.0, 1.0, 1.0);
	vec2 t = (UV - vec2(0.5, 0.5)) * 1.15;
	float vignette_rect = pow(distance(t, clamp(t, vec2(-0.45, -0.4), vec2(0.45, 0.4))), 1.4);

	color = mix(color, vignette_color, vignette_rect);

	float border_cutoff = border_width;
	float border_perc = 1.0 - step(border_cutoff, UV.x * rect_size.x);
	border_perc += 1.0 - step(border_cutoff, UV.y * rect_size.y);
	border_perc += 1.0 - step(border_cutoff, (1.0 - UV.x) * rect_size.x);
	border_perc += 1.0 - step(border_cutoff, (1.0 - UV.y) * rect_size.y);
	border_perc = clamp(border_perc, 0.0, 1.0);

	color.rgb = mix(color.rgb, vec3(0.0), border_perc);

	COLOR = color;
}
