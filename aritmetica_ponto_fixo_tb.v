`timescale 1ns/1ps

module aritmetica_ponto_fixo_tb;

localparam BITS_INTEIROS = 3;
localparam BITS_FRACIONARIOS = 5;

reg [1:0] operacao;
reg signed [7:0] operando_a;
reg signed [7:0] operando_b;
wire signed [7:0] resultado;
wire saturou;

aritmetica_ponto_fixo #(.BITS_INTEIROS(BITS_INTEIROS), .BITS_FRACIONARIOS(BITS_FRACIONARIOS)) u_ponto_fixo (
    .operacao(operacao),
    .operando_a(operando_a),
    .operando_b(operando_b),
    .resultado(resultado),
    .saturou(saturou)
);

real valor_a_real, valor_b_real, valor_resultado_real;

task executar_caso;
    input [799:0] nome_caso;
    begin
        #10;
        valor_a_real = operando_a / 32.0;
        valor_b_real = operando_b / 32.0;
        valor_resultado_real = resultado / 32.0;
        $display("CASO: %0s | a=%0d/32=%0.5f b=%0d/32=%0.5f operacao=%0d -> resultado=%0d/32=%0.5f saturou=%0d",
                    nome_caso, operando_a, valor_a_real, operando_b, valor_b_real, operacao,
                    resultado, valor_resultado_real, saturou);
    end
endtask

initial begin
    $display("=== Iniciando testes da aritmetica_ponto_fixo (formato Q3.5) ===");

    operacao = 2'b00; operando_a = 8'sd48; operando_b = 8'sd32;
    executar_caso("soma tipica (1.5 + 1.0)");

    operacao = 2'b00; operando_a = 8'sd112; operando_b = 8'sd32;
    executar_caso("soma com estouro/saturacao (3.5 + 1.0)");

    operacao = 2'b01; operando_a = 8'sd64; operando_b = 8'sd112;
    executar_caso("subtracao tipica (2.0 - 3.5)");

    operacao = 2'b01; operando_a = -8'sd96; operando_b = 8'sd64;
    executar_caso("subtracao com estouro/saturacao (-3.0 - 2.0)");

    operacao = 2'b10; operando_a = 8'sd48; operando_b = 8'sd64;
    executar_caso("multiplicacao tipica (1.5 * 2.0)");

    operacao = 2'b10; operando_a = 8'sd33; operando_b = 8'sd33;
    executar_caso("multiplicacao com erro de quantizacao/truncamento (1.03125 * 1.03125)");

    operacao = 2'b10; operando_a = 8'sd112; operando_b = 8'sd112;
    executar_caso("multiplicacao com estouro/saturacao (3.5 * 3.5)");

    $display("=== Testes concluidos ===");
    $finish;
end

endmodule