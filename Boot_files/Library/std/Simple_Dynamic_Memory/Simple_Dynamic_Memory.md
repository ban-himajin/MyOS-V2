# ライブラリ説明
このライブラリは32bit環境を想定したライブラリとなっていて、簡素な動的メモリを含めたメモリ系統のライブラリです。  
コード内で使われている**end**という変数についてはリンカスクリプトからとってきているものになっています。  
また、現在ではfreeに該当するようなメモリ開放をするようなものを使う予定がないので作る予定もありません。  


# 定義
|定義名|数値|説明|コード|
|-----|-----|-----|-----|
|SIMPLE_DYANMIC_MEMORY|1|ライブラリが存在するか同課に使用|#define SIMPLE_DYANMIC_MEMORY 1|
|SIMPLE_DYANMIC_MEMORY_VERSION|1.0|ライブラリのバージョン管理に使用|#define SIMPLE_DYANMIC_MEMORY_VERSION 1.0|

# 型
|型名|コード|説明|
|-----|-----|-----|
|size32_t|typedef unsigned int size32_t;|32bit環境を想定で実装した型サイズを入れる前提の型|

# 関数
|関数名|引数|詳細|
|-----|-----|-----|
|SDMemory|<details><summary>引数の数(1)</summary>1.確保するサイズ数(byte単位)<details>|<details><summary>詳細</summary>1.安全にメモリを確保できるようにする。また、メモリ位置を返される<br>2.使用例:`SDMemory(sizeof(int)*5);`<br>3.関数設計:`void* __attribute__((section(".Ctext")))  SDMemory(size32_t size){void* start_memory = (void*)end_memory;end_memory += size;return start_memory;}`</details>|