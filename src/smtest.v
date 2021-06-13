
`timescale	1ns / 1ns
`default_nettype none


/*Produced by NSL Core(version=20180321), IP ARCH, Inc. Sun Jun 13 17:51:16 2021
 Licensed to :EVALUATION USER*/
/*
 DO NOT USE ANY PART OF THIS FILE FOR COMMERCIAL PRODUCTS. 
*/

module smtest ( p_reset , m_clock );
  input p_reset, m_clock;
  wire p_reset, m_clock;
  reg [9:0] tmp;
  wire _s_start;
  wire _s_p_reset;
  wire _s_m_clock;
  wire _net_0;
  wire _net_1;
statemachine s (.m_clock(m_clock), .p_reset( p_reset), .start(_s_start));


// synthesis translate_off
// synopsys translate_off
always @(posedge _s_start)
  begin
#1 if (_s_start===1'bx)
 begin
$display("Warning: control hazard(smtest:_s_start) at %d",$time);
 end
#1 if (((_net_0)===1'bx) || (1'b1)===1'bx) $display("hazard (_net_0 || 1'b1) line 16 at %d\n",$time);
 end

// synthesis translate_on
// synopsys translate_on
   assign  _s_start = _net_0;
   assign  _s_p_reset = p_reset;
   assign  _s_m_clock = m_clock;
   assign  _net_0 = (tmp==10'b0000000001);
   assign  _net_1 = 
// synthesis translate_off
// synopsys translate_off
((~_net_0))? 
// synthesis translate_on
// synopsys translate_on
(((~_net_0))?(&tmp):1'b0)
// synthesis translate_off
// synopsys translate_off
:1'bx
// synthesis translate_on
// synopsys translate_on
;

// synthesis translate_off
// synopsys translate_off
always @(posedge m_clock)
  begin
    if(((~_net_0)&_net_1))
    begin
    $finish;
    end
  end

// synthesis translate_on
// synopsys translate_on
always @(posedge m_clock or posedge p_reset)
  begin
if (p_reset)
     tmp <= 10'b0000000000;
else   tmp <= (tmp+10'b0000000001);
end
endmodule

/*Produced by NSL Core(version=20180321), IP ARCH, Inc. Sun Jun 13 17:51:16 2021
 Licensed to :EVALUATION USER*/

/*Produced by NSL Core(version=20180321), IP ARCH, Inc. Sun Jun 13 17:51:16 2021
 Licensed to :EVALUATION USER*/

//synthesis translate_off
/*
 DO NOT USE ANY PART OF THIS FILE FOR COMMERCIAL PRODUCTS. 
*/
module tb;
	parameter tCYC=2;
	parameter tPD=(tCYC/10);

	reg p_reset;
	reg m_clock;

	smtest smtest_instance(
		.p_reset(p_reset),
		.m_clock(m_clock)
	);

	initial forever #(tCYC/2) m_clock = ~m_clock;

	initial begin
		$dumpfile("smtest.vcd");
		$dumpvars(0,smtest_instance);
	end

	initial begin
		#(tPD)
			p_reset = 1;
			m_clock = 0;
		#(tCYC)
			p_reset = 0;
	end

endmodule

//synthesis translate_on
