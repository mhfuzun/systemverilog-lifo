`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: M. Furkan UZUN
// 
// Create Date: 27.10.2024 10:50:42
// Module Name: lifo
//////////////////////////////////////////////////////////////////////////////////


module lifo
    #(parameter
        DEPTH = 32,
        DATA_WIDTH = 32,
        OUTPUT_REGISTER=0   // 0: in the same cycle, 1: next cycle
    )
    (
        input clk_i,
        input reset_i,
        
        output lifo_empty_o,
        output lifo_full_o,
        
        input push_i,
        input [DATA_WIDTH - 1 : 0] push_data_i,
        
        input pop_i,
        output reg [DATA_WIDTH - 1 : 0] pop_data_o
    );
    
    localparam MEMORY_ADDR_WIDTH = $clog2(DEPTH) + 1;
    
    reg [DATA_WIDTH - 1 : 0] store_memory [0 : DEPTH - 1];
    
    reg [MEMORY_ADDR_WIDTH - 1 : 0] pointer_r;
    reg non_empty_r; 
    
    wire push_w, pop_w, empty_w, full_w;
    
    assign empty_w          = (pointer_r ==     0);
    assign full_w           = (pointer_r == DEPTH);
    assign push_w           = (~full_w & push_i);
    assign pop_w            = (~empty_w & pop_i);
    
    assign lifo_empty_o     = empty_w;
    assign lifo_full_o      = full_w;
    
    always @(posedge clk_i, posedge reset_i) begin
        if (reset_i) begin
            pointer_r <= 0;
            non_empty_r <= 0;
        end else begin
            case ({push_w, pop_w})
                2'b00: pointer_r <=  pointer_r;
                2'b01: pointer_r <= (pointer_r - 1);
                2'b10: pointer_r <= (pointer_r + 1);
                2'b11: pointer_r <=  pointer_r;
            endcase
            
            non_empty_r <= (non_empty_r & ~(pop_w & (pointer_r == 1))) | push_w;
        end
    end
    
    always @(posedge clk_i) begin
        if (push_w) begin
            store_memory[pointer_r] <= push_data_i;
        end
        
        if (OUTPUT_REGISTER == 1) begin
            pop_data_o <= store_memory[pointer_r-1];
        end
    end
    
    always @(*) begin
        if (OUTPUT_REGISTER == 0) begin
            pop_data_o = store_memory[pointer_r-1];
        end
    end
    
endmodule




















