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
<!--
SFL/NSLは順序回路の記述において、大きな力を発揮します。
SFLのステージ記述、NSLのプロシージャまたはステート記述により、
状態ごとの動作および状態遷移を簡潔に記述することが可能です。
-->

### アップカウンタ

まずは、簡単な32bitアップカウンタを例に説明していきましょう。

Verilog
```verilog
module counter (
    clock,
    reset,
    value
);
    input clock;
    input reset;
    output [31:0] value;

    reg [31:0] r_count;

    always @(posedge clock or posedge reset) begin
        if (reset) r_count <= 0;
        else r_count <= r_count + 1;
    end

    assign value = r_count;
endmodule
```

SFL
```sfl
declare counter {
    output value<32>;
}

circuit counter {
    reg_wr r_counter<32>;

    par {
        r_counter := r_counter + 1;
        value = r_counter;
    }
}
```

順序回路の記述において目を引くのは、クロック信号およびリセット信号に
関する記述がないところかと思います。
SFL/NSLの設計対象として、単一のクロック信号による同期回路であることが
前提となっています。したがって、暗黙のうちにクロック信号およびリセット信号が
生成されます。
PARTHENONのSFL2VerilogやNSL Coreのnsl2vlでコンパイルしたソースを見ると、
m_clock, p_resetというポートが定義されているのが分かるはずです。
VerilogやVHDLからモジュールを呼び出す場合、これらによって、
クロック信号とリセット信号を供給する必要があります。注意しましょう。

### ステートマシン

いい例が浮かばなかったので、マルチサイクルのプロセッサのステートマシン部を
考えてみましょう。

| Instruction Fetch | Decode | Register Fetch | Execute | Write Back |
|:-----------------:|:------:|:--------------:|:-------:|:----------:|
|命令をメモリから取得|命令を解釈|レジスタから値を取得|命令を実行|レジスタに値を書き戻す|

5サイクルかけて1つの命令を実行するプロセッサです。
このプロセッサの制御部、すなわちステートマシンを記述してみることにします。

Verilog
```verilog
module statemachine (
    p_reset,
    m_clock,
    start
);
    input p_reset;
    input m_clock;
    input start;

    parameter IF = 1;
    parameter DE = 2;
    parameter RF = 3;
    parameter EX = 4;
    parameter WB = 5;
    reg [2:0] state;

    always @(posedge m_clock or posedge p_reset) begin
        if (p_reset) state <= 0;
        else if (~p_reset & start) state <= IF;
        else begin
            case (state)
                IF: state <= DE;
                DE: state <= RF;
                RF: state <= EX;
                EX: state <= WB;
                WB: state <= IF; 
                default: state <= 0;
            endcase
        end
    end

endmodule
```

これがVerilogにおけるステートマシンのプリミティブな実装かと思われます。
単純な状態遷移なので、そこまで見づらくはないです。

続いてSFLのソースを見てみましょう。

SFL
```sfl
declare statemachine {
    instrin start;
}

circuit statemachine {
    stage_name IF {
        task x();
    }

    stage_name DE {
        task y();
    }

    stage_name RF {
        task z();
    }

    stage_name EX {
        task v();
    }

    stage_name WB {
        task w();
    }

    instruct start generate IF.x();

    stage IF {
        relay DE.y();
    }

    stage DE {
        relay RF.z();
    }

    stage RF {
        relay EX.v();
    }

    stage EX {
        relay WB.w();
    }

    stage WB {
        relay IF.x();
    }
}
```

多少Verilogのソースよりも長いです。ステージ構文を使用すると
どうしても冗長な感じになってしまいます。
そこで、NSLではseq構文というものが用意されました。

NSL
```nsl
declare statemachine {
    func_in start();
}

module statemachine {
    proc_name IF, DE, RF, EX, WB;
    func_self s();

    func start {
        s();
    }

    func s seq{
        IF();
        DE();
        RF();
        EX();
        WB();
        s();
    }

    proc IF finish;
    proc DE finish;
    proc RF finish;
    proc EX finish;
    proc WB finish;
}
```