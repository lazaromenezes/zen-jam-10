// NOTE: Shader automatically converted from Godot Engine 4.4.beta2's ParticleProcessMaterial.

shader_type particles;
render_mode disable_velocity;

uniform vec3 direction;
uniform float inherit_emitter_velocity_ratio = 0.0;

uniform float directional_velocity_min;
uniform float directional_velocity_max;
uniform float scale_min;
uniform float scale_max;
uniform float lifetime_randomness;

uniform vec3 emission_shape_offset = vec3(0.0);
uniform vec3 emission_shape_scale = vec3(1.0);
uniform vec3 velocity_pivot = vec3(0.0);
uniform float emission_sphere_radius;
uniform vec4 color_value : source_color;
uniform vec3 gravity;
uniform sampler2D alpha_curve : repeat_disable;

uniform sampler2D sprite;

float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0) {
		s = 305420679;
	}
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0) {
		s += 2147483647;
	}
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

struct DisplayParameters {
	vec3 scale;
	float hue_rotation;
	float lifetime;
	vec4 color;
	float emission_texture_position;
	vec2 texture_size;
};

struct DynamicsParameters {
	float initial_velocity_multiplier;
	float directional_velocity;
};

void calculate_initial_dynamics_params(inout DynamicsParameters params, inout uint alt_seed) {
	// -------------------- DO NOT REORDER OPERATIONS, IT BREAKS VISUAL COMPATIBILITY
	// -------------------- ADD NEW OPERATIONS AT THE BOTTOM
	params.directional_velocity = mix(directional_velocity_min, directional_velocity_max, rand_from_seed(alt_seed));
}

void calculate_initial_display_params(inout DisplayParameters params, inout uint alt_seed) {
	// -------------------- DO NOT REORDER OPERATIONS, IT BREAKS VISUAL COMPATIBILITY
	// -------------------- ADD NEW OPERATIONS AT THE BOTTOM
	float pi = 3.14159;
	params.scale = vec3(mix(scale_min, scale_max, rand_from_seed(alt_seed)));
	params.scale = sign(params.scale) * max(abs(params.scale), 0.001);
	params.lifetime = (1.0 - lifetime_randomness * rand_from_seed(alt_seed));
	params.color = color_value;
	params.texture_size = vec2(textureSize(sprite, 0));
}

void process_display_param(inout DisplayParameters parameters, float lifetime, mat4 transform) {
	vec2 particlePosition = transform[3].xy;
	vec4 spriteColor = texture(sprite, particlePosition / parameters.texture_size + vec2(0.5, 0.5));

	parameters.color = spriteColor;
	parameters.color.a *= texture(alpha_curve, vec2(lifetime)).r;
}

vec3 calculate_initial_position(inout DisplayParameters params, inout uint alt_seed) {
	float pi = 3.14159;
	vec3 pos = vec3(0.0);

	{ // Emission shape.
		float s = rand_from_seed(alt_seed) * 2.0 - 1.0;
		float t = rand_from_seed(alt_seed) * 2.0 * pi;
		float p = rand_from_seed(alt_seed);
		float radius = emission_sphere_radius * sqrt(1.0 - s * s);
		pos = mix(vec3(0.0, 0.0, 0.0), vec3(radius * cos(t), radius * sin(t), emission_sphere_radius * s), p);
	}

	return pos * emission_shape_scale + emission_shape_offset;
}

vec3 get_random_direction_from_spread(inout uint alt_seed, float spread_angle) {
	float pi = 3.14159;
	float degree_to_rad = pi / 180.0;
	float spread_rad = spread_angle * degree_to_rad;
	float angle1_rad = rand_from_seed_m1_p1(alt_seed) * spread_rad;
	angle1_rad += direction.x != 0.0 ? atan(direction.y, direction.x) : sign(direction.y) * (pi / 2.0);
	vec3 spread_direction = vec3(cos(angle1_rad), sin(angle1_rad), 0.0);
	return spread_direction;
}

void start() {
	uint base_number = NUMBER;
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);

	DisplayParameters params;
	calculate_initial_display_params(params, alt_seed);

	DynamicsParameters dynamic_params;
	calculate_initial_dynamics_params(dynamic_params, alt_seed);

	process_display_param(params, 0.0, TRANSFORM);
	if (rand_from_seed(alt_seed) > AMOUNT_RATIO) {
		ACTIVE = false;
	}

	if (RESTART_CUSTOM) {
		CUSTOM = vec4(0.0);
		CUSTOM.w = params.lifetime;
	}

	if (RESTART_POSITION) {
		TRANSFORM[3].xyz = calculate_initial_position(params, alt_seed);
		TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
	}

	process_display_param(params, 0.0, TRANSFORM);

	VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz;
	VELOCITY += EMITTER_VELOCITY * inherit_emitter_velocity_ratio;
	VELOCITY.z = 0.0;
	TRANSFORM[3].z = 0.0;
}

void process() {
	uint base_number = NUMBER;

	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);

	DisplayParameters params;
	calculate_initial_display_params(params, alt_seed);

	DynamicsParameters dynamic_params;
	calculate_initial_dynamics_params(dynamic_params, alt_seed);

	float pi = 3.14159;
	float degree_to_rad = pi / 180.0;

	CUSTOM.y += DELTA / LIFETIME;
	CUSTOM.y = mix(CUSTOM.y, 1.0, INTERPOLATE_TO_END);
	float lifetime_percent = CUSTOM.y / params.lifetime;
	if (CUSTOM.y > CUSTOM.w) {
		ACTIVE = false;
	}

	vec2 final_velocity = TRANSFORM[3].xy / dynamic_params.directional_velocity;

	TRANSFORM[3].xyz += vec3(final_velocity.x, final_velocity.y, 0) * DELTA;

	process_display_param(params, lifetime_percent, TRANSFORM);

	COLOR = params.color;

	TRANSFORM[0] = vec4(cos(CUSTOM.x), -sin(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[1] = vec4(sin(CUSTOM.x), cos(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[2] = vec4(0.0, 0.0, 1.0, 0.0);
	TRANSFORM[3].z = 0.0;

	TRANSFORM[0].xyz *= sign(params.scale.x) * max(abs(params.scale.x), 0.001);
	TRANSFORM[1].xyz *= sign(params.scale.y) * max(abs(params.scale.y), 0.001);
	TRANSFORM[2].xyz *= sign(params.scale.z) * max(abs(params.scale.z), 0.001);

	if (CUSTOM.y > CUSTOM.w) {
		ACTIVE = false;
	}

}
