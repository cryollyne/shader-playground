shader_type spatial;
render_mode depth_draw_never;

uniform sampler2D screen_tex : hint_screen_texture;

uniform float filmIndexOfRefraction;
uniform float innerIndexOfRefraction;

uniform float filmThickness;

uniform float intensity1;
uniform float intensity2;

float getAngle(vec3 a, vec3 b) {
    return acos(dot( normalize(a), normalize(b) ));
}

void vertex() {
}

void fragment() {
	// extremely hacky way to make transparent materials with reflections
	ALBEDO = textureLod(screen_tex, SCREEN_UV, 0).xyz;
}

float getIntensityFromWavelength(vec3 N, vec3 L, vec3 V, float wavelength) {
    float wavelengthMedium = wavelength / filmIndexOfRefraction;

    float refractedAngle = asin( sin(getAngle(N, L)) / filmIndexOfRefraction);
    float lightDistance = 2.0 * filmThickness / cos(refractedAngle);

    float phaseShift1 = 0.5*float(filmIndexOfRefraction < 1.0);
    float phaseShift2 = 0.5*float(innerIndexOfRefraction < filmIndexOfRefraction) + lightDistance/wavelengthMedium;
    
    float reflectedIntensity = sqrt(
        intensity1 * intensity1
        + intensity2 * intensity2
        + 2.0 * intensity1 * intensity2 * cos(2.0*PI*(phaseShift2 - phaseShift1))
    );
    vec3 R = reflect(-L, N);
    return reflectedIntensity;
}

void light() {
	DIFFUSE_LIGHT = vec3(1.0);

	vec3 reflected = vec3(1, 0, 0) * getIntensityFromWavelength(NORMAL, LIGHT, VIEW, 645)
                   + vec3(0.5, 0.5, 0) * getIntensityFromWavelength(NORMAL, LIGHT, VIEW, 577)
                   + vec3(0, 1, 0) * getIntensityFromWavelength(NORMAL, LIGHT, VIEW, 510)
                   + vec3(0, 0.5, 0.5) * getIntensityFromWavelength(NORMAL, LIGHT, VIEW, 475)
                   + vec3(0, 0, 1) * getIntensityFromWavelength(NORMAL, LIGHT, VIEW, 440);
    SPECULAR_LIGHT += reflected * (1.0 - dot(NORMAL, VIEW));
}
