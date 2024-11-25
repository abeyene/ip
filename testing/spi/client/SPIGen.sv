module SPIGen (input clk, input rstn, output sck, output logic cs, output mosi, input miso);

  typedef enum logic [3:0] {STATE_IDLE, STATE_SEND, STATE_WAIT} state_t;
  state_t state, state_n, state_p;

  wire [15:0] spi_tx_data;
  reg spi_tx_valid, final_r;

  reg [1:0] spi_clk_r;
  reg [9:0] clk_cnt;

  always @(posedge clk)
  begin
    spi_clk_r <= {spi_clk_r[0], sck};
  end

  assign spi_clk_fe = ~spi_clk_r[1] &  spi_clk_r[0];
  assign spi_clk_re =  spi_clk_r[1] & ~spi_clk_r[0];

  assign spi_tx_data = final_r ? 16'b1100000010000000 : 16'b1010100001000000;

  spi_master #(.SPI_MODE(1)) spi_ctrl (
            .i_Clk(clk),
            .i_Rst_L(rstn),
            .i_TX_Byte(spi_tx_data),
            .i_TX_DV(spi_tx_valid),
            .o_TX_Ready(spi_tx_ready),
            .o_RX_DV(),
            .o_RX_Byte(),
            .o_SPI_Clk(sck),
            .i_SPI_MISO(miso),
            .o_SPI_MOSI(mosi)
            );

  always @(posedge clk)
  begin
    if (~rstn)
      clk_cnt <= 1'b0;
    else
    begin
      if (spi_clk_re)
        clk_cnt <= (clk_cnt == 5'b10000) ? 1'b0 : clk_cnt + 1'b1;
    end
  end

  always_comb
  begin
    case (state)
      STATE_IDLE    : spi_tx_valid = 1'b0;
      STATE_SEND    : spi_tx_valid = 1'b1;
      STATE_WAIT    : spi_tx_valid = 1'b0;
      default       : spi_tx_valid = 1'b0;
    endcase
  end
  
  always_comb
  begin
    case (state)
      STATE_IDLE    : cs = 1'b1;
      STATE_SEND    : cs = 1'b1;
      STATE_WAIT    : cs = 1'b0;
      default       : cs = 1'b1;
    endcase
  end

  always_comb
  begin
    case (state)
      STATE_IDLE : state_n = ~rstn ? STATE_IDLE : (~final_r ? STATE_SEND : STATE_IDLE);
      STATE_SEND : state_n = STATE_WAIT;
      STATE_WAIT : state_n = spi_tx_ready ? (~final_r ? STATE_SEND : STATE_IDLE) : STATE_WAIT;
      default    : state_n = STATE_IDLE; 
    endcase
  end

  always @(posedge clk)
  begin
    if (~rstn)
    begin
      state   <= STATE_IDLE;
      state_p <= STATE_IDLE;
    end
    else
    begin
      state   <= state_n;
      state_p <= state;
    end
  end

  always @(posedge clk)
  begin
    if (~rstn)
      final_r <= 1'b0;
    else
    begin
      if (state == STATE_WAIT && state_n == STATE_SEND)
        final_r <= 1'b1;
    end
  end
endmodule
