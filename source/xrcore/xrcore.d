module xrayed.xrcore.xrcore;

class XrCore
{
public:
	const bool pluginMode;

	this(
		string applicationName, 
		string[] args = null,
		string fsFname = null
	)
	{
		import bindbc.sdl;
		_applicationName = applicationName;
		{
			calculateBuildId();
			pluginMode = false;
			_params = args;

			version(windows)
			{
				// Init COM so we can use CoCreateInstance
				if (!strstr(Params, "-weather"))
					CoInitializeEx(nullptr, COINIT_MULTITHREADED);
			}

			version(windows)
			{
				string_path fn, dr, di;

				// application path
				GetModuleFileName(GetModuleHandle("xrCore"), fn, sizeof(fn));
				_splitpath(fn, dr, di, nullptr, nullptr);
				strconcat(sizeof(ApplicationPath), ApplicationPath, dr, di);
			} else {
				import std.string : fromStringz;
				char *base_path = SDL_GetBasePath();
				_applicationPath = base_path.fromStringz.dup;
				SDL_free(base_path);
			}

			import std.file : getcwd;
			_workingPath = getcwd;

			version(windows)
			{
				// User/Comp Name
				DWORD sz_user = sizeof(UserName);
				GetUserName(UserName, &sz_user);

				DWORD sz_comp = sizeof(CompName);
				GetComputerName(CompName, &sz_comp);
			}
			else version(linux)
			{
				import std.algorithm : findSplit;
				import core.sys.posix.unistd : geteuid, gethostname;
				import core.sys.posix.pwd : getpwuid;
				import xrayed.common : Log;

				auto uid = geteuid();
				auto pw = getpwuid(uid);
				if(pw)
				{
					_userName = pw.pw_gecos.fromStringz.findSplit(",")[0].dup;
					Log("User name: ", _userName);
				}
				else
					Log("Couldn't get user name");

				char[1024] buffer;
				gethostname(buffer.ptr, buffer.sizeof);
				_compName = buffer.ptr.fromStringz.dup;
			}

			// import xrayed.bindings : Memory;
			// Memory._initialize();

			Log("xrayed: ", getBuildConfiguration(), " build: ", _buildId, " date: ", _buildDate);
			// PrintBuildInfo();
			Log("Command line args ", _params);

			// import xrayed.bindings : _initialize_cpu;
			// _initialize_cpu();
			// import xrayed.bindings : XRay;
			// XRay.Math.Initialize();

			// import xrayed.bindings : rtc_initialize;
			// rtc_initialize();

			import xrayed.xrcommon.xr_smart_pointers : xr_make_unique;
			import xrayed.xrcore.locator_api : CLocatorAPI;
			auto xr_FS = xr_make_unique!CLocatorAPI(0, 0f);
	// 		xr_FS = xr_make_unique<CLocatorAPI>();

	// 		xr_EFS = xr_make_unique<EFS_Utils>();
	// 		//. R_ASSERT (co_res==S_OK);
	// 	}
	// 	if (init_fs)
	// 	{
	// 		u32 flags = 0u;
	// 		if (strstr(Params, "-build") != nullptr)
	// 			flags |= CLocatorAPI::flBuildCopy;
	// 		if (strstr(Params, "-ebuild") != nullptr)
	// 			flags |= CLocatorAPI::flBuildCopy | CLocatorAPI::flEBuildCopy;
	// #ifdef DEBUG
	// 		if (strstr(Params, "-cache"))
	// 			flags |= CLocatorAPI::flCacheFiles;
	// 		else
	// 			flags &= ~CLocatorAPI::flCacheFiles;
	// #endif // DEBUG
	// #ifdef _EDITOR // for EDITORS - no cache
	// 		flags &= ~CLocatorAPI::flCacheFiles;
	// #endif // _EDITOR
	// 		flags |= CLocatorAPI::flScanAppRoot;

	// #ifndef _EDITOR
	// #ifndef ELocatorAPIH
	// 		if (strstr(Params, "-file_activity") != nullptr)
	// 			flags |= CLocatorAPI::flDumpFileActivity;
	// #endif
	// #endif
	// 		FS._initialize(flags, nullptr, fs_fname);
	// 		EFS._initialize();
	// #ifdef DEBUG
	// #ifndef _EDITOR
	// #ifndef LINUX // FIXME!!!
	// 		Msg("Process heap 0x%08x", GetProcessHeap());
	// #endif
	// #endif
	// #endif // DEBUG
		}
	}
	// void _destroy();
	// const char* GetBuildDate() const { return buildDate; }
	// u32 GetBuildId() const { return buildId; }
	static string getBuildConfiguration()
	{
		debug
		{
			version(mixed)
			{
				version(xr_x64)
					return "Mx64";
				else
					return "Mx86";
			}
			else
			{
				version(xr_x64)
					return "Dx64";
				else
					return "Dx86";
			}
		}
		else
		{
			version(xr_x64)
				return "Rx64";
			else
				return "Rx86";
		}
	}

private:
	void calculateBuildId()
	{

	}

	string _buildDate;
	string _applicationName;
	string _applicationPath;
	uint   _buildId;
	string _workingPath;
	string _userName;
	string _compName;
	long   _dwFrame;
	string[] _params;
	
};