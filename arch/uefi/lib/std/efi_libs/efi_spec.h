#ifndef _EFI_SPEC_H_
#define _EFI_SPEC_H_

#include "efi_status.h"
#include "efi_status.h"

struct _EFI_SIMPLE_TEXT_INPUT_PROTOCOL;
struct _EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL;

typedef struct{
    EFI_TABLE_HEADER Hdr;
    void *RaiseTPL;
    void *RestoreTPL;

    EFI_STATUS(*AllocatePages)();
    EFI_STATUS(*FressPages)();
    EFI_STATUS(*GetMemoryMap)(UINTN *MemoryMapSize, void *MemoryMap, UINTN *MapKey, UINTN *DescriptorSize, UINT32 *DescriptorVersion);

    //プロトコル操作系(GOPなどを探すのに使う)
    void *Reserved;
    void *RegisterProtocolNotify;
    void *LocateHandle;
    void *HandleProtocol;
    void *Reserved2;

    EFI_STATUS (*LocateProtocol)(EFI_GUID *Protocol, void *Registration, void **Interface);

    EFI_STATUS (*ExitBootServices)(EFI_HANDLE ImageHandle, UINTN MapKey);

}EFI_BOOT_SERVICES;

typedef struct{
    EFI_TABLE_HEADER Hdr;
    CHAR16 *FirmwareVendor;
    UINT32 FirmwareRevision;

    EFI_HANDLE ConsoleInHandle;
    struct _EFI_SIMPLE_TEXT_INPUT_PROTOCOL *ConIn;

    EFI_HANDLE ConsoleOutHandle;
    struct _EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *ConOut;

    EFI_HANDLE StandardErrorHandle;
    struct _EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *StdErr;

    void *RuntimeServices;
    EFI_BOOT_SERVICES *BootServices;

    UINTN NumberOfTableEntries;
    void *ConfigurationTable;
}EFI_SYSTEM_TABLE;

#endif