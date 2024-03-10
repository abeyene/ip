//=========================================================================
// AXI4 Lite Bridge
//=========================================================================
// A Beyene
// Mar 7 2024
//
// Convert AXI4 protocol to AXI4 Lite

module axi4lite_bridge
  #( parameter axi4_id_size = 5,
     axi4_addr_size = 32,
     axi4_data_size = 64)
  (
  input                                 clk,
  input                                 rstn,
  // Slave AXI4 Write Address Interface
  input                                 s_axi4_aw_ready,
  input                                 s_axi4_aw_valid,
  input [axi4_id_size-1:0]              s_axi4_aw_id,
  input [axi4_addr_size-1:0]            s_axi4_aw_addr,
  input [1:0]                           s_axi4_aw_burst,
  input [2:0]                           s_axi4_aw_size,
  input [7:0]                           s_axi4_aw_len,
  input [3:0]                           s_axi4_aw_cache,
  input                                 s_axi4_aw_lock,
  input [2:0]                           s_axi4_aw_prot,
  input [3:0]                           s_axi4_aw_qos,
  input [3:0]                           s_axi4_aw_region,
  // Master AXI4 Write Data Interface
  output                                s_axi4_w_ready,
  input                                 s_axi4_w_valid,
  input [axi4_id_size-1:0]              s_axi4_w_id,
  input [axi4_data_size-1:0]            s_axi4_w_data,
  input [(axi4_data_size >> 3):0]       s_axi4_w_strb,
  input                                 s_axi4_w_last,
  // Master AXI4 Write Response Interface
  input                                 s_axi4_b_ready,
  output                                s_axi4_b_valid,
  output [axi4_id_size-1:0]             s_axi4_b_id,
  output [1:0]                          s_axi4_b_resp,
  // Master AXI4 Read Address Interface
  input                                 s_axi4_ar_ready,
  input                                 s_axi4_ar_valid,
  input [axi4_id_size-1:0]              s_axi4_ar_id,
  input [axi4_addr_size-1:0]            s_axi4_ar_addr,
  input [3:0]                           s_axi4_ar_cache,
  input [1:0]                           s_axi4_ar_burst,
  input [2:0]                           s_axi4_ar_size,
  input [7:0]                           s_axi4_ar_len,
  input                                 s_axi4_ar_lock,
  input [2:0]                           s_axi4_ar_prot,
  input [3:0]                           s_axi4_ar_qos,
  input [3:0]                           s_axi4_ar_region,
  // Master AXI4 Read Data Interface
  input                                 s_axi4_r_ready,
  output                                s_axi4_r_valid,
  output [axi4_id_size-1:0]             s_axi4_r_id,
  output [axi4_data_size-1:0]           s_axi4_r_data,
  output                                s_axi4_r_last,
  // Master AXI4 Lite Write Address Interface
  input                                 m_axi4lite_aw_ready,
  input                                 m_axi4lite_aw_valid,
  input [axi4_addr_size-1:0]            m_axi4lite_aw_addr,
  input [2:0]                           m_axi4lite_aw_prot,
  // Master AXI4 Lite Write Data Interface
  output                                m_axi4lite_w_ready,
  input                                 m_axi4lite_w_valid,
  input [axi4_data_size-1:0]            m_axi4lite_w_data,
  input [(axi4_data_size >> 3):0]       m_axi4lite_w_strb,
  // Master AXI4 Write Response Interface
  input                                 m_axi4lite_b_ready,
  output                                m_axi4lite_b_valid,
  output [1:0]                          m_axi4lite_b_resp,
  // Master AXI4 Read Address Interface
  input                                 m_axi4lite_ar_ready,
  input                                 m_axi4lite_ar_valid,
  input [axi4_addr_size-1:0]            m_axi4lite_ar_addr,
  input [2:0]                           m_axi4lite_ar_prot,
  // Master AXI4 Read Data Interface
  input                                 m_axi4lite_r_ready,
  output                                m_axi4lite_r_valid,
  output [axi4_data_size-1:0]           m_axi4lite_r_data,
  output [1:0]                          m_axi4lite_r_resp
  );

  typedef struct packed {
    logic      [axi4_addr_size-1:0] addr;
    logic      [axi4_id_size-1:0]   id;
    logic      [7:0] len;
    logic      [2:0] size;
    logic      [1:0] burst;
    logic            lock;
    logic      [3:0] cache;
    logic      [2:0] prot;
    logic      [3:0] qos;
    logic      [3:0] region;
  } axi4_a_pkt_t; // 67 bits

  typedef struct packed {
    logic [axi4_data_size-1:0] data;
    logic            last;
    logic      [(axi4_data_size>>3)-1:0] strb;
  } axi4_w_pkt_t; // 73 bits

  typedef struct packed {
    logic    [1:0] resp;
    logic [axi4_id_size-1:0] id;
  } axi4_b_pkt_t; // 8 bits

  typedef struct packed {
    logic      [1:0] resp;
    logic [axi4_data_size-1:0] data;
    logic            last;
    logic [axi4_id_size-1:0] id;
  } axi4_r_pkt_t; // 73 bits

  axi4_a_pkt_t axi4_aw_pkt, axi4_ar_pkt;
  axi4_w_pkt_t axi4_w_pkt; 
  axi4_r_pkt_t axi4_r_pkt;

  /************************* BEGIN: Slave AXI4 AW Logic ***********************/

  typedef enum logic [3:0] {S_AXI4_AW_STATE_IDLE, S_AXI4_AW_STATE_CHECK, S_AXI4_AW_STATE_CONVERT, S_AXI4_AW_STATE_STORE, S_AXI4_AW_STATE_WAIT} s_axi4_aw_state_t;
  s_axi4_aw_state_t s_axi4_aw_state, s_axi4_aw_state_n;

  reg [axi4_addr_size-1:0] s_axi4_aw_aligned_addr_r;
  reg [axi4_addr_size-1:0] s_axi4_aw_wrap_boundary_r;
  reg [axi4_addr_size-1:0] s_axi4_aw_other_addr_r;
  reg [7:0] s_axi4_aw_burst_count_r;
  reg [axi4_addr_size-1:0] s_axi4_aw_addr_offset_r;

