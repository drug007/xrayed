module xrayed.splash;

import bindbc.sdl;

import xrayed.common : u8, CopyMemory, Log;

SDL_Window* logoWindow;

SDL_Surface* XRSDL_SurfaceVerticalFlip(ref SDL_Surface* source)
{
	const pitch = source.pitch;
	const size = pitch * source.h;

	import core.stdc.stdlib : alloca;
	auto original = cast(u8*) alloca(size);
	CopyMemory(original, source.pixels, size);

	auto flipped = cast(u8*)(source.pixels) + size;

	for (auto line = 0; line < source.h; ++line)
	{
		CopyMemory(flipped, original, pitch);
		original += pitch;
		flipped -= pitch;
	}

	return source;
}

struct Splash
{
	static void show(bool topmost)
	{
		if (logoWindow)
			return;

	version (windows)
	{
		BITMAP splash;
		HBITMAP bitmapHandle = cast(HBITMAP)LoadImage(GetModuleHandle(null), MAKEINTRESOURCE(IDB_BITMAP1), IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION);
		const int bitmapSize = GetObject(bitmapHandle, sizeof(BITMAP), &splash);

		if (0 == bitmapSize)
		{
			DeleteObject(bitmapHandle);
			return;
		}

		enum Uint32 alpha = 0xFF000000;
		enum Uint32 red   = 0x00FF0000;
		enum Uint32 green = 0x0000FF00;
		enum Uint32 blue  = 0x000000FF;

		SDL_Surface* surface = SDL_CreateRGBSurfaceFrom(
			splash.bmBits, splash.bmWidth, splash.bmHeight,
			splash.bmBitsPixel, splash.bmWidthBytes,
			red, green, blue, alpha);
	}
	else version (linux) 
	{
		SDL_Surface* surface = SDL_LoadBMP("logo.bmp"); // need placed logo.bmp beside of fsgame.ltx
	}
	else
		static assert(0, "Unsupported platform");

		if (surface is null)
		{
			import std.string : fromStringz;
			Log("Couldn't create surface from image: `", SDL_GetError().fromStringz, "`");
			return;
		}

		SDL_WindowFlags flags = SDL_WINDOW_BORDERLESS | SDL_WINDOW_HIDDEN | SDL_WINDOW_SKIP_TASKBAR;
		if (topmost)
			flags |= SDL_WINDOW_ALWAYS_ON_TOP;

		logoWindow = SDL_CreateWindow("OpenXRay", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, surface.w, surface.h, flags);
		auto logoSurface = SDL_GetWindowSurface(logoWindow);

	version (windows)
	{
		XRSDL_SurfaceVerticalFlip(surface);
	}
		SDL_UpperBlit(surface, null, logoSurface, null);

		SDL_FreeSurface(surface);
		SDL_ShowWindow(logoWindow);
		SDL_UpdateWindowSurface(logoWindow);
	}

	static void hide()
	{
		if (logoWindow != null)
		{
			SDL_DestroyWindow(logoWindow);
			logoWindow = null;
		}
	}
}
