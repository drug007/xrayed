module xrayed.bindings;

// xrMemory.h

extern(C++) struct xrMemory
{
    // this();
    void _initialize();
    void _destroy();

    size_t mem_usage  ();
    void   mem_compact();
    void*  mem_alloc  (size_t size);
    void*  mem_realloc(void* ptr, size_t size);
    void   mem_free   (void* ptr);
}

extern xrMemory Memory;

// end of xrMemory.h

// _math.cpp
extern(C++)
void _initialize_cpu();

// xrCore/Math/MathUtil.hpp
extern(C++)
struct XRay
{
	struct Math
	{
		static void Initialize();
	}
}

extern(C++)
void rtc_initialize();