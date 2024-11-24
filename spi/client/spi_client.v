module spi_client (
   // The well-known four SPI interface signals
   input  wire  spi_clk,   // This must be an FPGA/CPLD clock pin!
   input  wire  spi_cs_n,  // This must be an FPGA/CPLD clock pin!
   input  wire  spi_mosi,   
   output wire  spi_miso,   
   
   // Example I/O ports 
   output reg   [7:0] out1,     // 8-bit writable register 1
   output reg   [7:0] out2,     // 8-bit writable register 2
   input  wire  [15:0] status1, // First  16-bit readable values
   input  wire  [15:0] status2  // Second 16-bit readable values
   );

  // The 10 SPI core registers 
  reg  [15:0] shift;
  reg        load;
  reg        bit_in;   

  // Two read adress bits allows reading of up to 
  // four 8-bit values
  reg  [7:0] read;

  wire [15:0] serial_in;

   // MOSI bit is stored on falling SPI clock edge 
   always @(negedge spi_clk)
   begin
      if (!spi_cs_n)
         bit_in <= spi_mosi;
   end
   
   // Combines MOSI bit with shift register bits
   // This producing 8 bits which are then used 
   // at the next rising clock edge
   assign serial_in = { bit_in,shift[15:1]};

   // The serial shift register 
   // This also produces the MISO data bit
   // The SPI cs is used as asynchronous active high reset 
   always @(posedge spi_clk or posedge spi_cs_n)
   begin
      if (spi_cs_n)
         load <= 1'b1;
      else
      begin
         load <= 1'b0;
         // First rising clock edge load the shift register
         // with the read data 
         if (load)
         begin
            case (read)
            8'h00 : shift <= status1;
            8'h01 : shift <= status2;
            endcase
         end
         else
         begin // The other cycles shift the data in
            shift <= serial_in;      
         end
      end
   end
 
  // The chip select rising edge is used to transfer 
  // the shift register data (the data just arrived)
  // to local registers.
  // The MS two bits are used to select which register the data should
  // go into, leaving 6 data bits to store.
  // BEWARE that this makes the spi_cs_n a clock signal!
   always @(posedge spi_cs_n) 
   begin
      case (serial_in[15:8])
      8'h0 : read <= serial_in[1:0]; 
      8'h1 : out1 <= serial_in[7:0];
      8'h2 : out2 <= serial_in[7:0];
      // Unused entry 
      endcase
   end
      
   // The MISO port is tri-stated when not selected
   // Otherwise it outputs the shift data
   assign spi_miso =  spi_cs_n ? 1'bz : shift[0];
   
endmodule 
