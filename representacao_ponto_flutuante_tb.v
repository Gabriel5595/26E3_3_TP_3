`timescale 1ns/1ps

module representacao_ponto_flutuante_tb;

localparam LARGURA_EXPOENTE = 4;
localparam LARGURA_MANTISSA = 11;

reg empacotar;
reg sinal_entrada;
reg [LARGURA_EXPOENTE-1:0] expoente_entrada;
reg [LARGURA_MANTISSA-1:0] mantissa_entrada;
reg [LARGURA_EXPOENTE+LARGURA_MANTISSA:0] palavra_entrada;
wire [LARGURA_EXPOENTE+LARGURA_MANTISSA:0] palavra_saida;
wire sinal_saida;
wire [LARGURA_EXPOENTE-1:0] expoente_saida;
wire [LARGURA_MANTISSA-1:0] mantissa_saida;

representacao_ponto_flutuante #(.LARGURA_EXPOENTE(LARGURA_EXPOENTE), .LARGURA_MANTISSA(LARGURA_MANTISSA)) u_representacao (
    .empacotar(empacotar),
    .sinal_entrada(sinal_entrada),
    .expoente_entrada(expoente_entrada),
    .mantissa_entrada(mantissa_entrada),
    .palavra_entrada(palavra_entrada),
    .palavra_saida(palavra_saida),
    .sinal_saida(sinal_saida),
    .expoente_saida(expoente_saida),
    .mantissa_saida(mantissa_saida)
);

initial begin
    $display("=== Iniciando testes da representacao_ponto_flutuante ===");

    empacotar = 1'b1;
    sinal_entrada = 1'b0; expoente_entrada = 4'd4; mantissa_entrada = 11'd14;
    #10;
    $display("EMPACOTAR: sinal=%0d expoente=%0d mantissa=%0d -> palavra=%016b (0x%04h)",
                sinal_entrada, expoente_entrada, mantissa_entrada, palavra_saida, palavra_saida);

    empacotar = 1'b1;
    sinal_entrada = 1'b1; expoente_entrada = 4'd6; mantissa_entrada = 11'd39;
    #10;
    $display("EMPACOTAR: sinal=%0d expoente=%0d mantissa=%0d -> palavra=%016b (0x%04h)",
                sinal_entrada, expoente_entrada, mantissa_entrada, palavra_saida, palavra_saida);

    empacotar = 1'b0;
    palavra_entrada = 16'b1_0110_00000100111;
    #10;
    $display("DESEMPACOTAR: palavra=%016b -> sinal=%0d expoente=%0d mantissa=%0d",
                palavra_entrada, sinal_saida, expoente_saida, mantissa_saida);

    empacotar = 1'b0;
    palavra_entrada = 16'b0_0100_00000001110;
    #10;
    $display("DESEMPACOTAR: palavra=%016b -> sinal=%0d expoente=%0d mantissa=%0d",
                palavra_entrada, sinal_saida, expoente_saida, mantissa_saida);

    $display("=== Testes concluidos ===");
    $finish;
end

endmodule