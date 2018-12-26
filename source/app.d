import core.stdc.string : strstr;

import xrayed.common : pcstr, string_path, Log;
import xrayed.splash : Splash;
import xrayed.genv : GEnv;
import xrayed.xrdebug.xrdebug : XrDebug;

XrDebug xrDebug;

int entry_point(string[] args)
{
	import std.getopt;

	bool nosplash;
	bool splashnotop;
	bool dedicated;
	string fsltx;

	auto helpInformation = getopt(
		args,
		"nosplash",    &nosplash,
		"splashnotop", &splashnotop,
		"dedicated",   &GEnv.isDedicatedServer,
		std.getopt.config.required,
		"fsltx",       &fsltx
	);

	if (helpInformation.helpWanted)
	{
		defaultGetoptPrinter("Usage:", helpInformation.options);
	}
	
    if (!nosplash)
    {
		debug {
        	bool topmost = false;
		} else {
        	bool topmost = !splashnotop;
		}

        Splash.show(topmost);
	}

    xrDebug.Initialize();
	version(windows)
	{
		StickyKeyFilter filter;
		if (!GEnv.isDedicatedServer)
			filter.initialize();
	}

	if (fsltx.length == 0)
	{
		defaultGetoptPrinter("Usage:", helpInformation.options);
		return 1;
	}

	import std.path : isValidPath;
	import std.file : exists;
	if (!fsltx.isValidPath || !fsltx.exists)
	{
		Log("-fsltx option contains wrong file path: `", fsltx, "`");
		return 1;
	}
	Log("fsltx : `", fsltx, "`");

	import std.typecons : scoped;
	import xrayed.xrcore : XrCore;
    auto core = scoped!XrCore("OpenXRay", args, fsltx);
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
			return entry_point(args);
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

version(linux)
{
	// small binding to lockfile library
	extern(C) int lockfile_create(const char *lockfile, int retries, int flags);
	enum L_PID = 16;
}

int runApplication()
{
	//<CM> R_ASSERT2(Core.Params, "Core must be initialized");

	version(no_multi_instances)
	{
		if (!GEnv.isDedicatedServer)
		{
			version(windows)
			{
				CreateMutex(nullptr, TRUE, "Local\\STALKER-COP");
				if (GetLastError() == ERROR_ALREADY_EXISTS)
					return 2;
			}
			else version (linux)
			{
				int lock_res = lockfile_create("/var/lock/stalker-cop.lock", 0, L_PID);
				if(lock_res)
				{
					Log("Couldn't lock file. Another instance is running?");
					return 2;
				}
				Log("Lock file successfully");	
			}
		}
	}
	// Patching system elements
//     *g_sLaunchOnExit_app = 0;
//     *g_sLaunchOnExit_params = 0;

//     InitSettings();
//     // Adjust player & computer name for Asian
//     if (pSettings->line_exist("string_table", "no_native_input"))
//     {
//         xr_strcpy(Core.UserName, sizeof(Core.UserName), "Player");
//         xr_strcpy(Core.CompName, sizeof(Core.CompName), "Computer");
//     }

//     FPU::m24r();
//     InitEngine();
//     InitInput();
//     InitConsole();
//     Engine.External.CreateRendererList();

//     if (CheckBenchmark())
//         return 0;

//     if (!GEnv.isDedicatedServer)
//     {
//         if (strstr(Core.Params, "-gl"))
//             Console->Execute("renderer renderer_gl");
//         else if (strstr(Core.Params, "-r4"))
//             Console->Execute("renderer renderer_r4");
//         else if (strstr(Core.Params, "-r3"))
//             Console->Execute("renderer renderer_r3");
//         else if (strstr(Core.Params, "-r2.5"))
//             Console->Execute("renderer renderer_r2.5");
//         else if (strstr(Core.Params, "-r2a"))
//             Console->Execute("renderer renderer_r2a");
//         else if (strstr(Core.Params, "-r2"))
//             Console->Execute("renderer renderer_r2");
//         else if (strstr(Core.Params, "-r1"))
//             Console->Execute("renderer renderer_r1");
//         else
//         {
//             CCC_LoadCFG_custom cmd("renderer ");
//             cmd.Execute(Console->ConfigFile);
//         }
//     }
//     else
//         Console->Execute("renderer renderer_r1");

//     Engine.External.Initialize();
//     Startup();
//     // check for need to execute something external
//     if (/*xr_strlen(g_sLaunchOnExit_params) && */ xr_strlen(g_sLaunchOnExit_app))
//     {
// #if defined(WINDOWS)
//         // CreateProcess need to return results to next two structures
//         STARTUPINFO si = {};
//         si.cb = sizeof(si);
//         PROCESS_INFORMATION pi = {};
//         // We use CreateProcess to setup working folder
//         pcstr tempDir = xr_strlen(g_sLaunchWorkingFolder) ? g_sLaunchWorkingFolder : nullptr;
//         CreateProcess(g_sLaunchOnExit_app, g_sLaunchOnExit_params, nullptr, nullptr, FALSE, 0, nullptr, tempDir, &si, &pi);
// #endif
//     }

	import core.thread : Thread;
	import std.datetime : dur;
	Thread.sleep(dur!"seconds"(1));
    return 0;
}