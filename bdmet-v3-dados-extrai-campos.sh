#!/bin/bash

# Função EXTRAIR colunas de dados de interesse
#  Dados alterados são copiados para ./v3/


# Comando:
# ./bdmet-v3-dados-extrai-campos.sh   DIRETORIO
# Parâmetro: diretório onde estão os arquivos
#   de dados de entrada


# Checa se o diretório foi passado como parâmetro
if [ -z $1 ]; then
    echo "Erro. Faltou parâmetro de diretório."
    echo "./$0 DIRETORIO   # Deve ser na forma v1 ou v2 ..."
    exit
fi

# 
echo "Impressão da linha de identificação dos campos fins escolha dos NÚMEROS das COLUNAS"

echo -e " 1.Data;\n 2.Hora UTC;\n 3.PRECIPITAÇÃO TOTAL, HORÁRIO (mm);\n 4.PRESSAO ATMOSFERICA AO NIVEL DA ESTACAO, HORARIA (mB);\n 5.PRESSÃO ATMOSFERICA MAX.NA HORA ANT. (AUT) (mB);\n 6.PRESSÃO ATMOSFERICA MIN. NA HORA ANT. (AUT) (mB);\n 7.RADIACAO GLOBAL (Kj/m²);\n 8.TEMPERATURA DO AR - BULBO SECO, HORARIA (°C);\n 9.TEMPERATURA DO PONTO DE ORVALHO (°C);\n 10.TEMPERATURA MÁXIMA NA HORA ANT. (AUT) (°C);\n 11.TEMPERATURA MÍNIMA NA HORA ANT. (AUT) (°C);\n 12.TEMPERATURA ORVALHO MAX. NA HORA ANT. (AUT) (°C);\n 13.TEMPERATURA ORVALHO MIN. NA HORA ANT. (AUT) (°C);\n 14.UMIDADE REL. MAX. NA HORA ANT. (AUT) (%);\n 15.UMIDADE REL. MIN. NA HORA ANT. (AUT) (%);\n 16.UMIDADE RELATIVA DO AR, HORARIA (%);\n 17.VENTO, DIREÇÃO HORARIA (gr) (° (gr));\n 18.VENTO, RAJADA MAXIMA (m/s);\n 19.VENTO, VELOCIDADE HORARIA (m/s);"

echo -e "\nListe, separado por VÍRGULAS, os números desejados (em ORDEM) para extração de CAMPOS. Exemplo: 1,4,18"
echo -n "Digite os números: "
read CAMPOS

echo -n "Os números de campos que serão extraídos: $CAMPOS. Continuar (S/N)?"
read RESPOSTA
if [[ $RESPOSTA == 'n' || $RESPOSTA == 'N' ]]; then
    exit 0
fi

# Diretório de origem
DIRETORIO_DADOS_ORIGEM="$1"

# Diretório de destino
mkdir -p v3


for fname in $(ls $DIRETORIO_DADOS_ORIGEM/dados*.csv)
do
    /bin/ls $fname
    fname_new=$(echo $fname | sed "s/$DIRETORIO_DADOS_ORIGEM/v3/g")
    echo $fname_new
    /bin/cat $fname | cut -d";" -f "$CAMPOS" > $fname_new
done


# Data;Hora UTC;PRECIPITAÇÃO TOTAL, HORÁRIO (mm);PRESSAO ATMOSFERICA AO NIVEL DA ESTACAO, HORARIA (mB);PRESSÃO ATMOSFERICA MAX.NA HORA ANT. (AUT) (mB);PRESSÃO ATMOSFERICA MIN. NA HORA ANT. (AUT) (mB);RADIACAO GLOBAL (Kj/m²);TEMPERATURA DO AR - BULBO SECO, HORARIA (°C);TEMPERATURA DO PONTO DE ORVALHO (°C);TEMPERATURA MÁXIMA NA HORA ANT. (AUT) (°C);TEMPERATURA MÍNIMA NA HORA ANT. (AUT) (°C);TEMPERATURA ORVALHO MAX. NA HORA ANT. (AUT) (°C);TEMPERATURA ORVALHO MIN. NA HORA ANT. (AUT) (°C);UMIDADE REL. MAX. NA HORA ANT. (AUT) (%);UMIDADE REL. MIN. NA HORA ANT. (AUT) (%);UMIDADE RELATIVA DO AR, HORARIA (%);VENTO, DIREÇÃO HORARIA (gr) (° (gr));VENTO, RAJADA MAXIMA (m/s);VENTO, VELOCIDADE HORARIA (m/s);

# 3 PRECIPITAÇÃO TOTAL, HORÁRIO (mm)

# PRESSAO ATMOSFERICA AO NIVEL DA ESTACAO, HORARIA (mB);PRESSÃO ATMOSFERICA MAX.NA HORA ANT. (AUT) (mB);PRESSÃO ATMOSFERICA MIN. NA HORA ANT. (AUT) (mB);RADIACAO GLOBAL (Kj/m²);

# 8 TEMPERATURA DO AR - BULBO SECO, HORARIA (°C);

# TEMPERATURA DO PONTO DE ORVALHO (°C);TEMPERATURA MÁXIMA NA HORA ANT. (AUT) (°C);TEMPERATURA MÍNIMA NA HORA ANT. (AUT) (°C);TEMPERATURA ORVALHO MAX. NA HORA ANT. (AUT) (°C);TEMPERATURA ORVALHO MIN. NA HORA ANT. (AUT) (°C);UMIDADE REL. MAX. NA HORA ANT. (AUT) (%);UMIDADE REL. MIN. NA HORA ANT. (AUT) (%);UMIDADE RELATIVA DO AR, HORARIA (%);

# 17 VENTO, DIREÇÃO HORARIA (gr) (° (gr));
# 18 VENTO, RAJADA MAXIMA (m/s);
# 19 VENTO, VELOCIDADE HORARIA (m/s);

# 2020/01/01;1500 UTC;0;904,1;904,4;904,1;1698,8;26,2;19;26,6;25,3;19,3;17;66;57;65;213;5,9;2,3;




