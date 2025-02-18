// A Mandelbrot set renderer.


shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;

// How many iterations to perform for each point before aborting.
uniform int max_steps = 5000;

// The distance between the center and the edges of the screen at default zoom.
const vec2 margin = vec2(2.5, 1.5);

// The palette to take the colors from.
uniform sampler2D palette;

// The coordinate represented by the center of the screen.
uniform vec2 center;

// The current zoom level.
uniform float zoom = 1.0;

uniform float x_mult = 1.0;
uniform float y_mult = 1.0;
uniform float threshold = 4.0;
uniform float strange_mult = 1.0;
uniform float a_var = 0.0;
uniform float b_var = 0.0;
uniform float c_var = 1.0;
uniform float d_var = 0.0;
uniform float e_var = 1.0;



// Calculates how many steps it takes for a point to escape to infitity
// (i.e. escape the circle with radius 2 around the origin)
// under the Mandelbrot map.
// If this returns max_steps, the point is considered to not escape to infinity,
// and thus be in the Mandelbrot set.

int mandelbrot_steps(float x, float y) {
	float orig_x = x;
	float orig_y = y;
	int i = 0;
	while (i++ < max_steps) {
		float x_squared = x * x * x_mult;
		float y_squared = y * y * y_mult;
		if (x_squared + y_squared > 4.0) {
			break;
		}
		float new_x = x_squared - y_squared + orig_x;
		y = ((x + x + b_var) * y * c_var + orig_y + a_var) * strange_mult;
		x = new_x * e_var + d_var;
	}
	return i;
}



void fragment() {
	float x = mix(center.x - margin.x / zoom, center.x + margin.x / zoom, SCREEN_UV.x);
	float y = mix(center.y - margin.y / zoom, center.y + margin.y / zoom, SCREEN_UV.y);
	int num_steps = mandelbrot_steps(x, y);
	float val = float(num_steps) / float(textureSize(palette, 0).x);
	COLOR = texture(palette, vec2(val, 0));
}
