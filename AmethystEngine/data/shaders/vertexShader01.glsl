#version 420

layout(location = 3) in mat4 inst_matModel;				// Model or World 

//uniform mat4 MVP;
uniform mat4 matModel;					// Model or World
uniform mat4 matModelInverseTranspose;	// For normal calculation
uniform mat4 matView; 					// View or camera
uniform mat4 matProj;					// Projection transform

in vec4 vColour;				// Was vec3
in vec4 vPosition;				// Was vec3
in vec4 vNormal;				// Vertex normal
in vec4 vUVx2;					// 2 x Texture coords

out vec4 fColour;
out vec4 fVertWorldLocation;
out vec4 fNormal;
out vec4 fUVx2;
out vec4 fUpdatedUVx2;

uniform bool bInstance;		// Mine

uniform sampler2D heightMap;
uniform bool useHeightMap;	// If true, use heightmap

uniform vec2 textOffset;
uniform bool useMovingTexture;

void main() {

    vec4 vertPosition = vPosition;

	vec3 theNormal = normalize(vNormal.xyz);
 	fNormal = matModelInverseTranspose * vec4(theNormal, 1.0f);
	fNormal.xyz = normalize(fNormal.xyz); 
	
	if ( useHeightMap )
	{
		// Move the y value by some amount from texture	
		// Since it's black and white, I only sample 1 colour.
		vec2 texUV1 = vUVx2.st + textOffset.xy;
		// This will pick a completely different location
		// (note the reversal of the xy to yx, called a "swizzle")
		vec2 texUV2 = vUVx2.st + textOffset.yx * vec2(-0.5f, 0.75f);
		float texValue1 = (texture( heightMap, texUV1.st ).g + texture( heightMap, texUV1.st ).r) * 0.5f;
		float texValue2 = (texture( heightMap, texUV2.st ).g + texture( heightMap, texUV1.st ).g) * 0.5f;
		float ratio = 1.0f;
		float texValue = (texValue1 + texValue2) * ratio;
		vertPosition.y += (texValue * ratio);
	}

	if ( bInstance )
	{
		mat4 matMVP = matProj * matView * inst_matModel;
		gl_Position = matMVP * vec4(vertPosition.xyz, 1.0);
	
		// Vertex location in "world space"
		fVertWorldLocation = inst_matModel * vec4(vertPosition.xyz, 1.0);
	}
	else
	{
		mat4 matMVP = matProj * matView * matModel;
		gl_Position = matMVP * vec4(vertPosition.xyz, 1.0);
	
		// Vertex location in "world space"
		fVertWorldLocation = matModel * vec4(vertPosition.xyz, 1.0);
	}

	// Pass the colour and UV unchanged.
    fColour = vColour;

	if ( useMovingTexture )
	{
		fUVx2.st = vUVx2.st + textOffset.xy;
	}
	else
	{
		fUVx2 = vUVx2;
	}
}