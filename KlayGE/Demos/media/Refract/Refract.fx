float4x4 model;
float4x4 mvp;
float4x4 modelit;
float3 eyePos;

struct VS_INPUT
{
	float4 pos			: POSITION;
	float3 normal		: NORMAL;
};

struct VS_OUTPUT
{
	float4 pos			: POSITION;
	float3 normal		: TEXCOORD0;
	float3 incident		: TEXCOORD1;
};

VS_OUTPUT TestCubeVS(VS_INPUT input)
{
	VS_OUTPUT output;
	
	float4 pos_in_world = mul(input.pos, model);
	output.incident = pos_in_world - eyePos;

	output.pos = mul(pos_in_world, mvp);
	output.normal = mul(input.normal, (float3x3)modelit);

	return output;
}


texture cubemap;

samplerCUBE cubeMapSampler = sampler_state
{
	Texture = <cubemap>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU  = Clamp;
	AddressV  = Clamp;
	AddressW  = Clamp;
};

float3 my_refract(float3 i, float3 n, float eta)
{
    float cosi = dot(-i, n);
    float cost2 = 1.0 - eta * eta * (1.0 - cosi * cosi);
    float3 t = eta * i + ((eta * cosi - sqrt(abs(cost2))) * n);
    return t * (cost2 > 0.0);
}

float4 TestCubePS(float3 normal : TEXCOORD0, float3 incident : TEXCOORD1) : COLOR
{
	normal = normalize(normal);
	incident = normalize(incident);
	return texCUBE(cubeMapSampler, refract(incident, normal, 1 / 1.2));
}

technique Refract
{
	pass p0
	{
		CullMode = CCW;

		VertexShader = compile vs_1_1 TestCubeVS();
		PixelShader = compile ps_2_0 TestCubePS();
	}
}
