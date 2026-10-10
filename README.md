# twitch-stream-helper

Twitchのコメント読み上げ（棒読みちゃん連携）と、チャンネルポイント交換に連動した演出（音＋画面表示）を1つのブラウザページでまとめて行うツール。
常駐サーバーは使わず、ブラウザ内のWebSocket接続だけで動くのでPCへの負荷は最小限。

- コメント読み上げ：`tubeyomi` 相当（Twitchチャットを取得し、ローカルの棒読みちゃんにHTTPで渡して読み上げ）
- チャンネルポイント連動演出：`tanuesa3` 相当（Twitchのポイント交換イベントを検知して音・テロップを発火）

## 必要なもの

- 棒読みちゃん（同じPC上で起動し、「連携」機能をONにしておく）
- Twitch Developer Consoleで発行した Client ID（チャンネルポイント連動を使う場合のみ必須。コメント読み上げだけなら不要）
- GitHub Pagesなど、https:// で配信できる場所（Twitchログインのリダイレクト先として必要）

## セットアップ

### 1. 棒読みちゃん側の設定

棒読みちゃんを起動し、「その他」→「連携設定」からHTTP連携（ポート番号はデフォルト50001）を有効にする。

### 2. Twitch Developer Consoleでアプリを用意

すでに `twitch-raid-tool` 用に作成済みのアプリがある場合は、そのClient IDを流用できます。
その場合は、アプリ設定の **OAuth Redirect URLs** に、このツールを公開したURL（例: `https://<user>.github.io/twitch-stream-helper/`）を追加してください。

新規に作る場合：

1. https://dev.twitch.tv/console/apps/create を開く
2. Name: 任意（例: `stream-helper`）
3. OAuth Redirect URLs: 公開後のURL（例: `https://<user>.github.io/twitch-stream-helper/`）
4. Category: Application Integration（または任意）
5. Client Type: Public（Client Secretは使わないため）
6. 発行された **Client ID** をコピーしておく

### 3. GitHub Pagesで公開

```
cd twitch-stream-helper
git init
git add index.html README.md
git commit -m "init"
gh repo create twitch-stream-helper --public --source=. --push
gh api -X PATCH repos/{owner}/twitch-stream-helper/pages -f source[branch]=main -f source[path]=/ 2>/dev/null || true
```

（`gh repo create` 後、GitHubリポジトリの Settings → Pages で Source を `main` ブランチ・`/ (root)` に設定しても同じ）

公開されたURL（`https://<user>.github.io/twitch-stream-helper/`）をブラウザで開く。

### 4. ツール側の設定

1. 「配信チャンネル名」にTwitchのログインID（小文字）を入力
2. チャンネルポイント連動を使う場合は「Client ID」を入力し、「Twitchでログイン」を押して認証
3. 棒読みちゃんのポート番号を確認（デフォルト50001のままでOKならそのまま）
4. 「チャンネルポイント演出」で、特典名（Twitchで設定した交換アイテムのタイトルと完全一致）ごとに音声ファイルと表示文字を設定
5. 「開始」を押す

## 棒読みちゃんの自動起動（OBS連動）

OBSを開くたびに棒読みちゃんを手動で起動するのを忘れないよう、OBS起動時に自動起動させることができます。

1. OBSで「ツール」→「スクリプト」を開く
2. 左下の「＋」でこのリポジトリの `obs-auto-launch-bouyomi.lua` を追加
3. 一覧でこのスクリプトを選び、右側の「棒読みちゃんのexeパス」を自分の環境の `BouyomiChan.exe` に合わせて設定（デフォルトは `D:\bouyomi\BouyomiChan.exe`）
4. 以後、OBSを起動するたびに棒読みちゃんが起動していなければ自動で起動する（既に起動中なら何もしない）
5. 「今すぐ起動」ボタンで即座にテストできる

## OBSへの組み込み

1. OBSで「ブラウザ」ソースを追加
2. URLに、ログイン後のURL（アクセストークンが付いた状態のURLをコピーしておくと認証が保持されたまま使える）を指定
3. 幅・高さは配信解像度と同じに設定（背景は自動で透明になる）
4. 右上の⚙ボタンで操作パネルを非表示にすると、視聴者には演出だけが見える
5. 「OBSで音声を制御」にチェックを入れると演出音が配信に乗る

## 注意

- コメント読み上げは匿名でTwitchチャットに接続するだけなので認証不要
- チャンネルポイント連動にはTwitchログイン（アクセストークン）が必要。このトークンはブラウザのlocalStorageにのみ保存され、どこにも送信されない
- 音声ファイルはブラウザを開き直すたびに再選択が必要（ファイル自体をサーバーに保存しない設計のため）
- 棒読みちゃんへのリクエストはfire-and-forgetのHTTP GETのみで、常時ポーリングは行わない（チャット・ポイント連動ともにWebSocketのpush通知で動くためCPU負荷が小さい）
