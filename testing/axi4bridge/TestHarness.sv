`include "axi4.svh"
`include "sipo.vh"

module TestHarness;

  reg  clk, rstn;

  wire ready_in;
  reg valid_in;
  reg [63:0] data_in;
  reg ready_out;
  wire valid_out;
  wire [63:0] data_out;

  logic                                 axi4_aw_ready;
  logic                                 axi4_aw_valid;
  logic [`AXI4_ID_BITS-1:0]             axi4_aw_id;
  logic [`AXI4_ADDR_BITS-1:0]           axi4_aw_addr;
  logic [`AXI4_BURST_BITS-1:0]          axi4_aw_burst;
  logic [`AXI4_SIZE_BITS-1:0]           axi4_aw_size;
  logic [`AXI4_LEN_BITS-1:0]            axi4_aw_len;
  logic [`AXI4_CACHE_BITS-1:0]          axi4_aw_cache;
  logic                                 axi4_aw_lock;
  logic [`AXI4_PROT_BITS-1:0]           axi4_aw_prot;
  logic [`AXI4_QOS_BITS-1:0]            axi4_aw_qos;
  logic [`AXI4_REGION_BITS-1:0]         axi4_aw_region;
  // Master AXI4 Write Data Interface
  logic                                 axi4_w_ready;
  logic                                 axi4_w_valid;
  logic [`AXI4_DATA_BITS-1:0]           axi4_w_data;
  logic [`AXI4_STRB_BITS-1:0]           axi4_w_strb;
  logic                                 axi4_w_last;
  // Master AXI4 Write Response Interface
  logic                                 axi4_b_ready;
  logic                                 axi4_b_valid;
  logic [`AXI4_ID_BITS-1:0]             axi4_b_id;
  logic [`AXI4_RESP_BITS-1:0]           axi4_b_resp;
  // Master AXI4 Read Address Interface
  logic                                 axi4_ar_ready;
  logic                                 axi4_ar_valid;
  logic [`AXI4_ID_BITS-1:0]             axi4_ar_id;
  logic [`AXI4_ADDR_BITS-1:0]           axi4_ar_addr;
  logic [`AXI4_CACHE_BITS-1:0]          axi4_ar_cache;
  logic [`AXI4_BURST_BITS-1:0]          axi4_ar_burst;
  logic [`AXI4_SIZE_BITS-1:0]           axi4_ar_size;
  logic [`AXI4_LEN_BITS-1:0]            axi4_ar_len;
  logic                                 axi4_ar_lock;
  logic [`AXI4_PROT_BITS-1:0]           axi4_ar_prot;
  logic [`AXI4_QOS_BITS-1:0]            axi4_ar_qos;
  logic [`AXI4_REGION_BITS-1:0]         axi4_ar_region;
  // Master AXI4 Read Data Interface
  logic                                 axi4_r_ready;
  logic                                 axi4_r_valid;
  logic [`AXI4_ID_BITS-1:0]             axi4_r_id;
  logic [`AXI4_DATA_BITS-1:0]           axi4_r_data;
  logic                                 axi4_r_last;
  logic [`AXI4_RESP_BITS-1:0]           axi4_r_resp;
  // Master AXI4 Lite Write Address Interface
  logic                                 axi4lite_aw_ready;
  logic                                 axi4lite_aw_valid;
  logic [`AXI4_ADDR_BITS-1:0]           axi4lite_aw_addr;
  logic [`AXI4_PROT_BITS-1:0]           axi4lite_aw_prot;
  // Master AXI4 Lite Write Data Interface
  logic                                 axi4lite_w_ready;
  logic                                 axi4lite_w_valid;
  logic [`AXI4_DATA_BITS-1:0]           axi4lite_w_data;
  logic [`AXI4_STRB_BITS-1:0]           axi4lite_w_strb;
  // Master AXI4 Write Response Interface
  logic                                 axi4lite_b_ready;
  logic                                 axi4lite_b_valid;
  logic [`AXI4_RESP_BITS-1:0]           axi4lite_b_resp;
  // Master AXI4 Read Address Interface
  logic                                 axi4lite_ar_ready;
  logic                                 axi4lite_ar_valid;
  logic [`AXI4_ADDR_BITS-1:0]           axi4lite_ar_addr;
  logic [`AXI4_PROT_BITS-1:0]           axi4lite_ar_prot;
  // Master AXI4 Read Data Interface
  logic                                 axi4lite_r_ready;
  logic                                 axi4lite_r_valid;
  logic [`AXI4_DATA_BITS-1:0]           axi4lite_r_data;
  logic [`AXI4_RESP_BITS-1:0]           axi4lite_r_resp;

  axi4bridge x (
    .clk(clk),
    .rstn(rstn),

    .s_axi4_aw_ready(axi4_aw_ready),
    .s_axi4_aw_valid(axi4_aw_valid),
    .s_axi4_aw_id(axi4_aw_id),
    .s_axi4_aw_addr(axi4_aw_addr),
    .s_axi4_aw_burst(axi4_aw_burst),
    .s_axi4_aw_size(axi4_aw_size),
    .s_axi4_aw_len(axi4_aw_len),
    .s_axi4_aw_cache(axi4_aw_cache),
    .s_axi4_aw_prot(axi4_aw_prot),
    .s_axi4_aw_lock(axi4_aw_lock),
    .s_axi4_aw_qos(axi4_aw_qos),
    .s_axi4_aw_region(axi4_aw_region),
    .s_axi4_w_ready(axi4_w_ready),
    .s_axi4_w_valid(axi4_w_valid),
    .s_axi4_w_data(axi4_w_data),
    .s_axi4_w_strb(axi4_w_strb),
    .s_axi4_w_last(axi4_w_last),
    .s_axi4_b_ready(axi4_b_ready),
    .s_axi4_b_valid(axi4_b_valid),
    .s_axi4_b_id(axi4_b_id),
    .s_axi4_b_resp(axi4_b_resp),
    .s_axi4_ar_ready(axi4_ar_ready),
    .s_axi4_ar_valid(axi4_ar_valid),
    .s_axi4_ar_id(axi4_ar_id),
    .s_axi4_ar_addr(axi4_ar_addr),
    .s_axi4_ar_burst(axi4_ar_burst),
    .s_axi4_ar_size(axi4_ar_size),
    .s_axi4_ar_len(axi4_ar_len),
    .s_axi4_ar_cache(axi4_ar_cache),
    .s_axi4_ar_prot(axi4_ar_prot),
    .s_axi4_ar_lock(axi4_ar_lock),
    .s_axi4_ar_qos(axi4_ar_qos),
    .s_axi4_ar_region(axi4_ar_region),
    .s_axi4_r_ready(axi4_r_ready),
    .s_axi4_r_valid(axi4_r_valid),
    .s_axi4_r_resp(axi4_r_resp),
    .s_axi4_r_data(axi4_r_data),

    .m_axi4lite_aw_ready(axi4lite_aw_ready),
    .m_axi4lite_aw_valid(axi4lite_aw_valid),
    .m_axi4lite_aw_addr(axi4lite_aw_addr),
    .m_axi4lite_aw_prot(axi4lite_aw_prot),
    .m_axi4lite_w_ready(axi4lite_w_ready),
    .m_axi4lite_w_valid(axi4lite_w_valid),
    .m_axi4lite_w_data(axi4lite_w_data),
    .m_axi4lite_w_strb(axi4lite_w_strb),
    .m_axi4lite_b_ready(axi4lite_b_ready),
    .m_axi4lite_b_valid(axi4lite_b_valid),
    .m_axi4lite_b_resp(axi4lite_b_resp),
    .m_axi4lite_ar_ready(axi4lite_ar_ready),
    .m_axi4lite_ar_valid(axi4lite_ar_valid),
    .m_axi4lite_ar_addr(axi4lite_ar_addr),
    .m_axi4lite_ar_prot(axi4lite_ar_prot),
    .m_axi4lite_r_ready(axi4lite_r_ready),
    .m_axi4lite_r_valid(axi4lite_r_valid),
    .m_axi4lite_r_resp(axi4lite_r_resp),
    .m_axi4lite_r_data(axi4lite_r_data)
  );

  /*
  sipo adc_sipo
  (
    .clk(clk),
    .rstn(rstn),
    .en(en),
    .sin(sin),
    .s_axi4lite_clk(clk),
    .s_axi4lite_rstn(rstn),
    .s_axi4lite_aw_ready(axi4lite_aw_ready),
    .s_axi4lite_aw_valid(axi4lite_aw_valid),
    .s_axi4lite_aw_addr(axi4lite_aw_addr),
    .s_axi4lite_aw_prot(axi4lite_aw_prot),
    .s_axi4lite_w_ready(axi4lite_w_ready),
    .s_axi4lite_w_valid(axi4lite_w_valid),
    .s_axi4lite_w_data(axi4lite_w_data),
    .s_axi4lite_w_strb(axi4lite_w_strb),
    .s_axi4lite_b_ready(axi4lite_b_ready),
    .s_axi4lite_b_valid(axi4lite_b_valid),
    .s_axi4lite_b_resp(axi4lite_b_resp),
    .s_axi4lite_ar_ready(axi4lite_ar_ready),
    .s_axi4lite_ar_valid(axi4lite_ar_valid),
    .s_axi4lite_ar_addr(axi4lite_ar_addr),
    .s_axi4lite_ar_prot(axi4lite_ar_prot),
    .s_axi4lite_r_ready(axi4lite_r_ready),
    .s_axi4lite_r_valid(axi4lite_r_valid),
    .s_axi4lite_r_resp(axi4lite_r_resp)
  ); */

  extmem mem
  (
    .clk(clk),
    .rstn(rstn),

    .s_axi4lite_aw_ready(axi4lite_aw_ready),
    .s_axi4lite_aw_valid(axi4lite_aw_valid),
    .s_axi4lite_aw_addr(axi4lite_aw_addr),
    .s_axi4lite_aw_prot(axi4lite_aw_prot),
    .s_axi4lite_w_ready(axi4lite_w_ready),
    .s_axi4lite_w_valid(axi4lite_w_valid),
    .s_axi4lite_w_data(axi4lite_w_data),
    .s_axi4lite_w_strb(axi4lite_w_strb),
    .s_axi4lite_b_ready(axi4lite_b_ready),
    .s_axi4lite_b_valid(axi4lite_b_valid),
    .s_axi4lite_b_resp(axi4lite_b_resp),
    .s_axi4lite_ar_ready(axi4lite_ar_ready),
    .s_axi4lite_ar_valid(axi4lite_ar_valid),
    .s_axi4lite_ar_addr(axi4lite_ar_addr),
    .s_axi4lite_ar_prot(axi4lite_ar_prot),
    .s_axi4lite_r_ready(axi4lite_r_ready),
    .s_axi4lite_r_valid(axi4lite_r_valid),
    .s_axi4lite_r_resp(axi4lite_r_resp)
  );

  typedef enum logic [1:0] {IDLE, REQUEST_STATE, RESPONSE_STATE} state_t;
  state_t state, state_n, state_p;
  logic test_done, go;
  logic [63:0]	trace_count;
  logic [255:0] desc;

  integer i;

  reg exit, fail;
  reg [1023:0] 	vcdplusfile = 0;
  reg [1023:0] 	vcdfile = 0;
  reg          	stats_active = 0;
  reg          	stats_tracking = 0;
  reg          	verbose = 0;
  reg [31:0]   	max_cycles = 0;
  integer      	stderr = 32'h80000002;
 
  integer f;

  always @(posedge clk or negedge clk)
    $fwrite(f, "%b\n", clk);

  initial
  begin
    f = $fopen ("vectors.sim", "w");
    clk	  = 1'b0;
    rstn  = 1'b0;
    exit  = 1'b0;
    fail  = 1'b0;
    go 	  = 1'b0;
    trace_count = 0;
    #200;
    $display("\n");
    $display("===============================================================================");
    $display("\n");
    $display("Fifo Project Test Suite");
    $display("Description: Fill in fifo and read out contents.");
    $display("\n");
    $display("===============================================================================");
    if (!verbose)
        $display("\n");

    // Unit Tests
    //
    // run_test(src_addr, dst_addr)
    //
    // Argument             Type            Values
    // --------------------------------------------------------------
    // src_addr             logic [39:0]    40-bit address of scores
    // dst_addr             logic [39:0]    40-bit address of logic
     

    run_test(0, 0);

