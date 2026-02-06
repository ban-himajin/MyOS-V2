# MyOS-V2

### [1.プロジェクトについて](https://github.com/ban-himajin/MyOS-V2/blob/main/README.md#1%E3%83%97%E3%83%AD%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6-1)
### [2.進捗状況](https://github.com/ban-himajin/MyOS-V2/blob/main/README.md#2%E9%80%B2%E6%8D%97%E7%8A%B6%E6%B3%81-1)
### [3.使用](https://github.com/ban-himajin/MyOS-V2/blob/main/README.md#3%E4%BB%95%E6%A7%98)
### [4.実装済み&実装予定ライブラリ](https://github.com/ban-himajin/MyOS-V2/blob/main/README.md#4%E5%AE%9F%E8%A3%85%E6%B8%88%E3%81%BF%E5%AE%9F%E8%A3%85%E4%BA%88%E5%AE%9A%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA-1)
### [5.規約](https://github.com/ban-himajin/MyOS-V2/blob/main/README.md#5%E8%A6%8F%E7%B4%84-1)

## 1.プロジェクトについて
このプロジェクトは現在BIOSを前提としたOSの開発をしていますが、今後UEFIの対応も考えて開発をしています。  
また基本的にこのプロジェクトは私が興味関心があるため技術的に不安定な場所、適切ではない書き方、間違いなどが多いと思いますのでその最は指摘をいただけると嬉しいです。  

## 2.進捗状況
### MBR：進捗度0%
MBR自体は動作確認用の簡素なものはありますが機能が不十分なため公開はしていませんが、満足のいくものができ次第公開します。  

### VBR：進捗度0%
VBRもMBR同様動作確認用の簡素なものはありますが機能が不十分なため満足いくものができ次第公開します。  

### BootLoader：進捗度20%
ブートローダーについては現在16bitモードをはじめとして32bitへの移行をした地点まで開発しました。  
今後は32bitからC言語へ移行しブートローダーを開発していきます。  
[BootLoaderの詳細](https://github.com/ban-himajin/MyOS-V2/blob/main/README.md#bootloader%E3%81%AE%E8%A9%B3%E7%B4%B0)

### Kernel：進捗度0%
ブートローダー自体ができていないのでまだ手を付けていません。  

### OS：進捗度0%
Kernel自体ができていないのでまた手を付けていません。  

## 3.仕様
自作OSで実装または実装した仕様について記述しています。
### ステージとメモリ配置
|ステージ|配置位置|
|-----|-----|
|MBR|0x7c00~|
|VBR|0x0900~(予定)|
|BootLoader|0x8000~|
|Kernel|0xFFFF800000000000~|

### BootLoaderの詳細
### BootLoader(asm)
#### 16bit/asm
- [x] 初期化
- [x] A20を有効化
- [x] 32bit用GDTの設定
- [x] int 0x13 ah 0x42で読み込み
- [x] 32bitへの移行
#### 32bit/asm
- [x] 初期化
- [x] 例外登録
- [x] C言語ローダー呼び出し
- [ ] 64bit用GDTの設定
- [ ] ページング
- [ ] 64bitへ移行
#### 32bit/CLanguage
- [x] VGAを使った出力
- [ ] AHCIを使ったディスク読み込み
- [ ] ELFカーネルの解析
- [ ] ELFカーネルの配置
- [ ] ページング用データの作成
- [ ] 例外処理の作成
#### 64bit/asm
- [ ] 初期化
- [ ] カーネル移動

### 4.実装済み&実装予定ライブラリ
|ライブラリ名|ライブラリ内容|ライブラリの詳細|
|-------|--------|--------|
|std|OS開発時に使う自作標準ライブラリ|-|
|VGA_Driver|ブートローダーで使うVGA出力をする最低限のドライバ|[VGA_Driver.md](https://github.com/ban-himajin/MyOS-V2/blob/main/Boot_files/Library/VGA_Driver/VGA_Driver.md)|
|SATA_Driver|ブートローダーで使う最低限のSATA操作ができるドライバ|-|

### 5.規約
- 改変、改造の自由
- 改変、改造を自作したものとして公開を禁止します
  - 改変や改造したものを公開するのであれば個のリポジトリのURLを記載をお願いします
- このOSの実機、エミュレーターなどでの起動で起きた破損、故障、トラブルについては一切責任を取りません
