/* C thunk file for functions in delete_this_file.m generated on Thu Jan 18 15:19:54 2018. */


#ifdef _WIN32
  #define DLL_EXPORT_SYM __declspec(dllexport)
#elif __GNUC__ >= 4
  #define DLL_EXPORT_SYM __attribute__ ((visibility("default")))
#else
  #define DLL_EXPORT_SYM
#endif

#ifdef LCC_WIN64
  #define DLL_EXPORT_SYM
#endif

#ifdef  __cplusplus
#define EXPORT_EXTERN_C extern "C" DLL_EXPORT_SYM
#else
#define EXPORT_EXTERN_C DLL_EXPORT_SYM
#endif

#include <tmwtypes.h>

/* use BUILDING_THUNKFILE to protect parts of your header if needed when building the thunkfile */
#define BUILDING_THUNKFILE

#include "LimeSuite_Build_Thunk.h"
#ifdef LCC_WIN64
#define EXPORT_EXTERN_C __declspec(dllexport)
#endif

/*  int __cdecl LMS_GetDeviceList ( lms_info_str_t * dev_list ); */
EXPORT_EXTERN_C int32_T int32voidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	return ((int32_T (*)(void * ))fcn)(p0);
}

/*  int __cdecl LMS_Open ( lms_device_t ** device , const lms_info_str_t info , void * args ); */
EXPORT_EXTERN_C int32_T int32voidPtrvoidPtrvoidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	void * p1;
	void * p2;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(void * const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(void * const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	return ((int32_T (*)(void * , void * , void * ))fcn)(p0 , p1 , p2);
}

/*  _Bool __cdecl LMS_IsOpen ( lms_device_t * device , int port ); */
EXPORT_EXTERN_C _Bool _BoolvoidPtrint32Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	int32_T p1;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(int32_T const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	return ((_Bool (*)(void * , int32_T ))fcn)(p0 , p1);
}

/*  int __cdecl LMS_GetNumChannels ( lms_device_t * device , _Bool dir_tx ); */
EXPORT_EXTERN_C int32_T int32voidPtr_BoolThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	return ((int32_T (*)(void * , _Bool ))fcn)(p0 , p1);
}

/*  int __cdecl LMS_EnableChannel ( lms_device_t * device , _Bool dir_tx , size_t chan , _Bool enabled ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64_BoolThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	_Bool p3;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(_Bool const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	return ((int32_T (*)(void * , _Bool , uint64_T , _Bool ))fcn)(p0 , p1 , p2 , p3);
}

/*  int __cdecl LMS_SetSampleRate ( lms_device_t * device , float_type rate , size_t oversample ); */
EXPORT_EXTERN_C int32_T int32voidPtrdoubleuint64Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	double p1;
	uint64_T p2;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(double const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	return ((int32_T (*)(void * , double , uint64_T ))fcn)(p0 , p1 , p2);
}

/*  int __cdecl LMS_GetSampleRate ( lms_device_t * device , _Bool dir_tx , size_t chan , float_type * host_Hz , float_type * rf_Hz ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64voidPtrvoidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	void * p3;
	void * p4;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(void * const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	p4=*(void * const *)callstack;
	callstack+=sizeof(p4) % sizeof(size_t) ? ((sizeof(p4) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p4);
	return ((int32_T (*)(void * , _Bool , uint64_T , void * , void * ))fcn)(p0 , p1 , p2 , p3 , p4);
}

/*  int __cdecl LMS_GetSampleRateRange ( lms_device_t * device , _Bool dir_tx , lms_range_t * range ); */
EXPORT_EXTERN_C int32_T int32voidPtr_BoolvoidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	void * p2;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(void * const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	return ((int32_T (*)(void * , _Bool , void * ))fcn)(p0 , p1 , p2);
}

