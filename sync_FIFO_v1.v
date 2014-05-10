module sync_FIFO_v1(
  input         clk_in,
  input         rst_n,
  input  [7:0]  data,
  input         wrreq,
  input         rdreq,	  
  output [7:0]  q,
  output        empty,
  output        full,
  output [3:0]  usedw
  );

  reg          full_in;
  reg          empty_in;
  reg   [7:0]  mem[15:0];
  reg   [3:0]  rd_ptr;
  reg   [3:0]  wr_ptr;
  reg   [3:0]  usedw_in;

  // memory write pointer increment
  always @(posedge clk_in)
    begin
      if(!rst_n)
        begin
          wr_ptr <= 4'b0;
	  mem[wr_ptr] <= 8'b0;
	end
      else if(wrreq && ~full_in)
        begin
	  wr_ptr <= wr_ptr + 4'b1;
	  mem[wr_ptr] <= data;
	end
    end

  // memory read pointer increment
  always @(posedge clk_in or negedge rst_n)
    begin
      if(!rst_n)
        rd_ptr <= 4'b0;
      else if(rdreq && ~empty_in)
        rd_ptr <= rd_ptr + 4'b1;
    end
  
  // generate full signal
  always @(posedge clk_in or negedge rst_n)
    begin
      if(!rst_n)
        full_in <= 1'b0;
      else if((~rdreq&&wrreq) && ((wr_ptr==rd_ptr-1) || (rd_ptr==4'h0&&wr_ptr==4'hf)))
        full_in <= 1'b1;
      else if(full_in && rdreq)
        full_in <= 1'b0;
    end
  
  //generate empty signal
  always @(posedge clk_in or negedge rst_n)
    begin
      if(!rst_n)
        empty_in <= 1'b1;
      else if((rdreq&&~wrreq) && ((rd_ptr==wr_ptr-1) || (rd_ptr==4'hf&&wr_ptr==4'h0)))
        empty_in <= 1'b1;
      else if(empty_in && wrreq)
        empty_in <= 1'b0;
    end

  // generate usedw_in signal
  always @(posedge clk_in or negedge rst_n)
    begin
      if(!rst_n)
        usedw_in <= 4'b0;
      else if(wrreq && ~rdreq)
        usedw_in <= wr_ptr + 1'b1;
      else if(wrreq && rdreq)
        usedw_in <= wr_ptr - rd_ptr + 1'b1;
      else if(~wrreq && rdreq)
        usedw_in <= usedw_in - 4'b1;
      else
        usedw_in <= 1'b0;
    end

  assign full = full_in;
  assign empty = empty_in;
  assign usedw = usedw_in;
  assign q = mem[rd_ptr];

endmodule
