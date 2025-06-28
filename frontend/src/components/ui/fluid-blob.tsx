"use client"
import React, { useRef, useMemo } from 'react';
import { Canvas, useFrame, useThree } from '@react-three/fiber';
import * as THREE from 'three';

const vertexShader = `
varying vec2 vUv;
uniform float time;
uniform vec4 resolution;

void main() {
    vUv = uv;
    gl_Position = vec4(position, 1.0);
}
`;

const fragmentShader = `
precision highp float;
varying vec2 vUv;
uniform float time;
uniform vec4 resolution;
uniform vec4 viewport; // left, right, top, bottom

float PI = 3.141592653589793238;

mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

vec3 rotate(vec3 v, vec3 axis, float angle) {
    mat4 m = rotationMatrix(axis, angle);
    return (m * vec4(v, 1.0)).xyz;
}

float smin( float a, float b, float k ) {
    k *= 6.0;
    float h = max( k-abs(a-b), 0.0 )/k;
    return min(a,b) - h*h*h*k*(1.0/6.0);
}

float sphereSDF(vec3 p, float r) {
    return length(p) - r;
}

float sdf(vec3 p) {
    vec3 p1 = rotate(p, vec3(0.0, 0.0, 1.0), time/5.0);
    vec3 p2 = rotate(p, vec3(1.), -time/5.0);
    vec3 p3 = rotate(p, vec3(1., 1., 0.), -time/4.5);
    vec3 p4 = rotate(p, vec3(0., 1., 0.), -time/4.0);
    
    float final = sphereSDF(p1 - vec3(-0.5, 0.0, 0.0), 0.35);
    float nextSphere = sphereSDF(p2 - vec3(0.55, 0.0, 0.0), 0.3);
    final = smin(final, nextSphere, 0.1);
    nextSphere = sphereSDF(p2 - vec3(-0.8, 0.0, 0.0), 0.2);
    final = smin(final, nextSphere, 0.1);
    nextSphere = sphereSDF(p3 - vec3(1.0, 0.0, 0.0), 0.15);
    final = smin(final, nextSphere, 0.1);
    nextSphere = sphereSDF(p4 - vec3(0.45, -0.45, 0.0), 0.15);
    final = smin(final, nextSphere, 0.1);
    
    return final;
}

vec3 getNormal(vec3 p) {
    float d = 0.001;
    return normalize(vec3(
        sdf(p + vec3(d, 0.0, 0.0)) - sdf(p - vec3(d, 0.0, 0.0)),
        sdf(p + vec3(0.0, d, 0.0)) - sdf(p - vec3(0.0, d, 0.0)),
        sdf(p + vec3(0.0, 0.0, d)) - sdf(p - vec3(0.0, 0.0, d))
    ));
}

float rayMarch(vec3 rayOrigin, vec3 ray) {
    float t = 0.0;
    for (int i = 0; i < 100; i++) {
        vec3 p = rayOrigin + ray * t;
        float d = sdf(p);
        if (d < 0.001) return t;
        t += d;
        if (t > 100.0) break;
    }
    return -1.0;
}

void main() {
    // Convert UV to camera space using viewport
    vec2 cameraSpace = (vUv - vec2(0.5)) * 1.0; // Convert to [-1, 1] range
    cameraSpace.x *= (viewport.y - viewport.x) / (viewport.w - viewport.z); // Apply aspect ratio
    
    vec3 cameraPos = vec3(0.0, 0.0, 5.0);
    vec3 ray = normalize(vec3(cameraSpace, -1.0));
    vec3 color = vec3(1.0);
    
    float t = rayMarch(cameraPos, ray);
    if (t > 0.0) {
        vec3 p = cameraPos + ray * t;
        vec3 normal = getNormal(p);
        float fresnel = pow(1.0 + dot(ray, normal), 3.0);
        color = vec3(fresnel);
        gl_FragColor = vec4(color, 1.0);
    } else {
        gl_FragColor = vec4(1.0);
    }
}
`;

function LavaLampShader() {
  const meshRef = useRef<THREE.Mesh>(null);
  const cameraRef = useRef<THREE.OrthographicCamera>(null);
  const { size, camera, gl } = useThree();
  
  const uniforms = useMemo(() => ({
    time: { value: 0 },
    resolution: { value: new THREE.Vector4() },
    viewport: { value: new THREE.Vector4() }
  }), []);
  React.useEffect(() => {
    if (camera) {
        cameraRef.current = camera as THREE.OrthographicCamera;
    }
  }, [camera]);
  // Update resolution and camera when size changes
  React.useEffect(() => {
    const { width, height } = size;
    
    // Set camera to use a large fixed viewport that covers the entire container
    if (cameraRef.current && cameraRef.current.type === 'OrthographicCamera') {
      const orthoCamera = cameraRef.current as THREE.OrthographicCamera;
      const viewSize = 100; // Large fixed viewport
      
      // Always use square viewport to maintain blob proportions
      const aspect = width / height;
      console.log("width", width, "height", height);
      orthoCamera.left = -viewSize * aspect;
      orthoCamera.right = viewSize * aspect;
      orthoCamera.top = viewSize;
      orthoCamera.bottom = -viewSize;
      console.log("yo bro", orthoCamera.left, orthoCamera.right, orthoCamera.top, orthoCamera.bottom);
      
      // Update viewport uniform with actual camera values
      uniforms.viewport.value.set(
        orthoCamera.left,
        orthoCamera.right,
        orthoCamera.top,
        orthoCamera.bottom
      );
      
      orthoCamera.updateProjectionMatrix();
    }
    
    uniforms.resolution.value.set(width, height, 1, 1);
    gl.setSize(width, height);
  }, [size, cameraRef, uniforms]);

  useFrame((state) => {
    if (meshRef.current) {
      uniforms.time.value = state.clock.elapsedTime;
    }
  });

  return (
    <mesh ref={meshRef}>
      <planeGeometry args={[5, 5]} />
      <shaderMaterial
        uniforms={uniforms}
        vertexShader={vertexShader}
        fragmentShader={fragmentShader}
        transparent={true}
        side={THREE.DoubleSide}
      />
    </mesh>
  );
}

export const LavaLamp = () => {
  return (
    <div style={{ width: '100%', height: '100%', background: '#000', position: "absolute" }}>
      <Canvas
        key="lava-lamp-canvas"
        orthographic
        gl={{ antialias: true }}
        style={{ width: '100%', height: '100%' }}
      >
        <LavaLampShader />
      </Canvas>
    </div>
  );
} 