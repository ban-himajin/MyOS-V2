# VGA_Driverライブラリの詳細
現在までで開発ができている関数や定義の詳細です。  
[実際のコード](https://github.com/ban-himajin/MyOS-V2/blob/ELF_Analysis_Library/Boot_files/32bit_Library/VGA_Driver/VGA_Driver.h)

## 定義
### データ定義&定義関数
|定義名|定義内容|詳細|
|-----|-----|-----|
|VGA_DRIVER|ライブラリが存在するか否かの判断|<details><summary>詳細</summary>- `#define VGA_DRIVER 1`</details>|
|VGA_Version|コンパイル時に使うバージョン定義|<details><summary>詳細</summary>- `#define VGA_Version 1.0`</details>|
|VGA_Start_Memory|VGAの固定メモリ位置の定義|<details><summary>詳細</summary>- `#define VGA_Start_Memory 0xb8000`</details>|
|VGA_HEIGHT|VGAで使用できる行数の定義|<details><summary>詳細</summary>- `#define VGA_HEIGHT 25`</details>|
|VGA_WIDTH|VGAで使用できる1行の文字数の定義|<details><summary>詳細</summary>- `#define VGA_WIDTH 80`</details>|
|COLLAR|関数で使う色の変換に使用|<details><summary>詳細</summary>- `#define COLLAR(bc, tc) ((bc<<4) ｜ (tc))`<br>- 第1引数に背景色<br>- 第2引数文字色</details>|

### 色定義
|定義名|値|色
|-----|-----|-----|
|Black|0|黒|
|Brue|1|青|
|Green|2|緑|
|Cyan|3|シアン|
|Red|4|赤|
|Magenta|5|マゼンタ|
|Brown|6|茶色|
|White|7|白|
|LightGray|8|明シアン|
|LightBrue|9|明青|
|LightGreen|10|明緑|
|LightLightBrue|11|水色|
|LightRed|12|明赤|
|LightMagenta|13|明マゼンタ|
|Yellow|14|黄色|
|LightWhite|15|白|

## 型
|型名|コード|
|-----|-----|
|VGA_data|<details><summary>コード</summary>`typedef struct{<br>unsigned short *VGA;<br>char x;char y;}VGA_data;`</details>

## 関数
|関数名|引数内容|戻り値|詳細|
|-----|-----|-----|-----|
|get_vga_memory|<details><summary>引数の数(0)</summary></details>|VGAメモリ位置(0xb8000)[固定]|<details><summary>詳細</summary>- 内容:VGAメモリ位置を返す<br>- 使用例:`unsigned short* VGA = get_vga_memory();`</datails>|
|set_vga|<details><summary>引数の数(3)</summary>1.VGAポインタのアドレス<br>2.VGA_s<br>3.VGA_y|0[固定]|<details><summary>詳細</summary>- 内容:x,yをもとにVGAを移動<br>- 使用例:`set_vga(&VGA,VGA_x,VGA_y);`</datails>|
|write_vga_text|<details><summary>引数の数(3)</summary>-VGAのポインタアドレス<br>- 単文字<br>- 文字色&背景色|0[固定]|<details><summary>詳細</summary>- 内容:短文字の出力<br>- 使用例:`write_vga_text(&VGA, 'A', COLLAR(Black, White));`</details>|
|write_vga_texts|<details><summary>引数の数(3)</summary>-VGAのポインタアドレス<br>- 文字列<br>- 文字色&背景色</details>|0[固定]|<details><summary>詳細</summary>- 内容:短文字の出力<br>- 使用例:`write_vga_text(&VGA, "Hello World", COLLAR(Black, White));`</details>|
|clean_screan|<details><summary>引数の数(2)</summary>- 開始位置<br>- 文字色&背景色</details>|0[固定]|<details><summary>詳細</summary>- 内容:指定の位置から最後までを指定の文字,色で埋める<br>- 使用例:`clean_screen(' ', COLLAR(Red,Black));`</details>|


