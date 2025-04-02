module mem_bank_1rw #(
    parameter int REG_DEPTH = 4,  // Number of registers
    parameter int REG_WIDTH = 64  // Width of each register
)(
    input  logic                  clk,             // Clock signal
    input  logic                  reset,           // Reset signal (active-high)
    
    // Port 1 Interface
    input  logic                         RW0_wen,        // Write enable for Port 1
    input  logic [$clog2(REG_DEPTH)-1:0] RW0_addr,       // Address for Port 1
    input  logic [REG_WIDTH-1:0]         RW0_wmask,
    input  logic [REG_WIDTH-1:0]         RW0_wdata,      // Write data for Port 1
    output logic [REG_WIDTH-1:0]         RW0_rdata       // Read data from Port 1
);

  // Register memory array
  logic [REG_WIDTH-1:0] reg_file [0:REG_DEPTH-1];

  // Synchronous Read and Write Logic
  always_ff @(posedge clk) 
  begin
    if (reset) 
    begin
      // Reset all registers to 0
      for (int i = 0; i < REG_DEPTH; i++) 
      begin
          reg_file[i] <= '0;
      end
      //RW0_rdata <= '0;
    end 
    else 
    begin
    // Handle writes first (write priority)
      if (RW0_wen) 
      begin
        for (int i = 0; i < REG_WIDTH; i = i + 1)
        begin
          if (RW0_wmask[i])
            reg_file[RW0_addr][i] <= RW0_wdata[i];
        end
      end
      // Synchronous Reads
      //RW0_rdata <= reg_file[RW0_addr];  
    end
  end
  assign RW0_rdata = reg_file[RW0_addr];

endmodule
