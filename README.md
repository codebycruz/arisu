# arisu

> NOTE: This is the frozen version of Arisu as the Vulkan backend alongside a custom shading language are being developed at the [arisu-slang](https://github.com/codebycruz/arisu/tree/arisu-slang) branch.

A painting program implemented entirely from scratch in LuaJIT.

## Requirements

- Linux (Recommended) or Windows
- Support for OpenGL 4.3 (you most certainly have this)
- _That's it._

There are no dependencies used by the library. Pure X11/Win32 and OpenGL.

## Goals

- [x] Fast
	- Best practices in the GPU pipeline and when writing LuaJIT code.
- [x] Written from scratch
	- **Zero** dependencies
- [x] Implement all painting operations on the GPU
	- Canvas is stored on the GPU and manipulated purely with compute shaders

## Showcase

![v4](./assets/showcase/v0.4.0.png)
![v1](./assets/showcase/v0.1.0.png)

## Running

1. Set up LuaJIT on your system
	- Windows: `winget install -e --id DEVCOM.LuaJIT`
	- Linux: `dnf install luajit` or `apt install luajit`
2. Clone the repository
	- `git clone https://github.com/codebycruz/arisu`
3. Run this inside the repo folder
	- `luajit ./src/main.lua`

And yes, it needs to be LuaJIT, not Lua! FFI is extensively used. This repo basically uses C.

## Attributions

### Icons

Almost all of the icons are sourced from FamFamFam (Mark James)'s Silk icon set.

The rest are made by me sloppily in GIMP.

### Sound

Free sounds are sourced from [ZapSplat](https://www.zapsplat.com).
