#!/bin/bash

# Gradleのインストール関数(6.3をインストール後に6.2.2にする)
function install_gradle() {
  brew install gradle
  cd /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/ || return
  git checkout 5fd374b706a7949f13fc20c654764c2ac5986e42 gradle.rb
  brew unlink gradle
  brew install gradle
}

brew tap homebrew/cask
brew tap AdoptOpenJDK/openjdk

echo "Java 1.8 をインストール中です..."
brew cask install adoptopenjdk/openjdk/adoptopenjdk8
echo "Java 11 をインストールします..."
brew cask install adoptopenjdk11

echo "JAVA_HOMEの設定を行います..."
JAVA_HOME=$(/usr/libexec/java_home -v 11)

cat <<EOF >> ~/.bashrc
export JAVA_HOME=${JAVA_HOME}
PATH=$JAVA_HOME/bin:${PATH}
EOF

# shellcheck disable=SC1091
source ~/.bashrc

# gradleのインストール
install_gradle

gradle -version

echo "完了しました✨"
