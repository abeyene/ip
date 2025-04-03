module mem_bank_2rw
(

    // Port 1 Interface
    input                           RW0_clk,      // Clock signal
    input                           RW0_en,       // Enable signal
    input                           RW0_wmode,    // Write enable for Port 1
    input  [1:0]                    RW0_addr,     // Address for Port 1
    input  [63:0]                   RW0_wdata,    // Write data for Port 1
    output [63:0]                   RW0_rdata,    // Read data from Port 1

    // Port 2 Interface
    input                           RW1_clk,      // Clock signal
    input                           RW1_en,       // Enable signal
    input                           RW1_wmode,    // Write enable for Port 2
    input   [1:0]                   RW1_addr,     // Address for Port 2
    input   [63:0]                  RW1_wdata,    // Write data for Port 2
    output  [63:0]                  RW1_rdata     // Read data from Port 2
);

  // Register memory array
  logic [63:0] reg_file [0:3];

  // Synchronous Write Logic
  always_ff @(posedge RW0_clk || RW1_clk)
  begin
    // Handle writes first (write priority)
    if (RW0_wmode)
        reg_file[RW0_addr] <= RW0_wdata;
    if (RW1_wmode && (RW1_addr != RW0_addr))
        reg_file[RW1_addr] <= RW1_wdata;
  end

  // Asynchronous read Logic
  assign RW0_rdata = reg_file[RW0_addr];

  // Asynchronous read Logic
  assign RW1_rdata = reg_file[RW1_addr];

endmodule
