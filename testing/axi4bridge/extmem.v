//---------------------------------------------------------
//  File:   Mem.v
//  Author: Abel Beyene
//  Date:   March 6, 2023
//
//  Description:
//
//  AXI4 Lite wrapper for 1RW synchronous SRAM 
//---------------------------------------------------------

`define EXTMEM_ADDR_SIZE 20

module  extmem
(
  input   logic        clk,
  input   logic        rstn,

  // Master AXI4 Lite Write Address Interface
  output logic                         s_axi4lite_aw_ready,
  input logic                          s_axi4lite_aw_valid,
  input logic [`AXI4_ADDR_BITS-1:0]    s_axi4lite_aw_addr,
  input logic [`AXI4_PROT_BITS-1:0]    s_axi4lite_aw_prot,
  // Master AXI4 Lite Write Data Interface
  output logic                         s_axi4lite_w_ready,
  input logic                          s_axi4lite_w_valid,
  input logic [`AXI4_DATA_BITS-1:0]    s_axi4lite_w_data,
  input logic [`AXI4_STRB_BITS-1:0]    s_axi4lite_w_strb,
  // Master AXI4 Lite Write Response Interface
  input logic                          s_axi4lite_b_ready,
  output logic                         s_axi4lite_b_valid,
  output logic [`AXI4_RESP_BITS-1:0]   s_axi4lite_b_resp,
  // Master AXI4 Read Address Interface
  output logic                         s_axi4lite_ar_ready,
  input logic                          s_axi4lite_ar_valid,
  input logic [`AXI4_ADDR_BITS-1:0]    s_axi4lite_ar_addr,
  input logic [`AXI4_PROT_BITS-1:0]    s_axi4lite_ar_prot,
  // Master AXI4 Read Data Interface
  input logic                          s_axi4lite_r_ready,
  output logic                         s_axi4lite_r_valid,
  output logic [`AXI4_DATA_BITS-1:0]   s_axi4lite_r_data,
  output logic [`AXI4_RESP_BITS-1:0]   s_axi4lite_r_resp
);

  localparam read_cmd_lp  = 3'b0;
  localparam write_cmd_lp = 3'b1;

  typedef enum logic [1:0] {WRITE_REQ, WRITE_RESP} wr_state_t;
  typedef enum logic [1:0] {READ_REQ, READ_RESP} r_state_t;

  wr_state_t wr_state, wr_state_n;
  r_state_t r_state, r_state_n;

  // Read port (synchronous read)

  logic                         read_en;
  logic [`EXTMEM_ADDR_SIZE-1:0] read_addr;
  logic [63:0]                  read_data;

  // Write port (sampled on the rising clock edge)

  logic                         write_en;
  logic [7:0]                   write_byte_en;
  logic [`EXTMEM_ADDR_SIZE-1:0] write_addr;
  logic [63:0]                  write_data;

  reg [1:0] wr_req;
  reg r_req;

  assign aw_fire = s_axi4lite_aw_ready & s_axi4lite_aw_valid;
  assign w_fire  = s_axi4lite_w_ready & s_axi4lite_w_valid;
  assign ar_fire  = s_axi4lite_ar_ready & s_axi4lite_ar_valid;

  always @(posedge clk)
  begin
    if (~rstn)
      wr_req[0] <= 1'b0;
    else
    begin
      case (wr_state)
        WRITE_REQ :
        begin
          if (aw_fire)
          begin
            wr_req[0] <= wr_req[0] | 1'b1;
            write_addr <= s_axi4lite_aw_addr;
          end
        end
        WRITE_RESP : 
        begin
          wr_req[0] <= 1'b0;
        end
      endcase
    end
  end

  always @(posedge clk)
  begin
    if (~rstn)
      wr_req[1] <= 1'b0;
    else
    begin
      case (wr_state)
        WRITE_REQ :
        begin
          if (w_fire)
          begin
            wr_req[1] <= wr_req[1] | 1'b1;
            write_data <= s_axi4lite_w_data;
            write_byte_en <= s_axi4lite_w_strb;
          end
        end
        WRITE_RESP :
        begin
          wr_req[1] <= 1'b0;
        end
      endcase
    end
  end

  always @(posedge clk)
  begin
    if (~rstn)
      r_req <= 1'b0;
    else
    begin
      case (r_state)
        READ_REQ :
        begin
          if (ar_fire)
          begin
            r_req[0] <= r_req[0] | 1'b1;
            read_addr <= s_axi4lite_ar_addr;
          end
        end
        READ_RESP : 
        begin
          r_req <= 1'b0;
        end
      endcase
    end
  end

  always @(*)
  begin
    case (wr_state)
      WRITE_REQ :
      begin
        s_axi4lite_aw_ready   = 1'b1;
        s_axi4lite_w_ready    = 1'b1;
        s_axi4lite_b_valid    = 1'b0;
        s_axi4lite_b_resp     = 2'b00;
        if (&wr_req)
        begin
          wr_state_n       = WRITE_RESP;
          write_en         = 1'b1;
        end
        else
        begin
          wr_state_n       = WRITE_REQ;
          write_en         = 1'b0;
        end
      end
      WRITE_RESP :
      begin
        s_axi4lite_aw_ready   = 1'b0;
        s_axi4lite_w_ready    = 1'b0;
        s_axi4lite_b_valid    = 1'b1;
        s_axi4lite_b_resp     = 2'b00;
        wr_state_n            = WRITE_REQ;
      end
    endcase
  end

  always @(*)
  begin
    case (r_state)
      READ_REQ :
      begin
        s_axi4lite_ar_ready   = 1'b1;
        s_axi4lite_r_valid    = 1'b0;
        s_axi4lite_r_resp     = 2'b00;
        s_axi4lite_r_data     = `AXI4_DATA_BITS'b0;
        if (r_req)
        begin
          r_state_n      = READ_RESP;
          read_en        = 1'b1;
        end
        else
        begin
          r_state_n      = READ_REQ;
          read_en        = 1'b0;
        end
      end
      READ_RESP :
      begin
        s_axi4lite_ar_ready   = 1'b0;
        s_axi4lite_r_valid    = 1'b1;
        s_axi4lite_r_resp     = 2'b00;
        s_axi4lite_r_data     = read_data;
        r_state_n             = READ_REQ;
      end
    endcase
  end

  always @(posedge clk)
  begin
    if (~rstn)
      wr_state <= WRITE_REQ;
    else
      wr_state <= wr_state_n;
  end

  always @(posedge clk)
  begin
    if (~rstn)
      r_state <= READ_REQ;
    else
      r_state <= r_state_n;
  end
    
  SynchronousSRAM_1rw #(.p_data_nbits(64), .p_num_entries(2**`EXTMEM_ADDR_SIZE))
    sram (  
          .clk(clk),
          .reset(rstn),
          .read_en(read_en),  
          .read_addr(read_addr),  
          .read_data(read_data),  
          .write_en(write_en),    
          .write_byte_en(write_byte_en),  
          .write_addr(write_addr),    
          .write_data(write_data)
        );
endmodule   
