//=========================================================================
// Fifo
//=========================================================================
// A Beyene
// Mar 7 2024
//
// 

module fifo
  #( parameter depth = 8,
     width = 64)
  (
    input   clk,
    input   rstn,
    output  data_in_ready,
    input   data_in_valid,
    input   [width-1:0] data_in,
    input   data_out_ready,
    output  data_out_valid,
    output  [width-1:0] data_out
  );

  reg [width-1:0] mem [depth-1:0];

  reg [$clog2(depth)-1:0]  inp_pos;
  wire [$clog2(depth)-1:0] inp_pos_nxt;
  reg [$clog2(depth)-1:0]  out_pos;
  wire [$clog2(depth)-1:0] out_pos_nxt;

  assign inp_pos_nxt = inp_pos + 1;
  assign out_pos_nxt = out_pos + 1;

  wire fifo_full = inp_pos_nxt == out_pos;
  wire fifo_empty = inp_pos == out_pos;

  assign data_in_ready = rstn & ~fifo_full;
  assign data_out_valid = rstn &  ~fifo_empty;

  assign data_out = mem[out_pos];

  always @(posedge clk)
  begin
    if (~rstn)
    begin
      inp_pos <= 0; 
      out_pos <= 0; 
    end
    else
    begin
      if (data_in_ready & data_in_valid)
      begin
        inp_pos <= inp_pos + 1;
        mem[inp_pos] <= data_in;
      end
      if (data_out_ready & data_out_valid)
      begin
        out_pos <= out_pos + 1; 
      end
    end
  end 

endmodule
