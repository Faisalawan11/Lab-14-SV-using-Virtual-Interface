`include "Interface.sv"//including the interface file in this test bench 
`include "top.sv"//including top module

module mem_test ( 
                  mem_intf.tb mbus
                );
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

logic [7:0] rand_data; // stores data to write to memory
logic [7:0] rdata;      // stores data read from memory for checking

bit done; //this bit is used to randomize the data


class mem_class;
  rand  bit [7:0] data;
  randc bit [4:0] addr;

        bit [7:0] rdata;

 virtual interface mem_intf vif;
 
  constraint datadist { data dist {[8'h41:8'h5a]:=4, [8'h61:8'h7a]:=1};}

   function new (input int darg = 0, aarg = 0);//Custom constructor
  data = darg;
  addr = aarg;
 endfunction

 function void configure(virtual interface mem_intf aif);
   vif = aif;
   if (vif == null) $display ("vif configure error");
 endfunction

  task write_mem (input debug = 0 );
    @(negedge vif.clk);
    vif.write <= 1;
    vif.read  <= 0;
    vif.addr  <= addr;
    vif.data_in  <= data;
    @(negedge vif.clk);
    vif.write <= 0;
    if (debug == 1)
      $display("Write - Address:%d  Data:%h %c", addr, data, data);
  endtask
  
  task read_mem (input debug = 0 );
    @(negedge vif.clk);
     vif.write <= 0;
     vif.read  <= 1;
     vif.addr  <= addr;
    @(negedge vif.clk);
     vif.read <= 0;
     rdata = vif.data_out;
     if (debug == 1) 
       $display("Read  - Address:%d  Data:%h %c", addr, rdata, rdata);
  endtask

endclass

mem_class memrnd;//handler of mem_class


// Monitor Results
  initial begin
     

      #20000ns $display ( "MEMORY TEST TIMEOUT" );
  $finish;
  
  end
   
   
    

initial
  begin: memtest
  int error_status;

 

    memrnd = new(0,0);
    memrnd.configure(mbus);

    $display("Random Data Test");
    for (int i = 0; i< 32; i++)
    begin
      done = memrnd.randomize();
       memrnd.write_mem (1);
       memrnd.read_mem  (1);
       error_status = checkit (memrnd.addr, memrnd.rdata, memrnd.data);
    end
    printstatus(error_status);

    $finish;
  end

function int checkit (input [4:0] address,
                      input [7:0] actual, expected);
  static int error_status;   // static variable
  if (actual !== expected) begin
    $display("ERROR:  Address:%h  Data:%h  Expected:%h",
                address, actual, expected);
// SYSTEMVERILOG: post-increment
     error_status++;
   end
// SYSTEMVERILOG: function return
   return (error_status);
endfunction: checkit

// SYSTEMVERILOG: void function
function void printstatus(input int status);
if (status == 0)
   $display("Test Passed - No Errors!");
else
   $display("Test Failed with %d Errors", status);
endfunction

endmodule
