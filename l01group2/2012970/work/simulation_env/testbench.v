`timescale 1ns/1ns

module testbench();

reg clk, rst_n, flick;

wire [15:0] LED;

Flash_bounder uut(clk,rst_n,flick,LED);

initial
begin

	clk = 0;

	rst_n = 0;
	
	flick = 0;
	
	#20
	rst_n = 1;
	
	#80
	flick = 1;
	
	#50
	flick = 0;

	#160
	flick = 1;

	#265
	rst_n = 0;
	
	#5
	rst_n = 1;

	#10
	flick = 0;

	#300 
	$finish;
end

initial begin
  $recordfile ("waves");
  $recordvars ("depth=0", testbench);
end

always #5 clk = ~clk;

endmodule
