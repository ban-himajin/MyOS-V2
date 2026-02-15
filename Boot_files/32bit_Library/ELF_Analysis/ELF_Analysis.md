# ELF_Analysisの仕様

## 定義
|定義名|用途|
|-----|-----|
|ELF_ANALYSIS|ライブラリがあるかどうかに使用|
|ELF_ANALYSIS_VERSION|バージョン管理に使用|

## 型
|型名|用途|
|-----|-----|
|ELF_data|ELFの実行に必要なデータ群を入れる構造体|

## 関数
|関数名|引数|用途|その他|
|-----|-----|-----|-----|
|ELF_check|<details><summary>引数の数(1)</summary>1.const unsigned char* ELF_mem</details>|ELFファイルかどうかを調べる|static関数|
|get_entry|<details><summary>引数の数(1)</summary>1.const unsigned char* ELF_mem</details>|ELFファイルからentryを得る|static関数|
|get_phoff|<details><summary>引数の数(1)</summary>1.const unsigned char* ELF_mem</details>|ELFファイルからphoffを得る|static関数|
|get_phentsize|<details><summary>引数の数(1)</summary>1.const unsigned char* ELF_mem</details>|ELFファイルからphentsizeを得る|static関数|
|get_phnum|<details><summary>引数の数(1)</summary>1.const unsigned char* ELF_mem</details>|ELFファイルからphnumを得る|static関数|
|ELF_Analysis|<details><summary>引数の数(2)</summary>1.const unsigned char* ELF_mem<br>2.ELF_data* ELF_datas</details>|ELFファイルから実行をするための情報を得る|global関数|

# コード
```C
#ifndef ELF_ANALYSIS
#define ELF_ANALYSIS 1
#define ELF_ANALYSIS_VERSION 1.0

typedef struct{
    unsigned long long e_entry;
    unsigned long long e_phoff;
    unsigned long long e_phentsize;
    unsigned long long e_phnum;
}ELF_data;

static char ELF_check(const unsigned char* ELF_mem){
    if( ELF_mem[0] != 0x7f ||
        ELF_mem[1] != 'E' ||
        ELF_mem[2] != 'L' ||
        ELF_mem[3] != 'F')return 0;
    return -1;
}

static unsigned long long get_entry(const unsigned char* ELF_mem){
    unsigned long long entry = 0;
    unsigned int offset = 24;
    for(int i = 0;i < 8; i++){
        entry |= (unsigned long long)ELF_mem[offset + i] << (8 * i);
    }
    return entry;
}

static unsigned long long get_phoff(const unsigned char* ELF_mem){
    unsigned long long phoff = 0;
    unsigned int offset = 32;
    for(int i = 0;i < 8; i++){
        phoff |= (unsigned long long)ELF_mem[offset + i] << (8 * i);
    }
    return phoff;
}

static unsigned short get_phentsize(const unsigned char* ELF_mem){
    unsigned short phentsize = 0;
    unsigned int offset = 54;
    for(int i = 0;i < 2; i++){
        phentsize |= (unsigned short)ELF_mem[offset + i] << (8 * i);
    }
    return phentsize;
}

static unsigned short get_phnum(const unsigned char* ELF_mem){
    unsigned short phnum = 0;
    unsigned int offset = 56;
    for(int i = 0;i < 2; i++){
        phnum |= (unsigned short)ELF_mem[offset + i] << (8 * i);
    }
    return phnum;
}

short ELF_Analysis(const unsigned char* ELF_mem,ELF_data* ELF_datas){
    if(ELF_check(ELF_mem) != 0)return -1;
    ELF_datas->e_entry = get_entry(ELF_mem);
    ELF_datas->e_phoff = get_phoff(ELF_mem);
    ELF_datas->e_phentsize = (unsigned long long)get_phentsize(ELF_mem);
    ELF_datas->e_phnum = (unsigned long long)get_phnum(ELF_mem);
    return 0;
}

#endif
```
