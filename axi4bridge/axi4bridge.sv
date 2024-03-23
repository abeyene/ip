//=========================================================================
// AXI4 Lite Bridge
//=========================================================================
// A Beyene
// Mar 7 2024
//
// Convert AXI4 protocol to AXI4 Lite

`include "axi4.svh"

module axi4bridge
  (
  input                                 clk,
  input                                 rstn,
  // Slave AXI4 Write Address Interface
  output logic                          s_axi4_aw_ready,
  input                                 s_axi4_aw_valid,
  input [`AXI4_ID_BITS-1:0]             s_axi4_aw_id,
  input [`AXI4_ADDR_BITS-1:0]           s_axi4_aw_addr,
  input [`AXI4_BURST_BITS-1:0]          s_axi4_aw_burst,
  input [`AXI4_SIZE_BITS-1:0]           s_axi4_aw_size,
  input [`AXI4_LEN_BITS-1:0]            s_axi4_aw_len,
  input [`AXI4_CACHE_BITS-1:0]          s_axi4_aw_cache,
  input                                 s_axi4_aw_lock,
  input [`AXI4_PROT_BITS-1:0]           s_axi4_aw_prot,
  input [`AXI4_QOS_BITS-1:0]            s_axi4_aw_qos,
  input [`AXI4_REGION_BITS-1:0]         s_axi4_aw_region,
  // Master AXI4 Write Data Interface
  output logic                          s_axi4_w_ready,
  input                                 s_axi4_w_valid,
  input [`AXI4_DATA_BITS-1:0]           s_axi4_w_data,
  input [`AXI4_STRB_BITS-1:0]           s_axi4_w_strb,
  input                                 s_axi4_w_last,
  // Master AXI4 Write Response Interface
  input                                 s_axi4_b_ready,
  output logic                          s_axi4_b_valid,
  output logic [`AXI4_ID_BITS-1:0]      s_axi4_b_id,
  output logic [`AXI4_RESP_BITS-1:0]    s_axi4_b_resp,
  // Master AXI4 Read Address Interface
  output logic                          s_axi4_ar_ready,
  input                                 s_axi4_ar_valid,
  input [`AXI4_ID_BITS-1:0]             s_axi4_ar_id,
  input [`AXI4_ADDR_BITS-1:0]           s_axi4_ar_addr,
  input [`AXI4_CACHE_BITS-1:0]          s_axi4_ar_cache,
  input [`AXI4_BURST_BITS-1:0]          s_axi4_ar_burst,
  input [`AXI4_SIZE_BITS-1:0]           s_axi4_ar_size,
  input [`AXI4_LEN_BITS-1:0]            s_axi4_ar_len,
  input                                 s_axi4_ar_lock,
  input [`AXI4_PROT_BITS-1:0]           s_axi4_ar_prot,
  input [`AXI4_QOS_BITS-1:0]            s_axi4_ar_qos,
  input [`AXI4_REGION_BITS-1:0]         s_axi4_ar_region,
  // Master AXI4 Read Data Interface
  input                                 s_axi4_r_ready,
  output logic                          s_axi4_r_valid,
  output logic [`AXI4_ID_BITS-1:0]      s_axi4_r_id,
  output logic [`AXI4_DATA_BITS-1:0]    s_axi4_r_data,
  output logic                          s_axi4_r_last,
  output logic [`AXI4_RESP_BITS-1:0]    s_axi4_r_resp,
  // Master AXI4 Lite Write Address Interface
  input                                 m_axi4lite_aw_ready,
  output logic                          m_axi4lite_aw_valid,
  output logic [`AXI4_ADDR_BITS-1:0]    m_axi4lite_aw_addr,
  output logic [`AXI4_PROT_BITS-1:0]    m_axi4lite_aw_prot,
  // Master AXI4 Lite Write Data Interface
  input                                 m_axi4lite_w_ready,
  output logic                          m_axi4lite_w_valid,
  output logic [`AXI4_DATA_BITS-1:0]    m_axi4lite_w_data,
  output logic [`AXI4_STRB_BITS-1:0]    m_axi4lite_w_strb,
  // Master AXI4 Write Response Interface
  output logic                          m_axi4lite_b_ready,
  input                                 m_axi4lite_b_valid,
  input [`AXI4_RESP_BITS-1:0]           m_axi4lite_b_resp,
  // Master AXI4 Read Address Interface
  input                                 m_axi4lite_ar_ready,
  output logic                          m_axi4lite_ar_valid,
  output logic [`AXI4_ADDR_BITS-1:0]    m_axi4lite_ar_addr,
  output logic [`AXI4_PROT_BITS-1:0]    m_axi4lite_ar_prot,
  // Master AXI4 Read Data Interface
  output logic                          m_axi4lite_r_ready,
  input                                 m_axi4lite_r_valid,
  input [`AXI4_DATA_BITS-1:0]           m_axi4lite_r_data,
  input [`AXI4_RESP_BITS-1:0]           m_axi4lite_r_resp
  );

  typedef struct packed {
    logic [`AXI4_ADDR_BITS-1:0] addr;
    logic [`AXI4_ID_BITS-1:0]   id;
    logic [`AXI4_LEN_BITS-1:0] len;
    logic [`AXI4_SIZE_BITS-1:0] size;
    logic [`AXI4_BURST_BITS-1:0] burst;
    logic                             lock;
    logic [`AXI4_CACHE_BITS-1:0] cache;
    logic [`AXI4_PROT_BITS-1:0] prot;
    logic [`AXI4_QOS_BITS-1:0] qos;
    logic [`AXI4_REGION_BITS-1:0] region;
  } axi4_a_pkt_t; // 67 bits

  typedef struct packed {
    logic last;
    logic [`AXI4_STRB_BITS-1:0] strb;
    logic [`AXI4_DATA_BITS-1:0] data;
  } axi4_w_pkt_t; // 73 bits

  typedef struct packed {
    logic [`AXI4_RESP_BITS-1:0] resp;
    logic [`AXI4_ID_BITS-1:0] id;
    logic [`AXI4_LEN_BITS-1:0] len;
  } axi4_b_pkt_t; // 8 bits

  typedef struct packed {
    logic [`AXI4_RESP_BITS-1:0] resp;
    logic [`AXI4_DATA_BITS-1:0] data;
    logic [`AXI4_LEN_BITS-1:0] len;
    logic [`AXI4_ADDR_BITS-1:0] addr;
    logic [`AXI4_SIZE_BITS-1:0] size;
    //logic            last;
    logic [`AXI4_ID_BITS-1:0] id;
  } axi4_r_pkt_t; // 73 bits

  axi4_a_pkt_t axi4_aw_pkt, axi4_ar_pkt;
  axi4_w_pkt_t axi4_w_pkt; 
  axi4_b_pkt_t axi4_b_pkt; 
  axi4_r_pkt_t axi4_r_pkt;

  logic s_axi4_aw_fifo_data_in_valid, s_axi4_aw_fifo_data_in_ready; 
  logic [$bits(axi4_aw_pkt)-1:0] s_axi4_aw_fifo_data_in;
  logic s_axi4_aw_fifo_data_out_valid, s_axi4_aw_fifo_data_out_ready; 
  logic [$bits(axi4_aw_pkt)-1:0] s_axi4_aw_fifo_data_out;

  logic s_axi4_w_fifo_data_in_valid, s_axi4_w_fifo_data_in_ready; 
  logic [$bits(axi4_w_pkt)-1:0] s_axi4_w_fifo_data_in;
  logic s_axi4_w_fifo_data_out_valid, s_axi4_w_fifo_data_out_ready; 
  logic [$bits(axi4_w_pkt)-1:0] s_axi4_w_fifo_data_out;

  logic m_axi4lite_b_fifo_data_in_valid, m_axi4lite_b_fifo_data_in_ready; 
  logic [$bits(axi4_b_pkt)-1:0] m_axi4lite_b_fifo_data_in;
  logic m_axi4lite_b_fifo_data_out_valid, m_axi4lite_b_fifo_data_out_ready; 
  logic [$bits(axi4_b_pkt)-1:0] m_axi4lite_b_fifo_data_out;

  logic s_axi4_aw_id_len_fifo_data_in_valid, s_axi4_aw_id_len_fifo_data_in_ready; 
  logic [`AXI4_LEN_BITS + `AXI4_ID_BITS-1:0] s_axi4_aw_id_len_fifo_data_in;
  logic s_axi4_aw_id_len_fifo_data_out_valid, s_axi4_aw_id_len_fifo_data_out_ready; 
  logic [`AXI4_LEN_BITS + `AXI4_ID_BITS-1:0] s_axi4_aw_id_len_fifo_data_out;

  logic s_axi4_ar_fifo_data_in_valid, s_axi4_ar_fifo_data_in_ready; 
  logic [$bits(axi4_ar_pkt)-1:0] s_axi4_ar_fifo_data_in;
  logic s_axi4_ar_fifo_data_out_valid, s_axi4_ar_fifo_data_out_ready; 
  logic [$bits(axi4_ar_pkt)-1:0] s_axi4_ar_fifo_data_out;

  logic s_axi4_ar_saved_fifo_data_in_valid, s_axi4_ar_saved_fifo_data_in_ready; 
  logic [`AXI4_SIZE_BITS + `AXI4_ADDR_BITS + `AXI4_LEN_BITS + `AXI4_ID_BITS-1:0] s_axi4_ar_saved_fifo_data_in;
  logic s_axi4_ar_saved_fifo_data_out_valid, s_axi4_ar_saved_fifo_data_out_ready; 
  logic [`AXI4_SIZE_BITS + `AXI4_ADDR_BITS + `AXI4_LEN_BITS + `AXI4_ID_BITS-1:0] s_axi4_ar_saved_fifo_data_out;

  logic m_axi4lite_r_fifo_data_in_valid, m_axi4lite_r_fifo_data_in_ready; 
  logic [$bits(axi4_r_pkt)-1:0] m_axi4lite_r_fifo_data_in;
  logic m_axi4lite_r_fifo_data_out_valid, m_axi4lite_r_fifo_data_out_ready; 
  logic [$bits(axi4_r_pkt)-1:0] m_axi4lite_r_fifo_data_out;

  fifo #(.width($bits(axi4_aw_pkt)))  s_axi4_aw_fifo (
          .clk(clk),
          .rstn(rstn),
          .data_in_ready(s_axi4_aw_fifo_data_in_ready),
          .data_in_valid(s_axi4_aw_fifo_data_in_valid),
          .data_in(s_axi4_aw_fifo_data_in),
          .data_out_ready(s_axi4_aw_fifo_data_out_ready),
          .data_out_valid(s_axi4_aw_fifo_data_out_valid),
          .data_out(s_axi4_aw_fifo_data_out)
          );

  fifo #(.width($bits(axi4_w_pkt)))  s_axi4_w_fifo (
          .clk(clk),
          .rstn(rstn),
          .data_in_ready(s_axi4_w_fifo_data_in_ready),
          .data_in_valid(s_axi4_w_fifo_data_in_valid),
          .data_in(s_axi4_w_fifo_data_in),
          .data_out_ready(s_axi4_w_fifo_data_out_ready),
          .data_out_valid(s_axi4_w_fifo_data_out_valid),
          .data_out(s_axi4_w_fifo_data_out)
          );

  fifo #(.width($bits(axi4_b_pkt)))  m_axi4lite_b_fifo (
          .clk(clk),
          .rstn(rstn),
          .data_in_ready(m_axi4lite_b_fifo_data_in_ready),
          .data_in_valid(m_axi4lite_b_fifo_data_in_valid),
          .data_in(m_axi4lite_b_fifo_data_in),
          .data_out_ready(m_axi4lite_b_fifo_data_out_ready),
          .data_out_valid(m_axi4lite_b_fifo_data_out_valid),
          .data_out(m_axi4lite_b_fifo_data_out)
          );

  fifo #(.width(`AXI4_LEN_BITS + `AXI4_ID_BITS))  s_axi4_aw_id_len_fifo (
          .clk(clk),
          .rstn(rstn),
          .data_in_ready(s_axi4_aw_id_len_fifo_data_in_ready),
          .data_in_valid(s_axi4_aw_id_len_fifo_data_in_valid),
          .data_in(s_axi4_aw_id_len_fifo_data_in),
          .data_out_ready(s_axi4_aw_id_len_fifo_data_out_ready),
          .data_out_valid(s_axi4_aw_id_len_fifo_data_out_valid),
          .data_out(s_axi4_aw_id_len_fifo_data_out)
          );

  fifo #(.width($bits(axi4_ar_pkt)))  s_axi4_ar_fifo (
          .clk(clk),
          .rstn(rstn),
          .data_in_ready(s_axi4_ar_fifo_data_in_ready),
          .data_in_valid(s_axi4_ar_fifo_data_in_valid),
          .data_in(s_axi4_ar_fifo_data_in),
          .data_out_ready(s_axi4_ar_fifo_data_out_ready),
          .data_out_valid(s_axi4_ar_fifo_data_out_valid),
          .data_out(s_axi4_ar_fifo_data_out)
          );

  fifo #(.width($bits(axi4_r_pkt)))  m_axi4lite_r_fifo (
          .clk(clk),
          .rstn(rstn),
          .data_in_ready(m_axi4lite_r_fifo_data_in_ready),
          .data_in_valid(m_axi4lite_r_fifo_data_in_valid),
          .data_in(m_axi4lite_r_fifo_data_in),
          .data_out_ready(m_axi4lite_r_fifo_data_out_ready),
          .data_out_valid(m_axi4lite_r_fifo_data_out_valid),
          .data_out(m_axi4lite_r_fifo_data_out)
          );

  fifo #(.width(`AXI4_SIZE_BITS + `AXI4_ADDR_BITS + `AXI4_LEN_BITS + `AXI4_ID_BITS))  s_axi4_ar_saved_fifo (
          .clk(clk),
          .rstn(rstn),
          .data_in_ready(s_axi4_ar_saved_fifo_data_in_ready),
          .data_in_valid(s_axi4_ar_saved_fifo_data_in_valid),
          .data_in(s_axi4_ar_saved_fifo_data_in),
          .data_out_ready(s_axi4_ar_saved_fifo_data_out_ready),
          .data_out_valid(s_axi4_ar_saved_fifo_data_out_valid),
          .data_out(s_axi4_ar_saved_fifo_data_out)
          );

  /************************* BEGIN: Slave AXI4 AW Logic ***********************/

  typedef enum logic [3:0] {S_AXI4_AW_STATE_IDLE, S_AXI4_AW_STATE_CHECK, S_AXI4_AW_STATE_CONVERT, S_AXI4_AW_STATE_STORE, S_AXI4_AW_STATE_WAIT} s_axi4_aw_state_t;
  s_axi4_aw_state_t s_axi4_aw_state, s_axi4_aw_state_n, s_axi4_aw_state_p;

  reg [`AXI4_ADDR_BITS-1:0] s_axi4_aw_aligned_addr_r;
  reg [`AXI4_ADDR_BITS-1:0] s_axi4_aw_wrap_boundary_r;
  reg [`AXI4_ADDR_BITS-1:0] s_axi4_aw_other_addr_r;
  reg [7:0] s_axi4_aw_burst_count_r;
  reg [`AXI4_ADDR_BITS-1:0] s_axi4_aw_addr_offset_r;

  always_comb
  begin
    case (s_axi4_aw_state)
      S_AXI4_AW_STATE_IDLE :
        begin
          s_axi4_aw_ready = 1'b1;
          s_axi4_aw_fifo_data_in_valid = 1'b0;
          s_axi4_aw_id_len_fifo_data_in_valid = 1'b0;
          if (s_axi4_aw_valid)
          begin
            s_axi4_aw_state_n = S_AXI4_AW_STATE_CHECK;
          end
        end
      S_AXI4_AW_STATE_CHECK :
        begin
          s_axi4_aw_ready = 1'b0;
          s_axi4_aw_fifo_data_in_valid = 1'b0;
          s_axi4_aw_id_len_fifo_data_in_valid = 1'b0;
          s_axi4_aw_state_n = S_AXI4_AW_STATE_STORE;
        end
      S_AXI4_AW_STATE_CONVERT :
        begin
          s_axi4_aw_ready = 1'b0;
          s_axi4_aw_fifo_data_in_valid = 1'b0;
          s_axi4_aw_id_len_fifo_data_in_valid = 1'b0;
          s_axi4_aw_state_n = S_AXI4_AW_STATE_STORE;
        end
      S_AXI4_AW_STATE_STORE :
        begin
          s_axi4_aw_ready = 1'b0;
          s_axi4_aw_fifo_data_in_valid = 1'b1;
          s_axi4_aw_id_len_fifo_data_in_valid = 1'b1;
          s_axi4_aw_state_n = s_axi4_aw_fifo_data_in_ready & s_axi4_aw_id_len_fifo_data_in_ready ? (s_axi4_aw_burst_count_r == axi4_aw_pkt.len ? S_AXI4_AW_STATE_WAIT : S_AXI4_AW_STATE_CONVERT) : S_AXI4_AW_STATE_STORE;
        end
      S_AXI4_AW_STATE_WAIT :
        begin
          s_axi4_aw_ready = 1'b0;
          s_axi4_aw_fifo_data_in_valid = 1'b0;
          s_axi4_aw_id_len_fifo_data_in_valid = 1'b0;
          s_axi4_aw_state_n = s_axi4_b_ready & s_axi4_b_valid ? S_AXI4_AW_STATE_IDLE : S_AXI4_AW_STATE_WAIT;
        end
      default :
        begin
          s_axi4_aw_ready = 1'b0;
          s_axi4_aw_fifo_data_in_valid = 1'b1;
          s_axi4_aw_state_n = S_AXI4_AW_STATE_IDLE;
        end
      endcase
  end

  always @(posedge clk)
  begin
    if (~rstn)
    begin
      s_axi4_aw_state <= S_AXI4_AW_STATE_IDLE;
      s_axi4_aw_state_p <= S_AXI4_AW_STATE_IDLE;
    end
    else
    begin
      s_axi4_aw_state   <= s_axi4_aw_state_n;
      s_axi4_aw_state_p <= s_axi4_aw_state;
    end
  end

  always @(posedge clk)
  begin
    if (s_axi4_aw_state == S_AXI4_AW_STATE_IDLE) 
    begin
      if (s_axi4_aw_state_n == S_AXI4_AW_STATE_CHECK)
      begin
        axi4_aw_pkt.id <= s_axi4_aw_id;
        axi4_aw_pkt.addr <= s_axi4_aw_addr;
        axi4_aw_pkt.burst <= s_axi4_aw_burst;
        axi4_aw_pkt.len <= s_axi4_aw_len;
        axi4_aw_pkt.size <= s_axi4_aw_size;
        axi4_aw_pkt.region <= s_axi4_aw_region;
        axi4_aw_pkt.cache <= s_axi4_aw_cache;
        axi4_aw_pkt.prot <= s_axi4_aw_prot;
        axi4_aw_pkt.qos <= s_axi4_aw_qos;
        axi4_aw_pkt.lock <= s_axi4_aw_lock;

        s_axi4_aw_aligned_addr_r <= s_axi4_aw_addr & ({`AXI4_ADDR_BITS{1'b1}} << s_axi4_aw_size);
        s_axi4_aw_wrap_boundary_r <= s_axi4_aw_addr & ({`AXI4_ADDR_BITS{1'b1}} << (s_axi4_aw_len << (1 << s_axi4_aw_size)));
      end
      else
      begin
        axi4_aw_pkt.id <= `AXI4_ID_BITS'b0;
        axi4_aw_pkt.addr <= `AXI4_ADDR_BITS'b0;
        axi4_aw_pkt.burst <= `AXI4_BURST_BITS'b0;
        axi4_aw_pkt.len <= `AXI4_LEN_BITS'b0;
        axi4_aw_pkt.size <= `AXI4_SIZE_BITS'b0;
        axi4_aw_pkt.region <= `AXI4_REGION_BITS'b0;
        axi4_aw_pkt.cache <= `AXI4_CACHE_BITS'b0;
        axi4_aw_pkt.prot <= `AXI4_PROT_BITS'b0;
        axi4_aw_pkt.qos <= `AXI4_QOS_BITS'b0;
        axi4_aw_pkt.lock <= `AXI4_LOCK_BITS'b0;

        s_axi4_aw_aligned_addr_r <= `AXI4_ADDR_BITS'b0;
        s_axi4_aw_wrap_boundary_r <= `AXI4_ADDR_BITS'b0;

      end
    end
  end

  always @(posedge clk)
  begin
    if (s_axi4_aw_state == S_AXI4_AW_STATE_CHECK)
    begin
      s_axi4_aw_burst_count_r <= `AXI4_LEN_BITS'b0;
      s_axi4_aw_addr_offset_r <= `AXI4_ADDR_BITS'b1 << axi4_aw_pkt.size;
      s_axi4_aw_other_addr_r  <= axi4_aw_pkt.addr;
    end
    if (s_axi4_aw_state == S_AXI4_AW_STATE_CONVERT && s_axi4_aw_state_n == S_AXI4_AW_STATE_STORE)
    begin
      case (axi4_aw_pkt.burst)
        `AXI4_BURST_BITS'h1 : axi4_aw_pkt.addr <= s_axi4_aw_aligned_addr_r + s_axi4_aw_addr_offset_r;
        `AXI4_BURST_BITS'h2 : 
          begin
            if (axi4_aw_pkt.addr < s_axi4_aw_wrap_boundary_r)
              axi4_aw_pkt.addr <= s_axi4_aw_aligned_addr_r + s_axi4_aw_addr_offset_r;
            else if (axi4_aw_pkt.addr == s_axi4_aw_wrap_boundary_r + (`AXI4_ADDR_BITS'(s_axi4_aw_len) << (`AXI4_ADDR_BITS'b1 << s_axi4_aw_size)))
              axi4_aw_pkt.addr <= s_axi4_aw_wrap_boundary_r;
            else
              axi4_aw_pkt.addr <= s_axi4_aw_other_addr_r - (`AXI4_ADDR_BITS'(s_axi4_aw_len) << (`AXI4_ADDR_BITS'b1 << s_axi4_aw_size));
          end
      endcase
      s_axi4_aw_burst_count_r <= s_axi4_aw_burst_count_r + `AXI4_LEN_BITS'b1; 
      s_axi4_aw_addr_offset_r <= s_axi4_aw_addr_offset_r + (`AXI4_ADDR_BITS'b1 << axi4_aw_pkt.size);
      s_axi4_aw_other_addr_r <= s_axi4_aw_other_addr_r + (`AXI4_ADDR_BITS'b1 << axi4_aw_pkt.size);
    end
  end


  /************************* END: Slave AXI4 AW Logic ***********************/

  assign s_axi4_aw_fifo_data_in = {axi4_aw_pkt.region, axi4_aw_pkt.qos, axi4_aw_pkt.prot, axi4_aw_pkt.lock, axi4_aw_pkt.cache, axi4_aw_pkt.len, axi4_aw_pkt.size,  axi4_aw_pkt.burst, axi4_aw_pkt.addr, axi4_aw_pkt.id};

  assign s_axi4_aw_fifo_data_out_ready = m_axi4lite_aw_ready;
  assign m_axi4lite_aw_valid = s_axi4_aw_fifo_data_out_valid;
  assign m_axi4lite_aw_addr = s_axi4_aw_fifo_data_out[`AXI4_ID_BITS+:`AXI4_ADDR_BITS];
  assign m_axi4lite_aw_prot = s_axi4_aw_fifo_data_out[`AXI4_ID_BITS+`AXI4_ADDR_BITS+`AXI4_BURST_BITS+`AXI4_SIZE_BITS+`AXI4_LEN_BITS+`AXI4_CACHE_BITS+`AXI4_LOCK_BITS+:`AXI4_PROT_BITS];

  /************************* BEGIN: Slave AXI4 W Logic ***********************/

  typedef enum logic [3:0] {S_AXI4_W_STATE_IDLE, S_AXI4_W_STATE_CHECK, S_AXI4_W_STATE_CONVERT, S_AXI4_W_STATE_STORE, S_AXI4_W_STATE_WAIT} s_axi4_w_state_t;
  s_axi4_w_state_t s_axi4_w_state, s_axi4_w_state_n, s_axi4_w_state_p;

  always_comb
  begin
    case (s_axi4_w_state)
      S_AXI4_W_STATE_IDLE :
        begin
          s_axi4_w_ready = 1'b1;
          s_axi4_w_fifo_data_in_valid = 1'b0;
          if (s_axi4_w_valid)
          begin
            s_axi4_w_state_n = S_AXI4_W_STATE_CONVERT;
          end
        end
      S_AXI4_W_STATE_CONVERT :
        begin
          s_axi4_w_ready = 1'b0;
          s_axi4_w_fifo_data_in_valid = 1'b0;
          s_axi4_w_state_n = S_AXI4_W_STATE_STORE;
        end
      S_AXI4_W_STATE_STORE :
        begin
          s_axi4_w_ready = 1'b0;
          s_axi4_w_fifo_data_in_valid = 1'b1;
          s_axi4_w_state_n = s_axi4_w_fifo_data_in_ready ? (axi4_w_pkt.last ? S_AXI4_W_STATE_WAIT : S_AXI4_W_STATE_IDLE) : S_AXI4_W_STATE_STORE;
        end
      S_AXI4_W_STATE_WAIT :
        begin
          s_axi4_w_ready = 1'b0;
          s_axi4_w_fifo_data_in_valid = 1'b0;
          s_axi4_w_state_n = s_axi4_b_ready & s_axi4_b_valid ? S_AXI4_W_STATE_IDLE : S_AXI4_W_STATE_WAIT;
        end
      default :
        begin
          s_axi4_w_ready = 1'b0;
          s_axi4_w_fifo_data_in_valid = 1'b1;
          s_axi4_w_state_n = S_AXI4_W_STATE_IDLE;
        end
    endcase
  end

  always @(posedge clk)
  begin
    if (~rstn)
    begin
      s_axi4_w_state <= S_AXI4_W_STATE_IDLE;
      s_axi4_w_state_p <= S_AXI4_W_STATE_IDLE;
    end
    else
    begin
      s_axi4_w_state   <= s_axi4_w_state_n;
      s_axi4_w_state_p <= s_axi4_w_state;
    end
  end

  always @(posedge clk)
  begin
    if (s_axi4_w_state == S_AXI4_W_STATE_IDLE) 
    begin
      if (s_axi4_w_state_n == S_AXI4_W_STATE_CONVERT)
      begin
        axi4_w_pkt.data <= s_axi4_w_data;
        axi4_w_pkt.strb <= s_axi4_w_strb;
        axi4_w_pkt.last <= s_axi4_w_last;
      end
      else
      begin
        axi4_w_pkt.data <= `AXI4_DATA_BITS'b0;
        axi4_w_pkt.strb <= `AXI4_STRB_BITS'b0;
        axi4_w_pkt.last <= 1'b0;
      end
    end
  end

  /************************* END: Slave AXI4 W Logic ***********************/

  assign s_axi4_w_fifo_data_in = {axi4_w_pkt.last, axi4_w_pkt.strb, axi4_w_pkt.data};

  assign s_axi4_w_fifo_data_out_ready = m_axi4lite_w_ready;
  assign m_axi4lite_w_valid = s_axi4_w_fifo_data_out_valid;
  assign m_axi4lite_w_data  = s_axi4_w_fifo_data_out[0+:`AXI4_DATA_BITS];
  assign m_axi4lite_w_strb  = s_axi4_w_fifo_data_out[`AXI4_DATA_BITS+:`AXI4_STRB_BITS];

  /************************* START: Slave AXI4 B Logic ***********************/

  typedef enum logic [3:0] {S_AXI4_B_STATE_IDLE, S_AXI4_B_STATE_CHECK, S_AXI4_B_STATE_SEND, S_AXI4_B_STATE_WAIT} s_axi4_b_state_t;
  s_axi4_b_state_t s_axi4_b_state, s_axi4_b_state_n, s_axi4_b_state_p;

  reg [7:0] s_axi4_b_burst_count_r;

  always_comb
  begin
    case (s_axi4_b_state)
      S_AXI4_B_STATE_IDLE :
        begin
          s_axi4_b_valid = 0;
          if (m_axi4lite_b_fifo_data_out_valid & s_axi4_aw_id_len_fifo_data_out_valid)
          begin
            s_axi4_b_state_n = S_AXI4_B_STATE_CHECK;
          end
        end
      S_AXI4_B_STATE_CHECK :
        begin
          s_axi4_b_valid = 0;
          s_axi4_b_state_n = s_axi4_b_burst_count_r == axi4_b_pkt.len ? S_AXI4_B_STATE_SEND : S_AXI4_B_STATE_WAIT;
        end
      S_AXI4_B_STATE_WAIT :
        begin
          s_axi4_b_valid = 0;
          if (m_axi4lite_b_fifo_data_out_valid)
          begin
            s_axi4_b_state_n = S_AXI4_B_STATE_CHECK;
          end
        end
      S_AXI4_B_STATE_SEND :
        begin
          s_axi4_b_valid = 1;
          s_axi4_b_state_n = (s_axi4_b_ready == 1'b1) ? S_AXI4_B_STATE_IDLE : S_AXI4_B_STATE_SEND;
        end
      default :
        begin
          s_axi4_b_valid = 0;
          s_axi4_b_state_n = S_AXI4_B_STATE_IDLE;
        end
    endcase
  end

  always @(posedge clk)
  begin
    if (s_axi4_b_state == S_AXI4_B_STATE_IDLE & s_axi4_b_state_n == S_AXI4_B_STATE_CHECK)
    begin
      axi4_b_pkt.id  <= s_axi4_aw_id_len_fifo_data_out[0+:`AXI4_ID_BITS];
      axi4_b_pkt.len <= s_axi4_aw_id_len_fifo_data_out[`AXI4_ID_BITS+:`AXI4_LEN_BITS];
    end
    if (s_axi4_b_state == S_AXI4_B_STATE_IDLE & s_axi4_b_state_n == S_AXI4_B_STATE_CHECK)
    begin
      axi4_b_pkt.resp <= m_axi4lite_b_fifo_data_out;
    end
    else if (s_axi4_b_state == S_AXI4_B_STATE_IDLE & s_axi4_b_state_n == S_AXI4_B_STATE_CHECK)
    begin
      if (axi4_b_pkt.resp == {`AXI4_RESP_BITS{1'b0}})
        axi4_b_pkt.resp <= m_axi4lite_b_fifo_data_out;
    end
    if (s_axi4_b_state == S_AXI4_B_STATE_IDLE)
    begin
      s_axi4_b_burst_count_r <= `AXI4_LEN_BITS'b0;
    end
    else if (s_axi4_b_state == S_AXI4_B_STATE_CHECK & s_axi4_b_state_n == S_AXI4_B_STATE_WAIT)
    begin
      s_axi4_b_burst_count_r <= s_axi4_b_burst_count_r + `AXI4_LEN_BITS'b1;
    end
  end

  always @(posedge clk)
  begin
    if (~rstn)
    begin
      s_axi4_b_state <= S_AXI4_B_STATE_IDLE;
      s_axi4_b_state_p <= S_AXI4_B_STATE_IDLE;
    end
    else
    begin
      s_axi4_b_state   <= s_axi4_b_state_n;
      s_axi4_b_state_p <= s_axi4_b_state;
    end
  end

  /************************* END: Slave AXI4 B Logic ***********************/

  assign m_axi4lite_b_fifo_data_out_ready = ((s_axi4_b_state == S_AXI4_B_STATE_IDLE | s_axi4_b_state == S_AXI4_B_STATE_WAIT) & s_axi4_b_state_n == S_AXI4_B_STATE_CHECK) ? 1'b1 : 1'b0;
  assign s_axi4_aw_id_len_fifo_data_out_ready = ((s_axi4_b_state == S_AXI4_B_STATE_IDLE | s_axi4_b_state == S_AXI4_B_STATE_WAIT) & s_axi4_b_state_n == S_AXI4_B_STATE_CHECK) ? 1'b1 : 1'b0;

  assign s_axi4_aw_id_len_fifo_data_in = {axi4_aw_pkt.len, axi4_aw_pkt.id};

  assign m_axi4lite_b_ready = m_axi4lite_b_fifo_data_in_ready;
  assign m_axi4lite_b_fifo_data_in_valid = m_axi4lite_b_valid;
  assign m_axi4lite_b_fifo_data_in       = m_axi4lite_b_resp;

  assign s_axi4_b_resp = s_axi4_b_state == S_AXI4_B_STATE_SEND ? axi4_b_pkt.resp : `AXI4_RESP_BITS'b0;
  assign s_axi4_b_id = s_axi4_b_state == S_AXI4_B_STATE_SEND ? axi4_b_pkt.id : `AXI4_ID_BITS'b0;

  /************************* BEGIN: Slave AXI4 AR Logic ***********************/

  typedef enum logic [3:0] {S_AXI4_AR_STATE_IDLE, S_AXI4_AR_STATE_CHECK, S_AXI4_AR_STATE_CONVERT, S_AXI4_AR_STATE_STORE, S_AXI4_AR_STATE_WAIT} s_axi4_ar_state_t;
  s_axi4_ar_state_t s_axi4_ar_state, s_axi4_ar_state_n, s_axi4_ar_state_p;

  reg [`AXI4_ADDR_BITS-1:0] s_axi4_ar_aligned_addr_r;
  reg [`AXI4_ADDR_BITS-1:0] s_axi4_ar_wrap_boundary_r;
  reg [`AXI4_ADDR_BITS-1:0] s_axi4_ar_other_addr_r;
  reg [7:0] s_axi4_ar_burst_count_r;
  reg [`AXI4_ADDR_BITS-1:0] s_axi4_ar_addr_offset_r;

  always_comb
  begin
    case (s_axi4_ar_state)
      S_AXI4_AR_STATE_IDLE :
        begin
          s_axi4_ar_ready = 1'b1;
          s_axi4_ar_fifo_data_in_valid = 1'b0;
          s_axi4_ar_saved_fifo_data_in_valid = 1'b0;
          if (s_axi4_ar_valid)
          begin
            s_axi4_ar_state_n = S_AXI4_AR_STATE_CHECK;
          end
        end
      S_AXI4_AR_STATE_CHECK :
        begin
          s_axi4_ar_ready = 1'b0;
          s_axi4_ar_fifo_data_in_valid = 1'b0;
          s_axi4_ar_saved_fifo_data_in_valid = 1'b0;
          s_axi4_ar_state_n = S_AXI4_AR_STATE_STORE;
        end
      S_AXI4_AR_STATE_CONVERT :
        begin
          s_axi4_ar_ready = 1'b0;
          s_axi4_ar_fifo_data_in_valid = 1'b0;
          s_axi4_ar_saved_fifo_data_in_valid = 1'b0;
          s_axi4_ar_state_n = S_AXI4_AR_STATE_STORE;
        end
      S_AXI4_AR_STATE_STORE :
        begin
          s_axi4_ar_ready = 1'b0;
          s_axi4_ar_fifo_data_in_valid = 1'b1;
          s_axi4_ar_saved_fifo_data_in_valid = 1'b1;
          s_axi4_ar_state_n = s_axi4_ar_fifo_data_in_ready & s_axi4_ar_saved_fifo_data_in_ready ? (s_axi4_ar_burst_count_r == axi4_ar_pkt.len ? S_AXI4_AR_STATE_WAIT : S_AXI4_AR_STATE_CONVERT) : S_AXI4_AR_STATE_STORE;
        end
      S_AXI4_AR_STATE_WAIT :
        begin
          s_axi4_ar_ready = 1'b0;
          s_axi4_ar_fifo_data_in_valid = 1'b0;
          s_axi4_ar_saved_fifo_data_in_valid = 1'b0;
          s_axi4_ar_state_n = s_axi4_r_ready & s_axi4_r_valid ? S_AXI4_AR_STATE_IDLE : S_AXI4_AR_STATE_WAIT;
        end
      default :
        begin
          s_axi4_ar_ready = 1'b0;
          s_axi4_ar_fifo_data_in_valid = 1'b1;
          s_axi4_ar_state_n = S_AXI4_AR_STATE_IDLE;
        end
    endcase
  end

  always @(posedge clk)
  begin
    if (~rstn)
    begin
      s_axi4_ar_state <= S_AXI4_AR_STATE_IDLE;
      s_axi4_ar_state_p <= S_AXI4_AR_STATE_IDLE;
    end
    else
    begin
      s_axi4_ar_state   <= s_axi4_ar_state_n;
      s_axi4_ar_state_p <= s_axi4_ar_state;
    end
  end

  always @(posedge clk)
  begin
    if (s_axi4_ar_state == S_AXI4_AR_STATE_IDLE & s_axi4_ar_state_n == S_AXI4_AR_STATE_CHECK)
    begin
      axi4_ar_pkt.id <= s_axi4_ar_id;
      axi4_ar_pkt.addr <= s_axi4_ar_addr;
      axi4_ar_pkt.burst <= s_axi4_ar_burst;
      axi4_ar_pkt.len <= s_axi4_ar_len;
      axi4_ar_pkt.size <= s_axi4_ar_size;
      axi4_ar_pkt.region <= s_axi4_ar_region;
      axi4_ar_pkt.cache <= s_axi4_ar_cache;
      axi4_ar_pkt.prot <= s_axi4_ar_prot;
      axi4_ar_pkt.qos <= s_axi4_ar_qos;
      axi4_ar_pkt.lock <= s_axi4_ar_lock;

      s_axi4_ar_aligned_addr_r <= s_axi4_ar_addr & ({`AXI4_ADDR_BITS{1'b1}} << s_axi4_ar_size);
      s_axi4_ar_wrap_boundary_r <= s_axi4_ar_addr & ({`AXI4_ADDR_BITS{1'b1}} << (s_axi4_ar_len << ({`AXI4_ADDR_BITS{1'b1}} << s_axi4_ar_size)));
    end
  end

  always @(posedge clk)
  begin
    if (s_axi4_ar_state == S_AXI4_AR_STATE_CHECK)
    begin
      s_axi4_ar_burst_count_r <= `AXI4_LEN_BITS'b0;
      s_axi4_ar_addr_offset_r <= `AXI4_ADDR_BITS'b1 << axi4_ar_pkt.size;
      s_axi4_ar_other_addr_r  <= axi4_ar_pkt.addr;
    end
    if (s_axi4_ar_state == S_AXI4_AR_STATE_STORE && s_axi4_ar_state_n == S_AXI4_AR_STATE_CONVERT)
    begin
      case (axi4_ar_pkt.burst)
        `AXI4_BURST_BITS'h1 : axi4_ar_pkt.addr <= s_axi4_ar_aligned_addr_r + s_axi4_ar_addr_offset_r;
        `AXI4_BURST_BITS'h2 : 
          begin
            if (axi4_ar_pkt.addr < s_axi4_ar_wrap_boundary_r)
              axi4_ar_pkt.addr <= s_axi4_ar_aligned_addr_r + s_axi4_ar_addr_offset_r;
            else if (axi4_ar_pkt.addr == s_axi4_ar_wrap_boundary_r + (`AXI4_ADDR_BITS'(s_axi4_ar_len) << (`AXI4_ADDR_BITS'b1 << s_axi4_ar_size)))
              axi4_ar_pkt.addr <= s_axi4_ar_wrap_boundary_r;
            else
              axi4_ar_pkt.addr <= s_axi4_ar_other_addr_r - (`AXI4_ADDR_BITS'(s_axi4_ar_len) << (`AXI4_ADDR_BITS'b1 << s_axi4_ar_size));
          end
      endcase
      s_axi4_ar_burst_count_r <= s_axi4_ar_burst_count_r + `AXI4_LEN_BITS'b1; 
      s_axi4_ar_addr_offset_r <= s_axi4_ar_addr_offset_r + (`AXI4_ADDR_BITS'b1 << axi4_ar_pkt.size);
      s_axi4_ar_other_addr_r <= s_axi4_ar_other_addr_r + (`AXI4_ADDR_BITS'b1 << axi4_ar_pkt.size);
    end
  end


  /************************* END: Slave AXI4 AR Logic ***********************/

  assign s_axi4_ar_fifo_data_in = {axi4_ar_pkt.region, axi4_ar_pkt.qos, axi4_ar_pkt.prot, axi4_ar_pkt.lock, axi4_ar_pkt.cache, axi4_ar_pkt.len, axi4_ar_pkt.size,  axi4_ar_pkt.burst, axi4_ar_pkt.addr, axi4_ar_pkt.id};

  assign s_axi4_ar_fifo_data_out_ready = m_axi4lite_ar_ready;
  assign m_axi4lite_ar_valid = s_axi4_ar_fifo_data_out_valid;
  assign m_axi4lite_ar_addr = s_axi4_ar_fifo_data_out[`AXI4_ID_BITS+:`AXI4_ADDR_BITS];
  assign m_axi4lite_ar_prot = s_axi4_ar_fifo_data_out[`AXI4_ID_BITS+`AXI4_ADDR_BITS+`AXI4_BURST_BITS+`AXI4_SIZE_BITS+`AXI4_LEN_BITS+`AXI4_CACHE_BITS+`AXI4_LOCK_BITS+:`AXI4_PROT_BITS];

  /************************* START: Slave AXI4 R Logic ***********************/

  typedef enum logic [3:0] {S_AXI4_R_STATE_IDLE, S_AXI4_R_STATE_CHECK, S_AXI4_R_STATE_SEND, S_AXI4_R_STATE_WAIT} s_axi4_r_state_t;
  s_axi4_r_state_t s_axi4_r_state, s_axi4_r_state_n, s_axi4_r_state_p;

  reg [7:0] s_axi4_r_burst_count_r;
  reg [$clog2(`AXI4_STRB_BITS)-1:0] upper_byte_lane, lower_byte_lane;
  wire [`AXI4_DATA_BITS-1:0] s_axi4_r_data_mask;
  wire [`AXI4_DATA_BITS-1:0] s_axi4_r_data_mask_lower;
  wire [`AXI4_DATA_BITS-1:0] s_axi4_r_data_mask_upper;

  always_comb
  begin
    case (s_axi4_r_state)
      S_AXI4_R_STATE_IDLE :
        begin
          s_axi4_r_valid = 1'b0;
          s_axi4_r_last  = 1'b0;
          if (m_axi4lite_r_fifo_data_out_valid & s_axi4_ar_saved_fifo_data_out_valid)
          begin
            s_axi4_r_state_n = S_AXI4_R_STATE_CHECK;
          end
        end
      S_AXI4_R_STATE_WAIT :
        begin
          s_axi4_r_valid = 1'b0;
          s_axi4_r_last  = 1'b0;
          if (m_axi4lite_r_fifo_data_out_valid)
          begin
            s_axi4_r_state_n = S_AXI4_R_STATE_CHECK;
          end
        end
      S_AXI4_R_STATE_CHECK :
        begin
          s_axi4_r_valid = 1'b0;
          s_axi4_r_last  = 1'b0;
          s_axi4_r_state_n = S_AXI4_R_STATE_SEND;
        end
      S_AXI4_R_STATE_SEND :
        begin
          s_axi4_r_valid = 1'b1;
          s_axi4_r_last  = s_axi4_r_burst_count_r == axi4_r_pkt.len;
          s_axi4_r_state_n = (s_axi4_r_ready == 1'b1) ? (s_axi4_r_burst_count_r == axi4_r_pkt.len ? S_AXI4_R_STATE_IDLE : S_AXI4_R_STATE_WAIT) : S_AXI4_R_STATE_SEND;
        end
      default :
        begin
          s_axi4_r_valid = 0;
          s_axi4_r_state_n = S_AXI4_R_STATE_IDLE;
        end
      endcase
  end

  always @(posedge clk)
  begin
    if ((s_axi4_r_state == S_AXI4_R_STATE_IDLE | s_axi4_r_state == S_AXI4_R_STATE_WAIT) & s_axi4_r_state_n == S_AXI4_R_STATE_CHECK)
    begin
      axi4_r_pkt.id   <= s_axi4_ar_saved_fifo_data_out[0+:`AXI4_ID_BITS];
      axi4_r_pkt.len  <= s_axi4_ar_saved_fifo_data_out[`AXI4_ID_BITS+:`AXI4_LEN_BITS];
      axi4_r_pkt.addr <= s_axi4_ar_saved_fifo_data_out[(`AXI4_ID_BITS+`AXI4_LEN_BITS)+:`AXI4_ADDR_BITS];
      axi4_r_pkt.size <= s_axi4_ar_saved_fifo_data_out[(`AXI4_ID_BITS+`AXI4_LEN_BITS+`AXI4_ADDR_BITS)+:`AXI4_SIZE_BITS];
    end

    if (s_axi4_r_state == S_AXI4_R_STATE_CHECK)
    begin
      if (s_axi4_r_burst_count_r == `AXI4_LEN_BITS'b0)
      begin
        lower_byte_lane <= axi4_r_pkt.addr - (axi4_r_pkt.addr & ~(`AXI4_ADDR_BITS'(`AXI4_DATA_BITS / 8) - 1));
        upper_byte_lane <= (axi4_r_pkt.addr & ~(`AXI4_ADDR_BITS'(`AXI4_ADDR_BITS'b1 << axi4_r_pkt.size) - 1)) + ((`AXI4_ADDR_BITS'b1 << axi4_r_pkt.size)-`AXI4_ADDR_BITS'b1) - (axi4_r_pkt.addr & ~(`AXI4_ADDR_BITS'(`AXI4_DATA_BITS / 8) - 1));
      end
      else
      begin
        lower_byte_lane <= axi4_r_pkt.addr - (axi4_r_pkt.addr & ~(`AXI4_ADDR_BITS'(`AXI4_DATA_BITS / 8) - 1));
        upper_byte_lane <= axi4_r_pkt.addr - (axi4_r_pkt.addr & ~(`AXI4_ADDR_BITS'(`AXI4_DATA_BITS / 8) - 1)) + (`AXI4_ADDR_BITS'b1 << axi4_r_pkt.size) - `AXI4_ADDR_BITS'b1;
      end
    end

    if ((s_axi4_r_state == S_AXI4_R_STATE_IDLE | s_axi4_r_state == S_AXI4_R_STATE_WAIT) & s_axi4_r_state_n == S_AXI4_R_STATE_CHECK)
    begin
      axi4_r_pkt.resp <= m_axi4lite_r_fifo_data_out[0+:`AXI4_RESP_BITS];
      axi4_r_pkt.data <= m_axi4lite_r_fifo_data_out[`AXI4_RESP_BITS+:`AXI4_DATA_BITS];
    end

    if (s_axi4_r_state == S_AXI4_R_STATE_IDLE)
      s_axi4_r_burst_count_r <= 8'h00;
    else if (s_axi4_r_state == S_AXI4_R_STATE_SEND && s_axi4_r_state_n == S_AXI4_R_STATE_WAIT)
    begin
      s_axi4_r_burst_count_r <= s_axi4_r_burst_count_r + `AXI4_LEN_BITS'b1;
    end

  end

  always @(posedge clk)
  begin
    if (~rstn)
    begin
      s_axi4_r_state <= S_AXI4_R_STATE_IDLE;
      s_axi4_r_state_p <= S_AXI4_R_STATE_IDLE;
    end
    else
    begin
      s_axi4_r_state   <= s_axi4_r_state_n;
      s_axi4_r_state_p <= s_axi4_r_state;
    end
  end

  /************************* END: Slave AXI4 R Logic ***********************/


  assign m_axi4lite_r_fifo_data_out_ready = ((s_axi4_r_state == S_AXI4_R_STATE_IDLE | s_axi4_r_state == S_AXI4_R_STATE_WAIT) & s_axi4_r_state_n == S_AXI4_R_STATE_CHECK) ? 1'b1 : 1'b0;
  assign s_axi4_ar_saved_fifo_data_out_ready = ((s_axi4_r_state == S_AXI4_R_STATE_IDLE | s_axi4_r_state == S_AXI4_R_STATE_WAIT) & s_axi4_r_state_n == S_AXI4_R_STATE_CHECK) ? 1'b1 : 1'b0;

  assign s_axi4_ar_saved_fifo_data_in = {axi4_ar_pkt.size, axi4_ar_pkt.addr, axi4_ar_pkt.len, axi4_ar_pkt.id};

  assign m_axi4lite_r_ready = m_axi4lite_r_fifo_data_in_ready;
  assign m_axi4lite_r_fifo_data_in_valid = m_axi4lite_r_valid;
  assign m_axi4lite_r_fifo_data_in = {m_axi4lite_r_data, m_axi4lite_r_resp};

  assign s_axi4_r_data_mask = ~(({`AXI4_DATA_BITS{1'b1}} << (`AXI4_DATA_BITS'(upper_byte_lane) << 3)) << 8) & ({`AXI4_DATA_BITS{1'b1}} << (`AXI4_DATA_BITS'(lower_byte_lane) << 3));
  //assign s_axi4_r_data_mask_lower = {`AXI4_DATA_BITS{1'b1}} << (`AXI4_DATA_BITS'(lower_byte_lane) << 3);
  //assign s_axi4_r_data_mask_upper = ~(({`AXI4_DATA_BITS{1'b1}} << (`AXI4_DATA_BITS'(upper_byte_lane) << 3)) << 8);
  assign s_axi4_r_data = s_axi4_r_state == S_AXI4_R_STATE_SEND ? (axi4_r_pkt.data & s_axi4_r_data_mask) : `AXI4_DATA_BITS'b0;

  assign s_axi4_r_resp = s_axi4_r_state == S_AXI4_R_STATE_SEND ? axi4_r_pkt.resp : `AXI4_RESP_BITS'b0;
  assign s_axi4_r_id   = s_axi4_r_state == S_AXI4_R_STATE_SEND ? axi4_r_pkt.id : `AXI4_ID_BITS'b0;

endmodule
