#定義
|定義名|数値|説明|コード|
|-----|-----|-----|-----|
|SETTING_LIBRARY_64BIT|1|ライブラリが存在するかの判断に使用|#define SETTING_LIBRARY_64BIT 1|
|SETTING_LIBRARY_VERSION|1.0|ライブラリのバージョン管理に使用|#define SETTING_LIBRARY_VERSION 1.0|
|BIT|1|bit|#define BIT 1|
|BYTE|8|byte|#define BYTE 8|
|KBYTE|1024ULL|Kbyte|#define KBYTE 1024ULL|
|MBYTE|1024*KBYTE|Mbyte|#define MBYTE (1024 * KBYTE)|
|GBYTE|1024*MBYTE|Gbyte|#define GBYTE (1024 * MBYTE)|
|TBYTE|1024*GBYTE|Tbyte|#define TBYTE (1024 * GBYTE)|
|PBYTE|1024*TBYTE|Pbyte|#define PBYTE (1024 * TBYTE)|

|定義名|フラグ名|数値|コード|
|-----|-----|-----|-----|
|P|Present|0x1|#define P 0x1|
|RW|Read/Write|0x2|#define RE 0x2|
|US|User/Supevisor|0x4|#define US 0x4|
|PWT|Page-level Write-Through|0x8|#define PWT 0x8|
|PCD|Page-level Cache Disable|0x10|#define PCD 0x10|
|A|Accessed|0x20|#define A 0x20|
|D|Dirty|0x40|#define D 0x40|
|PS|Page Size|0x80|#define PS 0x80|
|PG|Global|0x100|#define PG 0x100|
|AVAILABLE1|Available|0x200|#define AVAILABLE1 0x200|
|AVAILABLE2|Available|0x400|#define AVAILABLE2 0x400|
|AVAILABLE3|Available|0x800|#define AVAILABLE3 0x800|
|XD|Execute Disable|0x1000000000000|#define XD 0x1000000000000|

# 型
|型名|メンバ内容|コード|
|-----|-----|-----|
|PT|<details><summary>メンバ数(2)</summary>1.unsigned char page_flag;<br>2.unsigned int map_mem;</details>|`typedef struct{unsigned char page_flag;unsigned int map_mem;}PT;`|
|PD|<details><summary>メンバ数(4)</summary>1.unsigned char page_flag;<br>2.unsigned int map_mem;<br>3.unsigned short PT_size;<br>4.PT* PT_data;</details>|`typedef struct{unsigned char page_flag;unsigned int map_mem;unsigned short PT_size;PT* PT_data;}PD;`|
|PDPT|<details><summary>メンバ数(4)</summary>1.unsigned char page_flag;<br>2.unsigned int map_mem;<br>3.unsigned short PD_size;<br>4.PD* PD_data;</details>|`typedef struct{unsigned char page_flag;unsigned int map_mem;unsigned short PD_size;PD* PD_data;}PDPT;`|
|PML4|<details><summary>メンバ数(4)</summary>1.unsigned char page_flag;<br>2.unsigned int map_mem;<br>3.unsigned short PDPT_size;<br>4.PDPT* PDPT_data;</details>|`typedef struct{unsigned char page_flag;unsigned int map_mem;unsigned short PDPT_size;PDPT* PDPT_data;}PML4;`|
|Page_Table|<details><summary>メンバ数(2)</summary>1.unsigned short PML4_size;<br>2.PML4* PML4_data;</details>|`typedef struct{unsigned short PML4_size;PML4* PML4_data;}Page_Table;`|

# 関数
|関数名|引数|
|-----|-----|
|page_table_data|<details><summary>引数の数(4)</summary>1.const unsigned short PML4_size<br>2.const unsigned short PDPT_size<br>3.const unsigned short PD_size<br>4.const unsigned short PT_size</details>|
|PML4_set_map_mem|<details><summary>引数の数(3)</summary>1.PML4* pages<br>2.const unsigned int mems<br>3.const unsigned char flag</details>|
|PDPT_set_map_mem|<details><summary>引数の数(3)</summary>1.PDPT* pages<br>2.const unsigned int mems<br>3.const unsigned char flag</details>|
|PD_set_map_mem|<details><summary>引数の数(3)</summary>1.PD* pages<br>2.const unsigned int mems<br>3.const unsigned char flag</details>|
|PT_set_map_mem|<details><summary>引数の数(3)</summary>1.PT* pages<br>2.const unsigned int mems<br>3.const unsigned char flag</details>|
|make_page_data|<details><summary>引数の数(1)</summary>1.Page_Table*</details>|

