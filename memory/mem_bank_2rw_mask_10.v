module mem_bank_2rw_mask_10
(
    // Port 1 Interface
    input                 RW0_clk,         // Clock signal
    input                 RW0_en,          // Clock signal
    input                 RW0_wmode,       // Write enable for Port 1
    input  [4:0]          RW0_addr,        // Address for Port 1
    input  [9:0]          RW0_wdata,       // Write data for Port 1
    input  [9:0]          RW0_wmask,
    output [9:0]          RW0_rdata,       // Read data from Port 1

    // Port 2 Interface
    input                 RW1_clk,         // Clock signal
    input                 RW1_en,          // Clock signal
    input                 RW1_wmode,       // Write enable for Port 2
    input  [4:0]          RW1_addr,        // Address for Port 2
    input  [9:0]          RW1_wdata,       // Write data for Port 2
    input  [9:0]          RW1_wmask,
    output [9:0]          RW1_rdata        // Read data from Port 2
);

  // Register memory array
  logic [9:0] reg_file [0:31];

  // Synchronous Read and Write Logic
  always_ff @(posedge RW0_clk || RW1_clk)
  begin
    // Handle writes first (write priority)
    if (RW0_wmode)
    begin
      for (int i = 0; i < 10; i = i + 1)
      begin
        if (RW0_wmask[i])
          reg_file[RW0_addr][i] <= RW0_wdata[i];
      end
    end

    if (RW1_wmode && (RW1_addr != RW0_addr))
    begin
      for (int i = 0; i < 10; i = i + 1)
      begin
        if (RW1_wmask[i])
          reg_file[RW1_addr] <= RW1_wdata;
      end
    end
  end

  assign RW0_rdata = reg_file[RW0_addr];  
  assign RW1_rdata = reg_file[RW1_addr];  

endmodule
