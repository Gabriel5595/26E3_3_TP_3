`timescale 1ns/1ps

module unidade_aritmetica_inteira_tb;

reg com_sinal;
reg [1:0] operacao;
reg [7:0] operando_a;
reg [7:0] operando_b;
wire [15:0] resultado;
wire estouro;

unidade_aritmetica_inteira #(.LARGURA(8)) u_unidade (
    .com_sinal(com_sinal),
    .operacao(operacao),
    .operando_a(operando_a),
    .operando_b(operando_b),
    .resultado(resultado),
    .estouro(estouro)
);

task executar_caso;
    input [799:0] nome_caso;
    begin
        #10;
        if (com_sinal)
            $display("CASO: %0s | com_sinal=%0d operacao=%0d a=%0d b=%0d -> resultado=%0d estouro=%0d",
                        nome_caso, com_sinal, operacao, $signed(operando_a), $signed(operando_b), $signed(resultado), estouro);
        else
            $display("CASO: %0s | com_sinal=%0d operacao=%0d a=%0d b=%0d -> resultado=%0d estouro=%0d",
                        nome_caso, com_sinal, operacao, operando_a, operando_b, resultado, estouro);
    end
endtask

initial begin
    $display("=== Iniciando testes da unidade_aritmetica_inteira ===");

    com_sinal = 1'b0; operacao = 2'b00; operando_a = 8'd15; operando_b = 8'd10;
    executar_caso("soma sem sinal tipica (15+10)");

    com_sinal = 1'b0; operacao = 2'b00; operando_a = 8'd250; operando_b = 8'd10;
    executar_caso("soma sem sinal com estouro (250+10)");

    com_sinal = 1'b1; operacao = 2'b00; operando_a = 8'd100; operando_b = 8'd100;
    executar_caso("soma com sinal com estouro (100+100)");

    com_sinal = 1'b1; operacao = 2'b01; operando_a = -8'sd128; operando_b = 8'd1;
    executar_caso("subtracao com sinal com estouro (-128-1)");

    com_sinal = 1'b1; operacao = 2'b01; operando_a = 8'd9; operando_b = 8'd4;
    executar_caso("subtracao com sinal tipica (9-4)");

    com_sinal = 1'b1; operacao = 2'b10; operando_a = -8'sd12; operando_b = 8'd10;
    executar_caso("multiplicacao com sinal tipica (-12*10)");

    com_sinal = 1'b0; operacao = 2'b10; operando_a = 8'd200; operando_b = 8'd200;
    executar_caso("multiplicacao sem sinal, resultado largo (200*200)");

    com_sinal = 1'b1; operacao = 2'b11; operando_a = -8'sd20; operando_b = 8'd3;
    executar_caso("divisao com sinal tipica (-20/3)");

    com_sinal = 1'b0; operacao = 2'b11; operando_a = 8'd50; operando_b = 8'd0;
    executar_caso("divisao por zero (50/0)");

    $display("=== Testes concluidos ===");
    $finish;
end

endmodule