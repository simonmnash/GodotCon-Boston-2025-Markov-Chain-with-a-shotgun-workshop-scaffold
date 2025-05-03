shader_type canvas_item;
render_mode unshaded;

uniform vec4 primary_color : source_color = vec4(0.2, 0.4, 0.8, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.0, 0.1, 0.5, 1.0);
uniform vec4 cloud_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform int pixel_size : hint_range(1, 16) = 4; // Controls pixelation amount
uniform float seed : hint_range(0, 100) = 0.0; // Random seed value for unique continents
uniform float primary_bias : hint_range(0.0, 1.0) = 0.5; // Higher values = more primary color

void fragment() {
    // Pixelate the UV coordinates
    vec2 pixelated_uv = floor(UV * 256.0 / float(pixel_size)) * float(pixel_size) / 256.0;

    // Transform UV so that (0,0) is the centre and radius is 1.0
    vec2 centred_uv = pixelated_uv * 2.0 - 1.0;
    float radius = length(centred_uv);

    // Discard pixels outside the planet disc
    if (radius > 1.0) {
        discard;
    }

    // Spherical effect: Darkening toward edges using a spherical function
    float sphere_mask = sqrt(1.0 - radius * radius); // Hemisphere formula

    // Base surface colors with unique continental divisions
    float freq_x = 6.0 + seed * 0.1;           // Range ~6.0-16.0
    float freq_y = 4.0 + mod(seed, 10.0) * 0.2; // Range ~4.0-6.0
    float noise_val = sin(centred_uv.x * freq_x + sin(centred_uv.y * freq_y) + seed) *
                      sin(centred_uv.y * freq_x + sin(centred_uv.x * freq_y) + seed * 1.618) * 0.5 + 0.5;
    float continent = step(primary_bias, noise_val); // Creates pixel-art continents
    vec4 surface = mix(primary_color, secondary_color, continent);

    // Create dynamic cloud system with rotation
    float time_offset = TIME * 0.2;
    float angle = time_offset * 0.3;
    vec2 rotated_uv = vec2(
        centred_uv.x * cos(angle) - centred_uv.y * sin(angle),
        centred_uv.x * sin(angle) + centred_uv.y * cos(angle)
    );

    // Weather pattern: Less uniform cloud patches
    float noise1 = sin(rotated_uv.x * 10.0 + time_offset) * sin(rotated_uv.y * 8.0 + time_offset);
    float noise2 = sin(rotated_uv.x * 5.0 - time_offset * 0.7) * sin(rotated_uv.y * 15.0 + time_offset * 0.3);

    // Combine noise patterns to create scattered clouds - only above threshold
    float cloud_threshold = 0.01; // Adjust to control cloud coverage (higher = less clouds)
    float cloud_density = noise1 * noise2; // Multiply for more variation

    // Clouds only where density exceeds threshold, with partial transparency
    float cloud_alpha = 0.0;
    if (cloud_density > cloud_threshold) {
        cloud_alpha = (cloud_density - cloud_threshold) / (1.0 - cloud_threshold) * 0.8;
    }

    // Apply cloud mask with partial transparency
    vec4 colour = mix(surface, cloud_color, cloud_alpha);

    // Apply spherical shading
    colour.rgb *= (sphere_mask * 0.5 + 0.5);

    COLOR = colour;
}