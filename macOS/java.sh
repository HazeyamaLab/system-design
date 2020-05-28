#!/bin/bash

brew tap homebrew/cask
brew tap AdoptOpenJDK/openjdk

echo "Java 1.8 をインストール中です..."
brew cask install adoptopenjdk/openjdk/adoptopenjdk8
echo "Java 11 をインストールします..."
brew cask install adoptopenjdk11

java -version

echo "完了しました✨"
