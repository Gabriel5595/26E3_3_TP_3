module nucleo_aritmetico #(
    parameter LARGURA_INTEIRO = 8,
    parameter BITS_INTEIROS_PF = 3,
    parameter BITS_FRACIONARIOS_PF = 5,
    parameter LARGURA_EXPOENTE_FLUT = 4,
    parameter LARGURA_MANTISSA_FLUT = 11
)(
    input wire [1:0] formato_numerico,
    input wire com_sinal,
    input wire [1:0] operacao,
    input wire [LARGURA_INTEIRO-1:0] operando_a_inteiro,
    input wire [LARGURA_INTEIRO-1:0] operando_b_inteiro,
    input wire signed [BITS_INTEIROS_PF+BITS_FRACIONARIOS_PF-1:0] operando_a_ponto_fixo,
    input wire signed [BITS_INTEIROS_PF+BITS_FRACIONARIOS_PF-1:0] operando_b_ponto_fixo,
    input wire sinal_a_flutuante,
    input wire [LARGURA_EXPOENTE_FLUT-1:0] expoente_a_flutuante,
    input wire [LARGURA_MANTISSA_FLUT-1:0] mantissa_a_flutuante,
    input wire sinal_b_flutuante,
    input wire [LARGURA_EXPOENTE_FLUT-1:0] expoente_b_flutuante,
    input wire [LARGURA_MANTISSA_FLUT-1:0] mantissa_b_flutuante,
    output reg [2*LARGURA_INTEIRO-1:0] resultado_inteiro,
    output reg signed [BITS_INTEIROS_PF+BITS_FRACIONARIOS_PF-1:0] resultado_ponto_fixo,
    output reg sinal_resultado_flutuante,
    output reg [LARGURA_EXPOENTE_FLUT-1:0] expoente_resultado_flutuante,
    output reg [LARGURA_MANTISSA_FLUT-1:0] mantissa_resultado_flutuante,
    output reg estouro
);

localparam FORMATO_INTEIRO = 2'b00;
localparam FORMATO_PONTO_FIXO = 2'b01;
localparam FORMATO_PONTO_FLUTUANTE = 2'b10;

wire [2*LARGURA_INTEIRO-1:0] resultado_inteiro_interno;
wire estouro_inteiro_interno;

unidade_aritmetica_inteira #(.LARGURA(LARGURA_INTEIRO)) u_inteiro (
    .com_sinal(com_sinal),
    .operacao(operacao),
    .operando_a(operando_a_inteiro),
    .operando_b(operando_b_inteiro),
    .resultado(resultado_inteiro_interno),
    .estouro(estouro_inteiro_interno)
);

wire signed [BITS_INTEIROS_PF+BITS_FRACIONARIOS_PF-1:0] resultado_ponto_fixo_interno;
wire estouro_ponto_fixo_interno;

aritmetica_ponto_fixo #(.BITS_INTEIROS(BITS_INTEIROS_PF), .BITS_FRACIONARIOS(BITS_FRACIONARIOS_PF)) u_ponto_fixo (
    .operacao(operacao),
    .operando_a(operando_a_ponto_fixo),
    .operando_b(operando_b_ponto_fixo),
    .resultado(resultado_ponto_fixo_interno),
    .saturou(estouro_ponto_fixo_interno)
);

wire sinal_resultado_flutuante_interno;
wire [LARGURA_EXPOENTE_FLUT-1:0] expoente_resultado_flutuante_interno;
wire [LARGURA_MANTISSA_FLUT-1:0] mantissa_resultado_flutuante_interno;

soma_ponto_flutuante #(.LARGURA_EXPOENTE(LARGURA_EXPOENTE_FLUT), .LARGURA_MANTISSA(LARGURA_MANTISSA_FLUT)) u_ponto_flutuante (
    .modo_subtracao(operacao[0]),
    .sinal_a(sinal_a_flutuante),
    .expoente_a(expoente_a_flutuante),
    .mantissa_a(mantissa_a_flutuante),
    .sinal_b(sinal_b_flutuante),
    .expoente_b(expoente_b_flutuante),
    .mantissa_b(mantissa_b_flutuante),
    .sinal_resultado(sinal_resultado_flutuante_interno),
    .expoente_resultado(expoente_resultado_flutuante_interno),
    .mantissa_resultado(mantissa_resultado_flutuante_interno)
);

always @(*) begin
    resultado_inteiro = {(2*LARGURA_INTEIRO){1'b0}};
    resultado_ponto_fixo = {(BITS_INTEIROS_PF+BITS_FRACIONARIOS_PF){1'b0}};
    sinal_resultado_flutuante = 1'b0;
    expoente_resultado_flutuante = {LARGURA_EXPOENTE_FLUT{1'b0}};
    mantissa_resultado_flutuante = {LARGURA_MANTISSA_FLUT{1'b0}};
    estouro = 1'b0;
    case (formato_numerico)
        FORMATO_INTEIRO: begin
            resultado_inteiro = resultado_inteiro_interno;
            estouro = estouro_inteiro_interno;
        end
        FORMATO_PONTO_FIXO: begin
            resultado_ponto_fixo = resultado_ponto_fixo_interno;
            estouro = estouro_ponto_fixo_interno;
        end
        FORMATO_PONTO_FLUTUANTE: begin
            sinal_resultado_flutuante = sinal_resultado_flutuante_interno;
            expoente_resultado_flutuante = expoente_resultado_flutuante_interno;
            mantissa_resultado_flutuante = mantissa_resultado_flutuante_interno;
            estouro = 1'b0;
        end
        default: begin
        end
    endcase
end

endmodule