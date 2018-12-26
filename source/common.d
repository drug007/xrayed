module xrayed.common;

alias pcstr = char*;
alias u8 = ubyte;

auto ZeroMemory(return scope void* s, size_t n)
{
	import core.stdc.string;
	return memset(s, 0, n);
}

auto CopyMemory(return scope void* s1, scope const(void*) s2, size_t n)
{
	import core.stdc.string;
	return memcpy(s1, s2, n);
}

auto FillMemory(return scope void* s, int c, size_t n)
{
	import core.stdc.string;
	return memset(s, c, n);
}

void Log(Args...)(Args args)
{
	import std.experimental.logger : log;
	log(args);
}

enum max_path = 260;

alias string16 = char[16];
alias string32 = char[32];
alias string64 = char[64];
alias string128 = char[128];
alias string256 = char[256];
alias string512 = char[512];
alias string1024 = char[1024];
alias string2048 = char[2048];
alias string4096 = char[4096];

alias string_path = char[2 * max_path];
