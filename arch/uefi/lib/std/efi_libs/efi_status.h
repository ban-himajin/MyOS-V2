#ifndef _EFI_STATUS_H_
#define _EFI_STATUS_H_

#include "efi_types.h"

typedef UINTN EFI_STATUS;

#define EFI_SUCCESS 0

#define EFI_ERROR(Status) ((INTN)(Status) < 0)

#define ERROR(a) (0x8000000000000000ULL | (a))

#define EFI_LOAD_ERROR           EFIERR(1)  // ロードに失敗した
#define EFI_INVALID_PARAMETER    EFIERR(2)  // 引数が不正
#define EFI_UNSUPPORTED          EFIERR(3)  // サポートされていない機能
#define EFI_BAD_BUFFER_SIZE      EFIERR(4)  // バッファサイズが足りない
#define EFI_BUFFER_TOO_SMALL     EFIERR(5)  // (同上)
#define EFI_NOT_READY            EFIERR(6)  // 準備ができていない
#define EFI_DEVICE_ERROR         EFIERR(7)  // デバイスエラー
#define EFI_WRITE_PROTECTED      EFIERR(8)  // 書き込み禁止
#define EFI_OUT_OF_RESOURCES     EFIERR(9)  // リソース（メモリ等）不足
#define EFI_NOT_FOUND            EFIERR(14) // 見つからない

#define EFIWARN(a) (a)

#define EFI_WARN_UNKNOWN_GLYPH   EFIWARN(1) // 表示できない文字があった
#define EFI_WARN_DELETE_FAILURE  EFIWARN(2) // 削除に失敗した

#endif