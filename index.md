# SFL/NSLに関するメモ
個人的にまとめておきたいSFL/NSLの書き方などについて書きます。
[聖典](http://www-lab09.kuee.kyoto-u.ac.jp/parthenon/NTT/hajimete/3shou.htm)を参照しながら読むことを推奨。

## はじめに
SFL/NSLで記述したハードウェアがFPGAなどで動作するのかと思われる方もいると思います。QuartusやVivadoはネイティブでSFL/NSLに
対応しているわけではないためです。
しかし、その点に関してはSFL/NSLをVerilogやVHDLに変換する[ソフトウェア(NSL Core)](https://www.overtone.co.jp/support/downloads/)</a>があるので、
問題ないです。

## 組み合わせ回路
組み合わせ回路の記述はVerilogとそこまで変わらないです。