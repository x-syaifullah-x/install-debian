# CHROMIUM FLAG
#
#
### OPENGL FOR CHROMIUM >= 133.0.6943.126
```sh
tee /etc/chromium.d/x-flags << EOF
export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --start-maximized --show-component-extension-options --gtk-version=4 --enable-native-gpu-memory-buffers --enable-zero-copy --enable-features=ConversionMeasurement,WebGPUService,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoEncoder --ozone-platform-hint=auto --enable-parallel-downloading --disable-gpu-driver-bug-workarounds"
EOF
```

### VULKAN FOR CHROMIUM >= 133.0.6943.126
```sh
tee /etc/chromium.d/x-flags << EOF
export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --start-maximized --show-component-extension-options --gtk-version=4 --enable-native-gpu-memory-buffers --enable-zero-copy --enable-features=ConversionMeasurement,WebGPUService,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE,AcceleratedVideoEncoder --ozone-platform-hint=auto --enable-parallel-downloading --disable-gpu-driver-bug-workarounds"
EOF
```

### FOR QEMU
```sh
tee /etc/chromium.d/x-flags << EOF
export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --start-maximized --show-component-extension-options --gtk-version=4 --enable-native-gpu-memory-buffers --enable-zero-copy --ozone-platform-hint=auto --enable-parallel-downloading --disable-gpu-driver-bug-workarounds --disable-gpu"
EOF
```