`ifdef DEBUG
  $vcdplusclose;
`endif
  end

  initial
  begin
    $value$plusargs("max-cycles=%d", max_cycles);
    verbose = $test$plusargs("verbose");
`ifdef DEBUG
  if ($value$plusargs("vcdplusfile=%s", vcdplusfile))
  begin
    $vcdplusfile(vcdplusfile);
    $vcdpluson(0);
    $vcdplusmemon(0);
  end
`endif
  end

  always	
  begin
      #1 clk = 1'b1; #1 clk = 1'b0;
  end

  always @(posedge clk)
  begin
      trace_count = trace_count + 1;
  end

  always @(posedge clk)
  begin
    if (max_cycles > 0 && trace_count > max_cycles && exit == 0)
    begin
      $fdisplay(stderr, "\n** TIMEOUT **\n");
      fail = 1;
      exit = 1;
    end
  end

  always @(posedge clk)
  begin
    if (exit == 1)
    begin
      if (fail == 1)
        $display("[ failed ]");
      else
        $display("[ passed ]");
      $display("");
      $fclose(f);
      $finish();
    end
  end

  task send_axi4_write
  (
  // Slave AXI4 Write Address Interface
  input                                 axi4_aw_valid_t,
  input [`AXI4_ID_BITS-1:0]             axi4_aw_id_t,
  input [`AXI4_ADDR_BITS-1:0]           axi4_aw_addr_t,
  input [`AXI4_BURST_BITS-1:0]          axi4_aw_burst_t,
  input [`AXI4_SIZE_BITS-1:0]           axi4_aw_size_t,
  input [`AXI4_LEN_BITS-1:0]            axi4_aw_len_t,
  input [`AXI4_CACHE_BITS-1:0]          axi4_aw_cache_t,
  input                                 axi4_aw_lock_t,
  input [`AXI4_PROT_BITS-1:0]           axi4_aw_prot_t,
  input [`AXI4_QOS_BITS-1:0]            axi4_aw_qos_t,
  input [`AXI4_REGION_BITS-1:0]         axi4_aw_region_t,
  // Master AXI4 Write Data Interface
  input                                 axi4_w_valid_t,
  input [`AXI4_DATA_BITS-1:0]           axi4_w_data_t,
  input [`AXI4_STRB_BITS-1:0]           axi4_w_strb_t,
  input                                 axi4_w_last_t,
  // Master AXI4 Write Response Interface
  input                                 axi4_b_ready_t
  );
  begin

    axi4_aw_valid  = axi4_aw_valid_t;
    axi4_aw_id     = axi4_aw_id_t;
    axi4_aw_addr   = axi4_aw_addr_t;
    axi4_aw_burst  = axi4_aw_burst_t; 
    axi4_aw_size   = axi4_aw_size_t; 
    axi4_aw_len    = axi4_aw_len_t;
    axi4_aw_cache  = axi4_aw_cache_t;
    axi4_aw_lock   = axi4_aw_lock_t;
    axi4_aw_prot   = axi4_aw_prot_t;
    axi4_aw_qos    = axi4_aw_qos_t;
    axi4_aw_region = axi4_aw_region_t;

    axi4_w_valid  = axi4_w_valid_t;
    axi4_w_data   = axi4_w_data_t;
    axi4_w_strb   = axi4_w_strb_t;
    axi4_w_last   = axi4_w_last_t;

    axi4_b_ready   = axi4_b_ready_t;
  end
  endtask

  task send_axi4_read
  (
  // Master AXI4 Read Address Interface
  input                                 axi4_ar_valid_t,
  input [`AXI4_ID_BITS-1:0]             axi4_ar_id_t,
  input [`AXI4_ADDR_BITS-1:0]           axi4_ar_addr_t,
  input [`AXI4_BURST_BITS-1:0]          axi4_ar_burst_t,
  input [`AXI4_SIZE_BITS-1:0]           axi4_ar_size_t,
  input [`AXI4_LEN_BITS-1:0]            axi4_ar_len_t,
  input [`AXI4_CACHE_BITS-1:0]          axi4_ar_cache_t,
  input                                 axi4_ar_lock_t,
  input [`AXI4_PROT_BITS-1:0]           axi4_ar_prot_t,
  input [`AXI4_QOS_BITS-1:0]            axi4_ar_qos_t,
  input [`AXI4_REGION_BITS-1:0]         axi4_ar_region_t,
  // Master AXI4 Read Data Interface
  input                                 axi4_r_ready_t
  );
  begin

    axi4_ar_valid  = axi4_ar_valid_t;
    axi4_ar_id     = axi4_ar_id_t;
    axi4_ar_addr   = axi4_ar_addr_t;
    axi4_ar_burst  = axi4_ar_burst_t; 
    axi4_ar_size   = axi4_ar_size_t; 
    axi4_ar_len    = axi4_ar_len_t;
    axi4_ar_cache  = axi4_ar_cache_t;
    axi4_ar_lock   = axi4_ar_lock_t;
    axi4_ar_prot   = axi4_ar_prot_t;
    axi4_ar_qos    = axi4_ar_qos_t;
    axi4_ar_region = axi4_ar_region_t;

  end
  endtask

  task run_test
  (
    input logic [39:0]  arg1,
    input logic [39:0] 	arg2
  );
  begin
    //$readmemb("configurations.bin", configurations);
    if (verbose)
        $display("\nTest Parameters: N/A\n");

    //#2 src_addr = arg1; dst_addr = arg2;

    #2 rstn = 1'b1;
    #2 go = 1'b1;
    #2 test_done = 1'b0;
    $display("Start ...");

    #10000;
    wait (axi4_r_valid);
    wait (axi4_r_valid);
    #4 $display("Finished.");

    fail = 1'b1;
    exit = 1'b1;
  end
  endtask

  always_comb
  begin
    case (state)
      IDLE :
        begin 
          //              AW_VALID,    AW_ID,       AW_ADDR, AW_BURST, AW_SIZE, AW_LEN, AW_CACHE, AW_LOCK, AW_PROT,  AW_QOS, AW_REGION, W_VALID,                  W_DATA,  W_STRB, W_LAST, B_READY
          send_axi4_write(    1'b0, 5'b00100, 32'h8000_0000,    2'b00,  3'b110,  8'h00,     4'h0,    1'b0,  3'b000, 4'b0000,   4'b0000,    1'b0, 64'h0000_0000_0000_0000, 8'h0000,    1'b0,   1'b0);
          //              AR_VALID,    AR_ID,       AR_ADDR, AR_BURST, AR_SIZE, AR_LEN, AR_CACHE, AR_LOCK, AR_PROT,  AR_QOS, AR_REGION, R_READY
          send_axi4_read(     1'b0, 5'b00100, 32'h8000_0000,    2'b00,  3'b110,  8'h00,     4'h0,    1'b0,  3'b000, 4'b0000,   4'b0000,    1'b0);
          if (go & ~test_done)
            state_n = REQUEST_STATE;
          else
            state_n = IDLE;
        end
      REQUEST_STATE : 
        begin
          //              AW_VALID,    AW_ID,       AW_ADDR, AW_BURST, AW_SIZE, AW_LEN, AW_CACHE, AW_LOCK, AW_PROT,  AW_QOS, AW_REGION, W_VALID,                  W_DATA,  W_STRB, W_LAST, B_READY
          send_axi4_write(    1'b0, 5'b00100, 32'h8000_0000,    2'b00,  3'b110,  8'h00,     4'h0,    1'b0,  3'b000, 4'b0000,   4'b0000,    1'b0, 64'h0000_0000_0000_0000, 8'h0000,    1'b0,   1'b0);
          //              AR_VALID,    AR_ID,       AR_ADDR, AR_BURST, AR_SIZE, AR_LEN, AR_CACHE, AR_LOCK, AR_PROT,  AR_QOS, AR_REGION, R_READY
          send_axi4_read(     1'b1, 5'b00100, 32'h8000_0000,    2'b01,  3'b110,  8'h01,     4'h0,    1'b0,  3'b000, 4'b0000,   4'b0000,    1'b0);
          state_n   = axi4_ar_ready ? RESPONSE_STATE : REQUEST_STATE;
        end	
      RESPONSE_STATE : 
        begin
          send_axi4_write(    1'b0, 5'b00100, 32'h8000_0000,    2'b00,  3'b110,  8'h00,     4'h0,    1'b0,  3'b000, 4'b0000,   4'b0000,    1'b0, 64'h0000_0000_0000_0000, 8'h0000,    1'b0,   1'b0);
          send_axi4_read(     1'b0, 5'b00100, 32'h8000_0000,    2'b00,  3'b110,  8'h00,     4'h0,    1'b0,  3'b000, 4'b0000,   4'b0000,    1'b1);
          state_n   = axi4lite_r_valid ? IDLE : RESPONSE_STATE;
        end	
      default :
        begin
          state_n 	= IDLE;
        end
    endcase
  end

  always @(posedge clk)
  begin
    if (~rstn)
    begin
      state   <= IDLE;
      state_p <= IDLE;
    end
    else
    begin
      state   <= state_n;
      state_p <= state;
    end
  end
endmodule