/*
  always @(posedge clk)
  begin
    if (s_axi4_aw_ready & s_axi4_aw_valid)
    begin
      lower_byte_lane <= s_axi4_aw_addr - (s_axi4_aw_addr >> (axi4_data_size >> 3));
      upper_byte_lane <= s_axi4_aw_addr >> s_axi4_aw_size + 2**s_axi4_aw_size - (s_axi4_aw_addr >> (axi4_data_size >> 3));
      default : 
    end
  end 
*/

  always_comb
  begin
    case (s_axi4_aw_state)
      S_AXI4_AW_STATE_IDLE :
        begin
          s_axi4_aw_ready = 1'b1;
          s_axi4_aw_fifo_data_in_valid = 1'b0;
          if (s_axi4_aw_valid)
          begin
            s_axi4_aw_state_n = S_AXI4_AW_STATE_CHECK
          end
        end
      S_AXI4_AW_STATE_CHECK :
        begin
          s_axi4_aw_ready = 1'b0;
          s_axi4_aw_fifo_data_in_valid = 1'b0;
        case (axi4_aw_pkt.len)
          2'b00 : 
            begin
              s_axi4_aw_state_n = S_AXI4_AW_STATE_STORE
            end
          2'b01 : 
            begin
              s_axi4_aw_state_n = S_AXI4_AW_STATE_CONVERT
            end
          2'b10 : 
            begin
              s_axi4_aw_state_n = S_AXI4_AW_STATE_CONVERT
            end
          default : 
            begin
              s_axi4_aw_state_n = S_AXI4_AW_STATE_IDLE
            end
        end
      S_AXI4_AW_STATE_CONVERT :
        begin
          s_axi4_aw_ready = 1'b0;
          s_axi4_aw_fifo_data_in_valid = 1'b0;
          s_axi4_aw_state_n = S_AXI4_AW_STATE_STORE
        end
      S_AXI4_AW_STATE_STORE :
        begin
          s_axi4_aw_ready = 1'b0;
          s_axi4_aw_fifo_data_in_valid = 1'b1;
          s_axi4_aw_state_n = s_axi4_aw_fifo_data_in_ready ? (s_axi4_aw_burst_count_r == axi4_aw_pkt.len ? S_AXI4_AW_STATE_WAIT : S_AXI4_AW_STATE_CONVERT) : S_AXI4_AW_STATE_STORE;
        end
      S_AXI4_AW_STATE_WAIT :
        begin
          s_axi4_aw_ready = 1'b0;
          s_axi4_aw_fifo_data_in_valid = 1'b1;
          s_axi4_aw_state_n = s_axi4_w_done_r ? S_AXI4_AW_STATE_IDLE : S_AXI4_AW_STATE_WAIT;
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
    end
    else
    begin
      s_axi4_aw_state <= s_axi4_aw_state_n;
    end
  end

  always @(posedge clk)
  begin
    if (rstn)
    begin
      if (state == S_AXI4_AW_STATE_CHECK & state_p = S_AXI4_AW_STATE_IDLE)
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

        s_axi4_aw_aligned_addr_r <= s_axi4_aw_addr & ({axi4_addr_size{1'b1}} << s_axi4_aw_size);
        s_axi4_aw_wrap_boundary_r <= s_axi4_aw_addr & ({axi4_addr_size{1'b1}} << (s_axi4_aw_len << (1 << s_axi4_aw_size));
      end
    end
  end

  always @(posedge clk)
  begin
    if (rstn)
    begin
      if (state == S_AXI4_AW_STATE_CHECK & state_n == S_AXI4_AW_STATE_CONVERT)
      begin
        s_axi4_aw_burst_count_r <= 3'b0;
        s_axi4_aw_addr_offset_r <= 1 << axi4_aw_pkt.size;
        s_axi4_aw_other_addr_r  <= axi4_aw_pkt.addr;
      end
      if (state == S_AXI4_AW_STATE_CONVERT && state_n == S_AXI4_AW_STATE_STORE)
      begin
        if (axi4_aw_burst_count != 3'b0)
        begin
          case (axi4_aw_pkt.burst)
            2'b01 : axi4_aw_pkt.addr <= s_axi4_aw_aligned_addr_r + s_axi4_aw_addr_offset_r;
            2'b10 : 
              begin
                  if (axi4_aw_pkt.addr < s_axi4_aw_wrap_boundary_r)
                    axi4_aw_pkt.addr <= s_axi4_aw_aligned_addr_r + s_axi4_aw_addr_offset_r;
                  else if (axi4_aw_pkt.addr == s_axi4_aw_wrap_boundary_r + (s_axi4_aw_len << (1 << s_axi4_aw_size)));
                    axi4_aw_pkt.addr <= s_axi4_aw_wrap_boundary_r;
                  else
                    axi4_aw_pkt.addr <= s_axi4_aw_other_addr_r - (s_axi4_aw_len << (1 << s_axi4_aw_size)));
              end
            default : 
                    axi4_aw_pkt.addr <= {axi4_addr_size{1'b0}};
          endcase
        end
        s_axi4_aw_burst_count_r <= s_axi4_aw_burst_count + 8'b1; 
        s_axi4_aw_addr_offset_r <= s_axi4_aw_addr_offset_r + (1 << axi4_aw_pkt.size);
        s_axi4_aw_other_addr_r <= s_axi4_aw_other_addr_r + (1 << axi4_aw_pkt.size);
      end
    end
  end


  /************************* END: Slave AXI4 AW Logic ***********************/

  wire s_axi4_aw_fifo_data_in_valid, s_axi4_aw_fifo_data_in_ready; 
  wire [$bits(axi4_aw_pkt)-1:0] s_axi4_aw_fifo_data_in;

  assign s_axi4_aw_fifo_data_in = {axi4_aw_pkt.region, axi4_aw_pkt.qos, axi4_aw_pkt.prot, axi4_aw_pkt.lock, axi4_aw_pkt.cache, axi4_aw_pkt.len, axi4_aw_pkt.size,  axi4_aw_pkt.burst, axi4_aw_pkt.addr, axi4_aw_pkt.id};

  fifo s_axi4_aw_fifo (
          .clk(clk),
          .rstn(rstn),
          .data_in_ready(s_axi4_aw_fifo_data_in_ready),
          .data_in_valid(s_axi4_aw_fifo_data_in_valid),
          .data_in(s_axi4_aw_fifo_data_in),
          .data_out_ready(),
          .data_out_valid(),
          .data_out()
          );


endmodule
