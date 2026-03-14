// efi_types.h などの共通ヘッダーに書く
#ifndef _EFI_TYPES_H_
#define _EFI_TYPES_H_

#if defined(_MSC_VER)
    // MSVC（Visual Studio）の場合は、デフォルトが ms_abi なので空にする
    #define EFIAPI 
#else
    // GCCやClangの場合は、明示的に指定する
    #define EFIAPI __attribute__((ms_abi))
#endif

#define TRUE 1
#define FALSE 0

typedef unsigned char UINT8;
typedef unsigned short UINT16;
typedef unsigned int UINT32;
typedef unsigned long long UINT64;

typedef unsigned char INT8;
typedef unsigned short INT16;
typedef unsigned int INT32;
typedef unsigned long long INT64;

typedef unsigned char BOOLEAN;

typedef char CHAR8;//ASCII
typedef unsigned short CHAR16;//UCS-2

typedef unsigned long long UINTN;
typedef long long INTN;

typedef unsigned long long EFI_STATUS;
typedef void *EFI_HANDLE;
typedef void *EFI_EVENT;

typedef struct{
    UINT32 DATA1;
    UINT16 DATA2;
    UINT16 DATA3;
    UINT8 DATA4[8];
}EFI_GUID;

typedef struct{
    UINT64 Signature;
    UINT32 Revision;
    UINT32 HeaderSize;
    UINT32 CRC32;
    UINT32 Reserved;
}EFI_TABLE_HEADER;

struct _EFI_SYSTEM_TABLE;
typedef struct _EFI_SYSTEM_TABLE EFI_SYSTEM_TABLE;

#endif