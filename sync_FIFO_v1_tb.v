`timescale 1ns/1ps;
module sync_FIFO_v1_tb();
  reg         clk_in;
  reg         rst_n;
  reg  [7:0]  data;
  reg         wrreq;
  reg         rdreq1;
  reg         rdreq2;
  reg         rdreq3;
  reg         rdreq4;
  reg         rdreq;

  initial 
    begin
      clk_in = 1'b0;
      forever #5 clk_in = ~clk_in;
    end
  
  initial
    begin
      rst_n = 1'b1;
      #5;
      rst_n = 1'b0;
      #20;
      rst_n = 1'b1;
      wrreq = 1'b0;
      #30;
      wrreq = 1'b1;
      #400;
      wrreq = 1'b0;
    end

  always @(posedge clk_in)
    begin
      if(!rst_n)
        data <= 8'b1;
      else if(wrreq)
        data <= data + 8'b1;
    end

  always @(posedge clk_in)
    begin
      if(!rst_n)
        begin
          rdreq1 <= 1'b0;
          rdreq2 <= 1'b0;
	  rdreq3 <= 1'b0;
	  rdreq4 <= 1'b0;
	  rdreq  <= 1'b0;
	end
      else
        begin
          rdreq1 <= wrreq;
	  rdreq2 <= rdreq1;
	  rdreq3 <= rdreq2;
	  rdreq4 <= rdreq3;
	  rdreq  <= rdreq4;
	end
    end
 
  sync_FIFO_v1 uut(
    .clk_in  (clk_in),
    .rst_n   (rst_n),
    .data    (data),
    .wrreq   (wrreq),
    .rdreq   (rdreq),	  
    .q       (),
    .empty   (),
    .full    (),
    .usedw   ()
    );
     
endmodule