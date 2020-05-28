#!/bin/bash

brew tap homebrew/cask
brew tap AdoptOpenJDK/openjdk

echo "Java 1.8 をインストール中です..."
brew cask install adoptopenjdk/openjdk/adoptopenjdk8
echo "Java 11 をインストールします..."
brew cask install adoptopenjdk11

echo "JAVA_HOMEの設定を行います..."
JAVA_HOME=$(/usr/libexec/java_home -v 11)

cat <<EOF >> ~/.bashrc
export JAVA_HOME=`${JAVA_HOME}`
PATH=${JAVA_HOME}/bin:${PATH}
EOF

source ~/.bashrc

java -version

echo "完了しました✨"