/*  int __cdecl LMS_SetLOFrequency ( lms_device_t * device , _Bool dir_tx , size_t chan , float_type frequency ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64doubleThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	double p3;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(double const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	return ((int32_T (*)(void * , _Bool , uint64_T , double ))fcn)(p0 , p1 , p2 , p3);
}

/*  int __cdecl LMS_GetLOFrequency ( lms_device_t * device , _Bool dir_tx , size_t chan , float_type * frequency ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64voidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	void * p3;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(void * const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	return ((int32_T (*)(void * , _Bool , uint64_T , void * ))fcn)(p0 , p1 , p2 , p3);
}

/*  int __cdecl LMS_SetAntenna ( lms_device_t * dev , _Bool dir_tx , size_t chan , size_t index ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64uint64Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	uint64_T p3;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(uint64_T const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	return ((int32_T (*)(void * , _Bool , uint64_T , uint64_T ))fcn)(p0 , p1 , p2 , p3);
}

/*  int __cdecl LMS_GetAntenna ( lms_device_t * dev , _Bool dir_tx , size_t chan ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	return ((int32_T (*)(void * , _Bool , uint64_T ))fcn)(p0 , p1 , p2);
}

/*  int __cdecl LMS_GetAntennaBW ( lms_device_t * dev , _Bool dir_tx , size_t chan , size_t index , lms_range_t * range ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64uint64voidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	uint64_T p3;
	void * p4;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(uint64_T const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	p4=*(void * const *)callstack;
	callstack+=sizeof(p4) % sizeof(size_t) ? ((sizeof(p4) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p4);
	return ((int32_T (*)(void * , _Bool , uint64_T , uint64_T , void * ))fcn)(p0 , p1 , p2 , p3 , p4);
}

/*  int __cdecl LMS_SetGaindB ( lms_device_t * device , _Bool dir_tx , size_t chan , unsigned gain ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64uint32Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	uint32_T p3;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(uint32_T const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	return ((int32_T (*)(void * , _Bool , uint64_T , uint32_T ))fcn)(p0 , p1 , p2 , p3);
}

/*  int __cdecl LMS_SetGFIRLPF ( lms_device_t * device , _Bool dir_tx , size_t chan , _Bool enabled , float_type bandwidth ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64_BooldoubleThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	_Bool p3;
	double p4;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(_Bool const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	p4=*(double const *)callstack;
	callstack+=sizeof(p4) % sizeof(size_t) ? ((sizeof(p4) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p4);
	return ((int32_T (*)(void * , _Bool , uint64_T , _Bool , double ))fcn)(p0 , p1 , p2 , p3 , p4);
}

/*  int __cdecl LMS_Calibrate ( lms_device_t * device , _Bool dir_tx , size_t chan , double bw , unsigned flags ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64doubleuint32Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	double p3;
	uint32_T p4;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(double const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	p4=*(uint32_T const *)callstack;
	callstack+=sizeof(p4) % sizeof(size_t) ? ((sizeof(p4) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p4);
	return ((int32_T (*)(void * , _Bool , uint64_T , double , uint32_T ))fcn)(p0 , p1 , p2 , p3 , p4);
}

/*  int __cdecl LMS_LoadConfig ( lms_device_t * device , const char * filename ); */
EXPORT_EXTERN_C int32_T int32voidPtrcstringThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	char * p1;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(char * const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	return ((int32_T (*)(void * , char * ))fcn)(p0 , p1);
}

