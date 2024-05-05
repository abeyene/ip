//=========================================================================
// Fifo
//=========================================================================
// A Beyene
// Mar 7 2024
//
// 

`include "axi4.svh"
`include "sipo.svh"

module sipo
  (
    input  clk,
    input  sin,
    // Slave AXI4 Lite Clock and Reset
    input s_axi4lite_clk,
    input s_axi4lite_rstn,
    // Slave AXI4 Lite Write Address Interface
    output logic                         s_axi4lite_aw_ready,
    input                                s_axi4lite_aw_valid,
    input [`AXI4_ADDR_BITS-1:0]          s_axi4lite_aw_addr,
    input [`AXI4_PROT_BITS-1:0]          s_axi4lite_aw_prot,
    // Slave AXI4 Lite Write Data Interface
    output logic                         s_axi4lite_w_ready,
    input                                s_axi4lite_w_valid,
    input [`AXI4_DATA_BITS-1:0]          s_axi4lite_w_data,
    input [`AXI4_STRB_BITS-1:0]          s_axi4lite_w_strb,
    // Slave AXI4 Write Response Interface
    input                                s_axi4lite_b_ready,
    output logic                         s_axi4lite_b_valid,
    output logic [`AXI4_RESP_BITS-1:0]   s_axi4lite_b_resp,
    // Slave AXI4 Read Address Interface
    output logic                         s_axi4lite_ar_ready,
    input                                s_axi4lite_ar_valid,
    input [`AXI4_ADDR_BITS-1:0]          s_axi4lite_ar_addr,
    input [`AXI4_PROT_BITS-1:0]          s_axi4lite_ar_prot,
    // Slave AXI4 Read Data Interface
    input                                s_axi4lite_r_ready,
    output logic                         s_axi4lite_r_valid,
    output logic [`AXI4_DATA_BITS-1:0]   s_axi4lite_r_data,
    output logic [`AXI4_RESP_BITS-1:0]   s_axi4lite_r_resp
  );

  reg async_en, sync_en;
  reg async_rstn, sync_rstn, user_rstn;
  reg [`SYNC_STAGES-1:0] en_sync_regs;
  reg [`SYNC_STAGES-1:0] rstn_sync_regs;

  
  reg [$clog2(`SIPO_DEPTH)-1:0]  inp_pos, sync_inp_pos, inp_pos_dly;
  wire [$clog2(`SIPO_DEPTH)-1:0] inp_pos_nxt, sync_inp_pos_nxt;
  reg [$clog2(`SIPO_DEPTH)-1:0]  out_pos, sync_out_pos;
  wire [$clog2(`SIPO_DEPTH)-1:0] out_pos_nxt;

  reg [$clog2(`SIPO_DEPTH)-1:0] inp_pos_sync_regs_stage_1;
  reg [$clog2(`SIPO_DEPTH)-1:0] inp_pos_sync_regs_stage_2;
  reg [$clog2(`SIPO_DEPTH)-1:0] inp_pos_sync_regs_stage_3;
  reg [$clog2(`SIPO_DEPTH)-1:0] out_pos_sync_regs_stage_1;
  reg [$clog2(`SIPO_DEPTH)-1:0] out_pos_sync_regs_stage_2;
  reg [$clog2(`SIPO_DEPTH)-1:0] out_pos_sync_regs_stage_3;

  reg  [`SIPO_WIDTH-1:0] data_in;
  wire [`SIPO_WIDTH-1:0] data_out;

  assign inp_pos_nxt = inp_pos + 1;
  assign sync_inp_pos_nxt = sync_inp_pos + 1;
  assign out_pos_nxt = out_pos + 1;

  wire fifo_full, sync_fifo_full;
  wire fifo_empty;

  assign fifo_full = inp_pos_nxt == sync_out_pos;
  assign sync_fifo_full = sync_inp_pos_nxt == out_pos;
  assign fifo_empty = sync_inp_pos == out_pos;

  reg [$clog2(`SIPO_WIDTH)-1:0] counter;

  assign async_rstn = s_axi4lite_rstn & user_rstn;

  always @(posedge clk)
  begin
    en_sync_regs <= {en_sync_regs[`SYNC_STAGES-2:0], async_en};    // shift left
    sync_en <= en_sync_regs[`SYNC_STAGES-1];
    rstn_sync_regs <= {rstn_sync_regs[`SYNC_STAGES-2:0], async_rstn};    // shift left
    sync_rstn <= rstn_sync_regs[`SYNC_STAGES-1];
  end

  always @(posedge clk) 
  begin
    out_pos_sync_regs_stage_1 <= out_pos;    // shift left
    out_pos_sync_regs_stage_2 <= out_pos_sync_regs_stage_1;
    out_pos_sync_regs_stage_3 <= out_pos_sync_regs_stage_2;
    sync_out_pos <= out_pos_sync_regs_stage_3;
  end

  always @(posedge s_axi4lite_clk) 
  begin
    inp_pos_sync_regs_stage_1 <= inp_pos;    // shift left
    inp_pos_sync_regs_stage_2 <= inp_pos_sync_regs_stage_1;
    inp_pos_sync_regs_stage_3 <= inp_pos_sync_regs_stage_2;
    sync_inp_pos <= inp_pos_sync_regs_stage_3;
  end

  mem_1r1w mem(
    .W0_addr(inp_pos_dly),
    .W0_clk(clk),
    .W0_data(data_in),
    .W0_en(sync_rstn & sync_en & ~fifo_full & (~(|counter))),
    .W0_mask(1'b1),
    .R0_addr(out_pos),
    .R0_clk(s_axi4lite_clk),
    .R0_data(data_out),
    .R0_en(s_axi4lite_rstn)
  );

  always @(posedge clk)
  begin
    if (~sync_rstn)
    begin
      inp_pos     <= {$clog2(`SIPO_DEPTH){1'b0}};
      inp_pos_dly <= {$clog2(`SIPO_DEPTH){1'b0}};
      counter     <= {$clog2(`SIPO_WIDTH){1'b0}};
      data_in     <= {`SIPO_WIDTH{1'b0}};
    end
    else
    begin
      if (sync_en & ~fifo_full)
      begin
        data_in <= {data_in[`SIPO_WIDTH-2:0], sin};
        counter <= counter + $clog2(`SIPO_WIDTH)'(1);
        if (&counter)
          inp_pos <= inp_pos + $clog2(`SIPO_DEPTH)'(1);
      end
      inp_pos_dly <= inp_pos;
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

  always @(posedge s_axi4lite_clk)
  begin
    if (~s_axi4lite_rstn) 
    begin
      s_axi4lite_r_data <= `AXI4_DATA_BITS'b0;
      s_axi4lite_r_resp <= `AXI4_RESP_BITS'b0;
      s_axi4lite_r_valid <= 1'b0;
      s_axi4lite_b_resp <= `AXI4_RESP_BITS'b0;
      s_axi4lite_b_valid <= 1'b0;
      rd_req <= 0;
      wr_req <= 2'b0;
      async_en <= 1'b1;
      user_rstn <= 1'b1;
      read_addr <= `AXI4_ADDR_BITS'b0;
      write_addr <= `AXI4_ADDR_BITS'b0;
      write_data <= `AXI4_DATA_BITS'b0;
      out_pos <= {$clog2(`SIPO_DEPTH){1'b0}};
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
        case (read_addr[7:0])
        8'h00: begin
          if (!fifo_empty) 
          begin
            s_axi4lite_r_data <= data_out; 
            out_pos <= out_pos_nxt; 
          end
          else
          begin
            s_axi4lite_r_data <= `AXI4_DATA_BITS'b0;
          end
            s_axi4lite_r_resp <= `AXI4_RESP_OKAY; 
        end
        8'h08: begin
          s_axi4lite_r_data <= `AXI4_DATA_BITS'({user_rstn, async_en, sync_fifo_full, fifo_empty});
          s_axi4lite_r_resp <= `AXI4_RESP_OKAY; 
        end
        default: begin
          s_axi4lite_r_data <= `AXI4_DATA_BITS'b0;
          s_axi4lite_r_resp <= `AXI4_RESP_SLVERR; 
        end
        endcase
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
        case (write_addr[7:0])
        8'h10: begin
          async_en <= write_data[0]; 
          user_rstn <= write_data[1]; 
          s_axi4lite_b_resp <= `AXI4_RESP_OKAY; 
        end
        default: begin
          s_axi4lite_b_resp <= `AXI4_RESP_SLVERR; 
        end
        endcase
        s_axi4lite_b_valid <= 1'b1;
        wr_req <= 2'b0;
      end
    end
  end

endmodule
