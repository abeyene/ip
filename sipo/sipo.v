//=========================================================================
// Fifo
//=========================================================================
// A Beyene
// Mar 7 2024
//
// 

`include "axi4.svh"
`include "sipo.vh"

module sipo
  (
    input  clk,
    input  rstn,
    input  en,
    input  sin,
    // Slave AXI4 Lite Clock and Reset
    input s_axi4lite_clk,
    input s_axi4lite_rstn,
    // Slave AXI4 Lite Write Address Interface
    output                               s_axi4lite_aw_ready,
    input logic                          s_axi4lite_aw_valid,
    input logic [`AXI4_ADDR_BITS-1:0]    s_axi4lite_aw_addr,
    input logic [`AXI4_PROT_BITS-1:0]    s_axi4lite_aw_prot,
    // Slave AXI4 Lite Write Data Interface
    output                               s_axi4lite_w_ready,
    input logic                          s_axi4lite_w_valid,
    input logic [`AXI4_DATA_BITS-1:0]    s_axi4lite_w_data,
    input logic [`AXI4_STRB_BITS-1:0]    s_axi4lite_w_strb,
    // Slave AXI4 Write Response Interface
    input logic                          s_axi4lite_b_ready,
    output                               s_axi4lite_b_valid,
    output [`AXI4_RESP_BITS-1:0]         s_axi4lite_b_resp,
    // Slave AXI4 Read Address Interface
    output                               s_axi4lite_ar_ready,
    input logic                          s_axi4lite_ar_valid,
    input logic [`AXI4_ADDR_BITS-1:0]    s_axi4lite_ar_addr,
    input logic [`AXI4_PROT_BITS-1:0]    s_axi4lite_ar_prot,
    // Slave AXI4 Read Data Interface
    input logic                          s_axi4lite_r_ready,
    output                               s_axi4lite_r_valid,
    output [`AXI4_DATA_BITS-1:0]         s_axi4lite_r_data,
    output [`AXI4_RESP_BITS-1:0]         s_axi4lite_r_resp
  );

  reg [$clog2(`SIPO_DEPTH)-1:0]  inp_pos;
  wire [$clog2(`SIPO_DEPTH)-1:0] inp_pos_nxt;
  reg [$clog2(`SIPO_DEPTH)-1:0]  out_pos;
  wire [$clog2(`SIPO_DEPTH)-1:0] out_pos_nxt;

  reg  [`SIPO_WIDTH-1:0] data_in;
  wire [`SIPO_WIDTH-1:0] data_out;

  assign data_in = sin;

  assign inp_pos_nxt = inp_pos + 1;
  assign out_pos_nxt = out_pos + 1;

  wire fifo_full = inp_pos_nxt == out_pos;
  wire fifo_empty = inp_pos == out_pos;

  assign data_in_ready  = rstn & ~fifo_full;
  assign data_out_valid = rstn &  ~fifo_empty;

  reg [$clog2(`SIPO_WIDTH)-1:0] counter;

  mem_1r1w mem(
    .W0_addr(inp_pos),
    .W0_clk(clk),
    .W0_data(data_in),
    .W0_en(rstn & en & ~fifo_full),
    .W0_mask(1'b1)
    .R0_addr(out_pos),
    .R0_clk(s_axi4lite_clk),
    .R0_data(data_out),
    .R0_en(s_axi4lite_rstn),
  );

  always @(posedge clk)
  begin
    if (~rstn)
    begin
      inp_pos <= {$clog2(`SIPO_DEPTH){1'b0}};
      counter <= {$clog2(`SIPO_WIDTH){1'b0}};
      data_in <= {`SIPO_WIDTH{1'b0}};
    end
    else
    begin
      if (en & ~fifo_full)
      begin
        data_in <= {sin, data_in[SIPO_WIDTH-2:0]};
        counter <= counter + $clog2(`SIPO_WIDTH)'b1;
        if (&counter)
          inp_pos <= inp_pos + $clog2(`SIPO_DEPTH)'b1;
      end
    end
  end
 
  reg [`AXI4_ADDR_BITS-1:0] read_addr;
  reg [`AXI4_ADDR_BITS-1:0] write_addr;
  reg [`AXI4_DATA_BITS-1:0] write_data;
  reg rd_req;
  reg [1:0] wr_req;

  assign s_axi4lite_ar_ready = !rd_req && !s_axi4lite_r_valid;
  assign s_axi4lite_aw_ready = !wr_req[0] && !s_axi4lite_b_valid;
  assign s_axi4lite_w_ready  = !wr_req[1] && !s_axi4lite_b_valid;

  wire [`AXI4_ADDR_BITS-1:0] read_addr_base;
  assign read_addr_base = read_addr & ~{`AXI4_ADDR_BITS'hf};
  wire [`AXI4_ADDR_BITS-1:0] write_addr_base;
  assign write_addr_base = write_addr & ~{`AXI4_ADDR_BITS'hf};

  always @(posedge s_axi4lite_clk)
  begin
    if (~s_axi4lite_rstn) 
    begin
      s_axi4lite_r_data <= `AXI4_DATA_BITS'0;
      s_axi4lite_r_resp <= `AXI4_RESP_BITS'0;
      s_axi4lite_r_valid <= 1'b0;
      s_axi4lite_b_resp <= `AXI4_RESP_BITS'0;
      s_axi4lite_b_valid <= 1'b0;
      rd_req <= 0;
      wr_req <= 2'b0;
      read_addr <= `AXI4_ADDR_BITS'0;
      write_addr <= `AXI4_ADDR_BITS'0;
      write_data <= `AXI4_DATA_BITS'0;
      out_pos <= {$clog2(`SIPO_DEPTH){1'b0}}
    end
    else 
    begin
      if (s_axi4lite_ar_ready && s_axi4lite_ar_valid) 
      begin
        read_addr <= s_axi4lite_ar_addr;
        rd_req <= 1'b1;
      end
      if (s_axi4lite_r_valid && s_axi4lite_r_ready) 
      begin
        s_axi4lite_r_valid <= 0;
      end 
      else if (!s_axi4lite_r_valid && rd_req) 
      begin
        s_axi4lite_r_data <= `AXI4_DATA_BITS'b0;
        if (read_addr_base == `MMIO_BASE_ADDR) 
        begin
            case (read_addr[3:0])
            4'h00: if (!fifo_empty) begin s_axi4lite_r_data <= data_out; out_pos <= out_pos_nxt; end
            4'h08: s_axi4lite_r_data[1:0] <= { fifo_full, !fifo_empty };
            endcase
        end
        s_axi4lite_r_resp <= `AXI4_RESP_OKAY;
        s_axi4lite_r_valid <= 1'b1;
        rd_req <= 1'b0;
      end
      if (s_axi4lite_aw_ready && s_axi4lite_aw_valid) 
      begin
        write_addr <= s_axi4lite_aw_addr;
        wr_req[0] <= 1'b1;
      end
      if (s_axi4lite_w_ready && s_axi4lite_w_valid)
      begin
        write_data <= s_axi4lite_w_data;
        wr_req[1] <= 1'b1;
      end
      if (s_axi4lite_b_valid && s_axi4lite_b_ready) 
      begin
        s_axi4lite_b_valid <= 1'b0;
      end 
      else if (!s_axi4lite_b_valid && wr_req == 2'b11) 
      begin
        if (write_addr_base == `MMIO_BASE_ADDR) 
        begin
          case (write_addr[3:0])
          4'h0c:
            begin
              if (write_data[0]) out_pos <= write_data[$clog2(`SIPO_DEPTH)-1:0];
            end
          endcase
        end
        s_axi4lite_b_resp <= `AXI4_RESP_OKAY;
        s_axi4lite_b_valid <= 1'b1;
        wr_req <= 2'b0;
      end
    end
  end

endmodule
