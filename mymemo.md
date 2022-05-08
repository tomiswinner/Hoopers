+ ruby veion
ruby 2.6.3p62 (2019-04-16 revision 67580) [x86_64-linux]

+ rails version
Rails 5.2.5

+ puma version
puma version 3.12.6 

+ bundler
Bundler version 1.17.3

+ linux distro
開発環境
NAME="Amazon Linux"
VERSION="2"
ID="amzn"
ID_LIKE="centos rhel fedora"
VERSION_ID="2"
PRETTY_NAME="Amazon Linux 2"
ANSI_COLOR="0;33"
CPE_NAME="cpe:2.3:o:amazon:amazon_linux:2"
HOME_URL="https://amazonlinux.com/"
リモート
NAME="Amazon Linux"
VERSION="2"
ID="amzn"
ID_LIKE="centos rhel fedora"
VERSION_ID="2"
PRETTY_NAME="Amazon Linux 2"
ANSI_COLOR="0;33"
CPE_NAME="cpe:2.3:o:amazon:amazon_linux:2"
HOME_URL="https://amazonlinux.com/"

+ ssh
$HOME/.ssh/known_hosts を確認すること。
ssh -i ~/.ssh/practice-aws.pem [ユーザー名]@[ipアドレス]
↑のようにキーペアの private key を使用して、最初は接続をする。
-i は identity file を指定する。 id_rsa とかは ssh が勝手に探してくれるけど、
名前が違うと探してくれないってことか。

+ サーバー：nginx
調べ方は ssh 後に、lsof をすると listen しているプロセス(?)がわかる
この時ＴＣＰポート番号 http 80, https 443 なので、該当プロセスを調べればよい。
/etc 以下を grep してもよいかも。


