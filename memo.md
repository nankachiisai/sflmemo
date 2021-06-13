# SFL/NSLに関するメモ
個人的にまとめておきたいSFL/NSLの書き方などについて書きます。
[聖典](http://www-lab09.kuee.kyoto-u.ac.jp/parthenon/NTT/hajimete/3shou.htm)を参照しながら読むことを推奨。

## はじめに
SFL/NSLで記述したハードウェアがFPGAなどで動作するのかと思われる方もいると思います。QuartusやVivadoはネイティブでSFL/NSLに
対応しているわけではないためです。
しかし、その点に関してはSFL/NSLをVerilogやVHDLに変換する[ソフトウェア(NSL Core)](https://www.overtone.co.jp/support/downloads/)</a>があるので、
問題ないです。

## 組み合わせ回路
組み合わせ回路の記述はVerilogとそこまで変わらないです。32bit加算器のコードを以下に示します。SFLのサンプルでは、parブロックが頻出します。これは、ブロック内に記述された文が並列に動作することを示すものです。

Verilog
```verilog
module adder (
    a,
    b,
    r,
    c
);
    input [31:0] a;
    input [31:0] b;
    output [31:0] r;
    output c;

    wire [32:0] tmp;

    assign tmp = {1'b0, a} + {1'b0, b};
    assign r = tmp[31:0];
    assign c = tmp[32];
endmodule
```

SFL
```sfl
declare adder {
    input a<32>;
    input b<32>;
    output s<32>;
    output c;
}

circuit adder {
    sel_v tmp<33>;

    par {
        tmp = a + b;
        s = tmp<31:0>;
        c = tmp<32>;
    }
}
```

## 順序回路
SFL/NSLは順序回路の記述において、大きな力を発揮します。
SFLのステージ記述、NSLのプロシージャまたはステート記述により、
状態ごとの動作および状態遷移を簡潔に記述することが可能です。