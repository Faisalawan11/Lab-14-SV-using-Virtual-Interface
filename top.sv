module top;
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: logic and bit data types
logic clk = 0;

always #5 clk = ~clk;

// SYSTEMVERILOG: interface instance
mem_intf mbus (clk);

mem_test mtest (.mbus(mbus.tb));

mem m1  (.mbus(mbus.mem));

endmodule
