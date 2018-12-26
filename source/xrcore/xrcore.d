module xrayed.xrcore;

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
		}
	}
	// void _destroy();
	// const char* GetBuildDate() const { return buildDate; }
	// u32 GetBuildId() const { return buildId; }
	// static constexpr pcstr GetBuildConfiguration();

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