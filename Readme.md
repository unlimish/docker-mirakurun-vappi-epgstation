# 自動CMカット, HWエンコード対応版 docker-epgstation

[fork元の本家](https://github.com/l3tnun/docker-mirakurun-epgstation) と比べて以下の変更があります。
- [追加]　[JoinLogoScpTrialSetLinux](https://github.com/tobitti0/JoinLogoScpTrialSetLinux) をベースとした自動CMカット対応
- [追加]　vaapi によるハードウェアエンコード (h264, hevc) 対応
- [追加]　ffmpeg の opus, fdkaac 対応
- [削除]　mirakurun コンテナ周り

<br>
<br>


# 利用方法
基本的には本家のインストール手順に従ってください。
以下、いくつかの差分, 留意点です。


## epgstation/config/*.js
適当なパラメータを設定した状態で置いてあります。
かなりサイズを小さくする方向に振った設定になっているので、適当に変更, 調整してください。
- enc_*: CMカットなし
- jlse_*: CMカットあり

- *_software: x264 ソフトウェアエンコード
- *_vaapi: h264_vaapi ハードウェアエンコード
- *_vaapi-hevc10bit: hevc_vaapi(10bit) ハードウェアエンコード


## vaapi ハードウェアエンコードについて
本 dockerイメージでの vaapi ハードウェアエンコードは intel CPU のみ動作可能で、
- h264_vaapi: Broadwell 以降
- hevc_vaapi(10bit): Kaby Lake 以降

だと思います。
`epgstation/config/*_hevc10bit.js` 内で `-profile:v 2` の指定を外すと、
HEVC (8bit) になり Sklylake 以降でも動くようになるようです。



## epgstation/config/config.yml(.template)
`encode`: 上記エンコードスクリプトを参照する設定(例) が書き加えられています。
また `stream` についても vaapi, opus, fdkaac など似たような設定が追加, 変更されています。

`mirakurunPath`: 下記の通り mirakurn コンテナは起動しないので自分の環境に合わせて適宜書き換えてください。


## join_logo_scp 関連
お住まいの地域により放送局の構成が異なることにも関連して、
正しく動作させるには以下について確認, 変更が必要です。

### join_logo_scp_trial/settings/ChList.csv
(m2)ts ファイル名に含まれる放送局名 と logoファイル名との対応表です。

### join_logo_scp_trial/logo/*.lgd
ロゴファイル(*.lgd) は配布できないので空です。
[Amatsukaze](https://github.com/nekopanda/Amatsukaze) などで用意してください。

<br>
<br>

詳しくは [JoinLogoScpTrialSetLinux](https://github.com/tobitti0/JoinLogoScpTrialSetLinux)、およびその改造元を参照してください。


## mirakurun 周り
mirakurun コンテナ周りは動作しないようになっているので、必要に応じて追加してください。


<br>
<br>
以下、fork 元の Readme.md

---
---
---
<br>
<br>



# docker-mirakurun-epgstation

[Mirakurun](https://github.com/Chinachu/Mirakurun) + [EPGStation](https://github.com/l3tnun/EPGStation) の Docker コンテナ

## 前提条件

- Docker, docker-compose の導入が必須
- ホスト上の pcscd は停止する
- チューナーのドライバが適切にインストールされていること

## インストール手順

```sh
curl -sf https://raw.githubusercontent.com/l3tnun/docker-mirakurun-epgstation/v2/setup.sh | sh -s
cd docker-mirakurun-epgstation

#チャンネル設定
vim mirakurun/conf/channels.yml

#コメントアウトされている restart や user の設定を適宜変更する
vim docker-compose.yml
```

## 起動

```sh
sudo docker-compose up -d
```

## チャンネルスキャン地上波のみ(取得漏れが出る場合もあるので注意)

```sh
curl -X PUT "http://localhost:40772/api/config/channels/scan"
```

mirakurun の EPG 更新を待ってからブラウザで http://DockerHostIP:8888 へアクセスし動作を確認する

## 停止

```sh
sudo docker-compose down
```

## 更新

```sh
# mirakurunとdbを更新
sudo docker-compose pull
# epgstationを更新
sudo docker-compose build --pull
# 最新のイメージを元に起動
sudo docker-compose up -d
```

## 設定

### Mirakurun

* ポート番号: 40772

### EPGStation

* ポート番号: 8888
* ポート番号: 8889

### 各種ファイル保存先

* 録画データ

```./recorded```

* サムネイル

```./epgstation/thumbnail```

* 予約情報と HLS 配信時の一時ファイル

```./epgstation/data```

* EPGStation 設定ファイル

```./epgstation/config```

* EPGStation のログ

```./epgstation/logs```

## v1からの移行について

[docs/migration.md](docs/migration.md)を参照