/*  int __cdecl LMS_SetTestSignal ( lms_device_t * device , _Bool dir_tx , size_t chan , lms_testsig_t sig , int16_t dc_i , int16_t dc_q ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64lms_testsig_tint16int16Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	lms_testsig_t p3;
	int16_T p4;
	int16_T p5;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(lms_testsig_t const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	p4=*(int16_T const *)callstack;
	callstack+=sizeof(p4) % sizeof(size_t) ? ((sizeof(p4) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p4);
	p5=*(int16_T const *)callstack;
	callstack+=sizeof(p5) % sizeof(size_t) ? ((sizeof(p5) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p5);
	return ((int32_T (*)(void * , _Bool , uint64_T , lms_testsig_t , int16_T , int16_T ))fcn)(p0 , p1 , p2 , p3 , p4 , p5);
}

/*  int __cdecl LMS_SetSampleRateDir ( lms_device_t * device , _Bool dir_tx , float_type rate , size_t oversample ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booldoubleuint64Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	double p2;
	uint64_T p3;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(double const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(uint64_T const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	return ((int32_T (*)(void * , _Bool , double , uint64_T ))fcn)(p0 , p1 , p2 , p3);
}

/*  int __cdecl LMS_SetNCOFrequency ( lms_device_t * device , _Bool dir_tx , size_t chan , const float_type * freq , float_type pho ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64voidPtrdoubleThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	void * p3;
	double p4;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(void * const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	p4=*(double const *)callstack;
	callstack+=sizeof(p4) % sizeof(size_t) ? ((sizeof(p4) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p4);
	return ((int32_T (*)(void * , _Bool , uint64_T , void * , double ))fcn)(p0 , p1 , p2 , p3 , p4);
}

/*  int __cdecl LMS_SetNCOIndex ( lms_device_t * device , _Bool dir_tx , size_t chan , int index , _Bool downconv ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64int32_BoolThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	int32_T p3;
	_Bool p4;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(int32_T const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	p4=*(_Bool const *)callstack;
	callstack+=sizeof(p4) % sizeof(size_t) ? ((sizeof(p4) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p4);
	return ((int32_T (*)(void * , _Bool , uint64_T , int32_T , _Bool ))fcn)(p0 , p1 , p2 , p3 , p4);
}

/*  int __cdecl LMS_SetGFIRCoeff ( lms_device_t * device , _Bool dir_tx , size_t chan , lms_gfir_t filt , const float_type * coef , size_t count ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64lms_gfir_tvoidPtruint64Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	lms_gfir_t p3;
	void * p4;
	uint64_T p5;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(lms_gfir_t const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	p4=*(void * const *)callstack;
	callstack+=sizeof(p4) % sizeof(size_t) ? ((sizeof(p4) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p4);
	p5=*(uint64_T const *)callstack;
	callstack+=sizeof(p5) % sizeof(size_t) ? ((sizeof(p5) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p5);
	return ((int32_T (*)(void * , _Bool , uint64_T , lms_gfir_t , void * , uint64_T ))fcn)(p0 , p1 , p2 , p3 , p4 , p5);
}

/*  int __cdecl LMS_GetGFIRCoeff ( lms_device_t * device , _Bool dir_tx , size_t chan , lms_gfir_t filt , float_type * coef ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64lms_gfir_tvoidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	lms_gfir_t p3;
	void * p4;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(lms_gfir_t const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	p4=*(void * const *)callstack;
	callstack+=sizeof(p4) % sizeof(size_t) ? ((sizeof(p4) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p4);
	return ((int32_T (*)(void * , _Bool , uint64_T , lms_gfir_t , void * ))fcn)(p0 , p1 , p2 , p3 , p4);
}

/*  int __cdecl LMS_SetGFIR ( lms_device_t * device , _Bool dir_tx , size_t chan , lms_gfir_t filt , _Bool enabled ); */
EXPORT_EXTERN_C int32_T int32voidPtr_Booluint64lms_gfir_t_BoolThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	_Bool p1;
	uint64_T p2;
	lms_gfir_t p3;
	_Bool p4;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(_Bool const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(lms_gfir_t const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	p4=*(_Bool const *)callstack;
	callstack+=sizeof(p4) % sizeof(size_t) ? ((sizeof(p4) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p4);
	return ((int32_T (*)(void * , _Bool , uint64_T , lms_gfir_t , _Bool ))fcn)(p0 , p1 , p2 , p3 , p4);
}

/*  int __cdecl LMS_VCTCXOWrite ( lms_device_t * dev , uint16_t val ); */
EXPORT_EXTERN_C int32_T int32voidPtruint16Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	uint16_T p1;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(uint16_T const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	return ((int32_T (*)(void * , uint16_T ))fcn)(p0 , p1);
}

/*  int __cdecl LMS_VCTCXORead ( lms_device_t * dev , uint16_t * val ); */
EXPORT_EXTERN_C int32_T int32voidPtrvoidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	void * p1;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(void * const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	return ((int32_T (*)(void * , void * ))fcn)(p0 , p1);
}

/*  int __cdecl LMS_ReadLMSReg ( lms_device_t * device , uint32_t address , uint16_t * val ); */
EXPORT_EXTERN_C int32_T int32voidPtruint32voidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	uint32_T p1;
	void * p2;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(uint32_T const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(void * const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	return ((int32_T (*)(void * , uint32_T , void * ))fcn)(p0 , p1 , p2);
}

/*  int __cdecl LMS_WriteLMSReg ( lms_device_t * device , uint32_t address , uint16_t val ); */
EXPORT_EXTERN_C int32_T int32voidPtruint32uint16Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	uint32_T p1;
	uint16_T p2;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(uint32_T const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint16_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	return ((int32_T (*)(void * , uint32_T , uint16_T ))fcn)(p0 , p1 , p2);
}

/*  int __cdecl LMS_ReadCustomBoardParam ( lms_device_t * device , uint8_t id , float_type * val , lms_name_t units ); */
EXPORT_EXTERN_C int32_T int32voidPtruint8voidPtrvoidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	uint8_T p1;
	void * p2;
	void * p3;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(uint8_T const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(void * const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(void * const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	return ((int32_T (*)(void * , uint8_T , void * , void * ))fcn)(p0 , p1 , p2 , p3);
}

/*  int __cdecl LMS_WriteCustomBoardParam ( lms_device_t * device , uint8_t id , float_type val , const lms_name_t units ); */
EXPORT_EXTERN_C int32_T int32voidPtruint8doublevoidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	uint8_T p1;
	double p2;
	void * p3;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(uint8_T const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(double const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(void * const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	return ((int32_T (*)(void * , uint8_T , double , void * ))fcn)(p0 , p1 , p2 , p3);
}

/*  int __cdecl LMS_GetClockFreq ( lms_device_t * dev , size_t clk_id , float_type * freq ); */
EXPORT_EXTERN_C int32_T int32voidPtruint64voidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	uint64_T p1;
	void * p2;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(uint64_T const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(void * const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	return ((int32_T (*)(void * , uint64_T , void * ))fcn)(p0 , p1 , p2);
}

/*  int __cdecl LMS_SetClockFreq ( lms_device_t * dev , size_t clk_id , float_type freq ); */
EXPORT_EXTERN_C int32_T int32voidPtruint64doubleThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	uint64_T p1;
	double p2;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(uint64_T const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(double const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	return ((int32_T (*)(void * , uint64_T , double ))fcn)(p0 , p1 , p2);
}

/*  int __cdecl LMS_GPIORead ( lms_device_t * dev , uint8_t * buffer , size_t len ); */
EXPORT_EXTERN_C int32_T int32voidPtrvoidPtruint64Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	void * p1;
	uint64_T p2;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(void * const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	return ((int32_T (*)(void * , void * , uint64_T ))fcn)(p0 , p1 , p2);
}

/*  int __cdecl LMS_RecvStream ( lms_stream_t * stream , void * samples , size_t sample_count , lms_stream_meta_t * meta , unsigned timeout_ms ); */
EXPORT_EXTERN_C int32_T int32voidPtrvoidPtruint64voidPtruint32Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	void * p1;
	uint64_T p2;
	void * p3;
	uint32_T p4;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(void * const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(void * const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	p4=*(uint32_T const *)callstack;
	callstack+=sizeof(p4) % sizeof(size_t) ? ((sizeof(p4) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p4);
	return ((int32_T (*)(void * , void * , uint64_T , void * , uint32_T ))fcn)(p0 , p1 , p2 , p3 , p4);
}

/*  int __cdecl LMS_UploadWFM ( lms_device_t * device , const void ** samples , uint8_t chCount , size_t sample_count , int format ); */
EXPORT_EXTERN_C int32_T int32voidPtrvoidPtruint8uint64int32Thunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	void * p1;
	uint8_T p2;
	uint64_T p3;
	int32_T p4;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(void * const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint8_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(uint64_T const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	p4=*(int32_T const *)callstack;
	callstack+=sizeof(p4) % sizeof(size_t) ? ((sizeof(p4) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p4);
	return ((int32_T (*)(void * , void * , uint8_T , uint64_T , int32_T ))fcn)(p0 , p1 , p2 , p3 , p4);
}

/*  int __cdecl LMS_EnableTxWFM ( lms_device_t * device , unsigned chan , _Bool active ); */
EXPORT_EXTERN_C int32_T int32voidPtruint32_BoolThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	uint32_T p1;
	_Bool p2;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(uint32_T const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(_Bool const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	return ((int32_T (*)(void * , uint32_T , _Bool ))fcn)(p0 , p1 , p2);
}

/*  int __cdecl LMS_Program ( lms_device_t * device , const char * data , size_t size , lms_prog_trg_t target , lms_prog_md_t mode , lms_prog_callback_t callback ); */
EXPORT_EXTERN_C int32_T int32voidPtrcstringuint64lms_prog_trg_tlms_prog_md_tvoidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	char * p1;
	uint64_T p2;
	lms_prog_trg_t p3;
	lms_prog_md_t p4;
	void * p5;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	p1=*(char * const *)callstack;
	callstack+=sizeof(p1) % sizeof(size_t) ? ((sizeof(p1) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p1);
	p2=*(uint64_T const *)callstack;
	callstack+=sizeof(p2) % sizeof(size_t) ? ((sizeof(p2) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p2);
	p3=*(lms_prog_trg_t const *)callstack;
	callstack+=sizeof(p3) % sizeof(size_t) ? ((sizeof(p3) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p3);
	p4=*(lms_prog_md_t const *)callstack;
	callstack+=sizeof(p4) % sizeof(size_t) ? ((sizeof(p4) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p4);
	p5=*(void * const *)callstack;
	callstack+=sizeof(p5) % sizeof(size_t) ? ((sizeof(p5) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p5);
	return ((int32_T (*)(void * , char * , uint64_T , lms_prog_trg_t , lms_prog_md_t , void * ))fcn)(p0 , p1 , p2 , p3 , p4 , p5);
}

/*  const lms_dev_info_t * __cdecl LMS_GetDeviceInfo ( lms_device_t * device ); */
EXPORT_EXTERN_C void * voidPtrvoidPtrThunk(void fcn(),const char *callstack,int stacksize)
{
	void * p0;
	p0=*(void * const *)callstack;
	callstack+=sizeof(p0) % sizeof(size_t) ? ((sizeof(p0) / sizeof(size_t)) + 1) * sizeof(size_t):sizeof(p0);
	return ((void * (*)(void * ))fcn)(p0);
}

/*  const char * LMS_GetLibraryVersion (); */
EXPORT_EXTERN_C char * cstringThunk(void fcn(),const char *callstack,int stacksize)
{
	return ((char * (*)( ))fcn)();
}

/*  const char * __cdecl LMS_GetLastErrorMessage ( void ); */
EXPORT_EXTERN_C char * cstringvoidThunk(void fcn(),const char *callstack,int stacksize)
{
	return ((char * (*)(void ))fcn)();
}

