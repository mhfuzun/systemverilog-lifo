`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: M. Furkan UZUN
// 
// Create Date: 27.10.2024 11:26:10
// Module Name: lifo
//////////////////////////////////////////////////////////////////////////////////

module tb_lifo();

    localparam T=10;
    localparam DATA_WIDTH=32;
    
    string succ_text = "\033[32mSUCC\033[0m";
    string error_text = "\033[31mERROR\033[0m";
    
    reg clk, reset;
    
    wire lifo_empty_w;
    wire lifo_full_w;
    
    reg push_w;
    reg [DATA_WIDTH - 1 : 0] push_data_w;
    
    reg pop_w;
    wire [DATA_WIDTH - 1 : 0] pop_data_w;
    
    lifo
    #(
        .DEPTH(32),
        .DATA_WIDTH(DATA_WIDTH),
        .OUTPUT_REGISTER(0)
    )
    DUT
    (
        .clk_i(clk),
        .reset_i(reset),
        
        .lifo_empty_o(lifo_empty_w),
        .lifo_full_o(lifo_full_w),
        
        .push_i(push_w),
        .push_data_i(push_data_w),
        
        .pop_i(pop_w),
        .pop_data_o(pop_data_w)
    );
    
    always #(T/2) clk=~clk;
    
    integer i,  j;
    initial begin
        clk=1'b0;
        reset=1'b1;
        
        push_w = 1'b0;
        pop_w = 1'b0;
        
        #(T*3);
        reset=1'b0;
        #(T+1);
        
        /*
            idle iken full/empty kontrol
        */
        assert ({lifo_full_w, lifo_empty_w} == 2'b01) $display("%s, Empty/Full.", succ_text); else begin
            $display("%s, Empty/Full error, data: %00b", error_text, {lifo_full_w, lifo_empty_w}); $stop;
        end
        #(T);
        // =========================================
        
        /*
            yazdıktan sonra, full/empty ve pop_data kontrol
        */
        push_w = 1'b1;
        push_data_w = -32'd1;
        #(T);
        push_w = 1'b0;
        assert (
                    ({lifo_full_w, lifo_empty_w} == 2'b00) &
                    (pop_data_w == -32'd1)
                ) $display("after push, Empty/Full and pop_data success."); else begin
            $display("Empty/Full error, data: %00b, %h", {lifo_full_w, lifo_empty_w}, pop_data_w); $stop;
        end
        #(T);
        // =========================================
        
        /*
            anlık pop konrol,
            okuduktan sonra, full/empty kontrol
        */
        #(T*3);
        pop_w = 1'b1;
        assert (
                    (pop_data_w == -32'd1)
                ) $display("after pop, pop_data success."); else begin
            $display("after pop, pop_data error, data: %h", pop_data_w); $stop;
        end
        #(T);
        pop_w = 1'b0;
        assert (
                    ({lifo_full_w, lifo_empty_w} == 2'b01)
                ) $display("after pop, Empty/Full success."); else begin
            $display("after pop, Empty/Full error, data: %00b", {lifo_full_w, lifo_empty_w}); $stop;
        end
        #(T);
        // =========================================
        
        /*
            döngü ile seri kontrol
        */
        for (j=1; j<3; j++) begin
            $display("Test Iteration: %d", j);
            /*
                döngü başı empty/full kontrol
            */
            assert (
                        ({lifo_full_w, lifo_empty_w} == 2'b01)
                    ) $display("iteration (%d, %d), start condition succ.", j, 0); else begin
                $display("iteration (%d, %d), start condition error, data: %00b.", j, i, {lifo_full_w, lifo_empty_w}); $stop;
            end
            for (i=0; i<16*j; i++) begin
                push_w = 1'b1;
                push_data_w = i*j*(-1);
                $display("iteration (%d, %d), push <- %h", j, i, push_data_w);
                #(T);
                if ((j==2) & (i==16*j-1)) begin
                    /*
                        full dolunca full flag kontrol
                    */
                    assert (
                                ({lifo_full_w, lifo_empty_w} == 2'b10)
                            ) else begin
                        $display("iteration (%d, %d), after push, Empty/Full error, data: %00b", j, i, {lifo_full_w, lifo_empty_w}); $stop;
                    end
                end else begin
                    /*
                        full/empty flag kontrol
                    */
                    assert (
                                ({lifo_full_w, lifo_empty_w} == 2'b00)
                            ) else begin
                        $display("iteration (%d, %d), after push, Empty/Full error, data: %00b", j, i, {lifo_full_w, lifo_empty_w}); $stop;
                    end
                end
            end
            push_w = 1'b0;
            for (i=16*j-1; i>=0; i--) begin
                pop_w = 1'b1;
                $display("iteration (%d, %d), pop -> %h", j, i, pop_data_w);
                /*
                    okuma (pop) kontrol
                */
                assert (
                            (pop_data_w == (i*j*(-1)))
                        ) else begin
                    $display("iteration (%d, %d), pop error, data: %h, c: %h", j, i, pop_data_w, (i*j*(-1))); $stop;
                end
                #(T);
                if (i==0) begin
                    /*
                        tamamen boşalınca empty flag kontrol
                    */
                    assert (
                                ({lifo_full_w, lifo_empty_w} == 2'b01)
                            ) else begin
                        $display("iteration (%d, %d), pop error, data: %00b", j, i, {lifo_full_w, lifo_empty_w}); $stop;
                    end
                end else begin
                    /*
                        full/empty flag kontrol
                    */
                    assert (
                                ({lifo_full_w, lifo_empty_w} == 2'b00)
                            ) else begin
                        $display("iteration (%d, %d), pop error, data: %00b", j, i, {lifo_full_w, lifo_empty_w}); $stop;
                    end
                end
            end
            #(T);
            pop_w = 1'b0;
            #(T);
        end
        // =========================================
        
        /*
            veri tutma kontrol
        */
        push_w = 1'b1;
        push_data_w = -32'd10;
        #(T);
        push_w = 1'b1;
        push_data_w = -32'd11;
        #(T);
        push_w = 1'b0;
        
        #(T*10);
        
        assert (
                    ({lifo_full_w, lifo_empty_w} == 2'b00) &
                    (pop_data_w == -32'd11)
                )
                $display("store control succ.");
            else begin
                $display("store control, data: %00b, %h, c: %h", {lifo_full_w, lifo_empty_w}, pop_data_w, -32'd11); $stop;
            end
        
        #(T*3);
        
        $display ("\n\n\nThe test was completely successfull.");
        
        $finish;
    end

endmodule















