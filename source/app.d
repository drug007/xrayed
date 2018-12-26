import core.stdc.string : strstr;

import xrayed.common : pcstr, string_path, Log;
import xrayed.splash : Splash;
import xrayed.genv : GEnv;
import xrayed.xrdebug.xrdebug : XrDebug;

XrDebug xrDebug;

int entry_point(pcstr commandLine)
{
    if (strstr(commandLine, "-nosplash") == null)
    {
		debug {
        	bool topmost = false;
		} else {
        	const bool topmost = strstr(commandLine, "-splashnotop") == null ? true : false;
		}

        Splash.show(topmost);
    }

    if (strstr(commandLine, "-dedicated"))
        GEnv.isDedicatedServer = true;

    xrDebug.Initialize();
	version(windows)
	{
		StickyKeyFilter filter;
		if (!GEnv.isDedicatedServer)
			filter.initialize();
	}

	enum fsltx = "-fsltx \0";
	static assert(fsltx.length == 8);
    string_path fsgame = "";
    if (strstr(commandLine, fsltx.ptr))
    {
		import core.stdc.stdio : sscanf;
        sscanf(strstr(commandLine, fsltx) + fsltx.length, "%[^ ] ", fsgame.ptr);
    }
    // Core.Initialize("OpenXRay", commandLine, null, true, *fsgame ? fsgame : null);
	// scope (exit) 
	//	Core._destroy();

    auto result = runApplication();

    return result;
}

version (windows)
{
	version(none)
	{
		// int StackoverflowFilter(const int exceptionCode)
		// {
		// 	if (exceptionCode == EXCEPTION_STACK_OVERFLOW)
		// 		return EXCEPTION_EXECUTE_HANDLER;
		// 	return EXCEPTION_CONTINUE_SEARCH;
		// }
	}

	int WinMain(HINSTANCE inst, HINSTANCE prevInst, char* commandLine, int cmdShow)
	{
		// BugTrap can't handle stack overflow exception, so handle it here
		try
		{
			return entry_point(commandLine);
		}
		catch(Exception e)
		{
			return 1;
		}
		version(none)
		{
		// __except (StackoverflowFilter(GetExceptionCode()))
		// {
		// 	_resetstkoflw();
		// 	FATAL("stack overflow");
		// }
		}
	}
}
else version(linux)
{
	import bindbc.sdl;
	int main(string[] args)
	{
		auto sdlSuport = SDLSupport.sdl205;
		SDLSupport ret = loadSDL();
		if(ret < sdlSupport) {
			if(ret == SDLSupport.noLibrary) {
				Log("SDL shared library failed to load");
				return 1;
			}
			else if(SDLSupport.badLibrary) {
				Log("Unsupported SDL version: ", loadedSDLVersion);
				return 1;
			}
		}
		Log("SDL version: ", loadedSDLVersion);

		try
		{
			import std.algorithm : joiner;
			import std.range : chain;
			import std.utf : byChar;
			import std.array : array;
			import std.string : toStringz;

			auto commandLine = args.chain(["\0"]).joiner.byChar.array;
			return entry_point(cast(char*) commandLine.toStringz);
		}
		// catch (const std.overflow_error& e)
		// {
		// 	_resetstkoflw();
		// 	FATAL_F("stack overflow: %s", e.what());
		// }
		// catch (const std.runtime_error& e)
		// {
		// 	FATAL_F("runtime error: %s", e.what());
		// }
		// catch (const std.exception& e)
		// {
		// 	FATAL_F("exception: %s", e.what());
		// }
		// catch (...)
		// {
		// // this executes if f() throws std.string or int or any other unrelated type
		// }
		catch (Exception e)
		{
			import std.stdio;
			stderr.writeln(e.msg);
			return 1;
		}
	}
}

int runApplication()
{
	import core.thread : Thread;
	import std.datetime : dur;
	Thread.sleep(dur!"seconds"(3));
	return 0;
}