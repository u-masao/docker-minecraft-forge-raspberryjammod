# Docker Minecraft Forge with Raspberry Jam Mod

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) Minecraft Forge サーバー (v1.12.2) と Raspberry Jam Mod (v0.94) を Docker と Docker Compose を使用して簡単に起動するためのリポジトリです。Raspberry Jam Mod と連携するための Python 3 環境 (pygame, Pillow ライブラリを含む) も同梱されています。

## ✨ 特徴 (Features)

* **Minecraft Forge Server**: v1.12.2 (forge-1.12.2-14.23.5.2860)
* **Raspberry Jam Mod**: v0.94 導入済み (Minecraft 内での Python スクリプティングが可能)
* **Python 3 環境**: `python3`, `pip`, `pygame`, `pillow` を含む
* **簡単セットアップ**: Docker Compose コマンド一つでサーバーを起動
* **データ永続化**: `server.properties` やワールドデータをホストマシンに簡単に保存可能

## 🔧 必要なもの (Prerequisites)

* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/install/) (通常、Docker Desktop に含まれています)

## 🚀 使い方 (Usage)

1.  **リポジトリをクローン:**
    ```bash
    git clone https://github.com/u-masao/docker-minecraft-forge-raspberryjammod.git
    cd docker-minecraft-forge-raspberryjammod
    ```

2.  **サーバー設定ファイルの編集:**
    * 必要に応じて Minecraft サーバーの設定ファイル `./storage/server.properties` を修正します。
    * (初回起動時にコンテナ内で `eula.txt` が自動生成され `eula=true` と設定されます。Minecraft の EULA に同意していることを確認してください。)

3.  **サーバーを起動:**
    ```bash
    docker-compose up -d --build
    ```
    これにより、Docker イメージがビルドされ (初回のみ)、コンテナがバックグラウンドで起動します。

4.  **サーバーに接続:**
    * Minecraft Java Edition (バージョン 1.12.2) を起動します。
    * 「マルチプレイ」 → 「サーバーを追加」 を選択します。
    * サーバー名 (例: `My Docker Forge Server`) とサーバーアドレス `localhost:25565` を入力します。
    * サーバーに接続します。

5.  **Raspberry Jam Mod Python スクリプトの実行:**
    Minecraft の世界と連携する Python スクリプトを実行できます。

    * **方法1: コンテナ内で実行**
        ```bash
        # サンプルスクリプトを実行
        docker compose exec mc-forge python3 mcpipy/helloworld.py
        ```
        Minecraft のチャット欄に "Hello world!" と表示されれば成功です。

    * **方法2: Minecraft チャットから実行**
        Minecraft のクライアントアプリで t キーを押します。
        以下のコマンドを入力します。
        ```
        /py helloworld
        ```
        チャット欄に「Hello wordl!」と表示されれば成功です。

    * **方法3: コンテナ外で実行**
        Raspberry Jam Mod のリポジトリをクローンします。

        ```
        git clone https://github.com/arpruss/raspberryjammod.git
        cd raspberryjammod
        ```

        コードを修正します。

        ```
        vi mcpipy/mcpi/util.py # 2箇所修正：collections -> collections.abc
        vi mcpipy/mcpi/vec3.py # 2箇所修正：collections -> collections.abc
        ````

        実行します。

        ```
        export MINECRAFT_API_HOST=localhost  # サーバーホスト
        export MINECRAFT_API_PORT=4711  # サーバーポート
        python mcpipy/helloworld.py
        ```

        Minecraft クライアントアプリのチャット欄に「Hello wordl!」と表示されれば成功です。

6.  **サーバーコンソールへのアクセス:**
    * ログの表示: `docker compose logs -f mc-forge`
    * コンソールへのアタッチ: `docker compose attach mc-forge`
        * アタッチ後、Minecraft サーバーコマンド (例: `/op <playername>`) を入力できます。
        * デタッチするには `Ctrl+P` を押してから `Ctrl+Q` を押します。(`Ctrl+C` だとサーバーが停止する可能性があります)

7.  **サーバーを停止:**
    ```bash
    docker compose down
    ```
    これにより、コンテナが停止・削除されます。ボリューム設定が正しく行われていれば、データは `storage` ディレクトリに残ります。

## ⚙️ 設定 (Configuration)

* **`Dockerfile`**: Docker イメージの定義ファイル。Java, Python, Forge, Raspberry Jam Mod をインストールします。
* **`docker-compose.yaml`**: `mc-forge` サービスを定義し、ポートやボリュームを管理します。
    * **ポート (Ports):**
        * `25565:25565`: Minecraft サーバー
        * `14711:14711`: Raspberry Jam Mod WebSocket
        * `4711:4711`: Raspberry Jam Mod Socket
    * **ボリューム (Volumes):**
        * `./storage/server.properties:/bin/forge/server.properties`: サーバー設定ファイルをホストとコンテナで共有します。**ホスト側にこのファイルが必須です。**
        * `# - ./storage/mc_data:/bin/forge`: この行のコメント (`#`) を解除すると、Minecraft のデータ (ワールド、ログ等) をホストの `./storage/mc_data` ディレクトリに永続化できます。必要に応じて、さらに具体的なディレクトリ (例: `/bin/forge/world`) を指定してください。
            ```yaml
            volumes:
              - ./storage/server.properties:/bin/forge/server.properties
              - ./storage/mc_data/world:/bin/forge/world # ワールドデータ
              - ./storage/mc_data/logs:/bin/forge/logs   # ログ
              # 他にも必要なディレクトリがあれば追加
            ```
            永続化したい場合は、ホスト側に `./storage/mc_data` ディレクトリを作成してから `docker-compose up -d` を実行してください。

* **`./storage/server.properties`**: Minecraft サーバーの標準設定ファイル。ゲームモード、難易度、MOTD などを変更できます。変更後はサーバーの再起動 (`docker compose restart mc-forge` または `docker compose down && docker compose up -d`) が必要です。

## 📄 ライセンス (License)

このプロジェクトは MIT License の下で公開されています。詳細は [LICENSE](LICENSE) ファイルをご覧ください。(リポジトリに `LICENSE` ファイルを追加し、適切なライセンス内容を記述してください。MIT License の例: [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT))

## 🙏 謝辞 (Acknowledgements)

* [マインクラフトをScratchでコントロールするための環境構築手順](https://zenn.dev/nobonobo/scraps/356265adc9f61b)
* [Minecraft Forge](https://files.minecraftforge.net/net/minecraftforge/forge/)
* [Raspberry Jam Mod](https://github.com/arpruss/raspberryjammod)
* [OpenJDK](https://openjdk.java.net/)
* [Docker](https://www.docker.com/)
