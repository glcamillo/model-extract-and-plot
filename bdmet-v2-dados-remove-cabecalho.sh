#!/bin/bash

# Função para remover dados de cabeçalho
#  O arquivo sem cabeçalho é copiado para ./v2/
#  Também é criado arquico somente com o cabeçalho dos nomes de colunas

# Comando:
# ./bdmet-v2-dados-remove-cabecalho.sh   DIRETORIO
# Parâmetro: diretório onde estão os arquivos (./v1)


# Dados constantes no cabeçalho do arquivo INMET_S_SC_A848_DIONISIO CERQUEIRA_01-01-2020_A_31-12-2020.CSV
# REGIAO:;S
# UF:;SC
# ESTACAO:;DIONISIO CERQUEIRA
# CODIGO (WMO):;A848
# LATITUDE:;-26,286562
# LONGITUDE:;-53,633114
# ALTITUDE:;807,54
# DATA DE FUNDACAO:;31/05/08
# Data;Hora UTC;PRECIPITAÇÃO TOTAL, HORÁRIO (mm);PRESSAO ATMOSFERICA AO NIVEL DA ESTACAO, HORARIA (mB);PRESSÃO ATMOSFERICA MAX.NA HORA ANT. (AUT) (mB);PRESSÃO ATMOSFERICA MIN. NA HORA ANT. (AUT) (mB);RADIACAO GLOBAL (Kj/m²);TEMPERATURA DO AR - BULBO SECO, HORARIA (°C);TEMPERATURA DO PONTO DE ORVALHO (°C);TEMPERATURA MÁXIMA NA HORA ANT. (AUT) (°C);TEMPERATURA MÍNIMA NA HORA ANT. (AUT) (°C);TEMPERATURA ORVALHO MAX. NA HORA ANT. (AUT) (°C);TEMPERATURA ORVALHO MIN. NA HORA ANT. (AUT) (°C);UMIDADE REL. MAX. NA HORA ANT. (AUT) (%);UMIDADE REL. MIN. NA HORA ANT. (AUT) (%);UMIDADE RELATIVA DO AR, HORARIA (%);VENTO, DIREÇÃO HORARIA (gr) (° (gr));VENTO, RAJADA MAXIMA (m/s);VENTO, VELOCIDADE HORARIA (m/s);


if [ -z $1 ]; then
	echo "Erro. Faltou parâmetro de diretório."
	echo "./$0 DIRETORIO"
	exit
fi

# Diretório de origem dos dados
DIRETORIO_DADOS_ORIGEM="$1"

# Diretório de destino
mkdir -p v2

# Retira as NOVE primeiras linhas do cabecalho
for fname in $(ls $DIRETORIO_DADOS_ORIGEM/dados*-v1.csv)
do
    /bin/ls $fname
    fname_new=$(echo $fname | sed 's/v1/v2/g')
    echo $fname_new
    /bin/cat $fname | sed '1,9 d' > ${fname_new}
done

# Retira as OITO primeiras linhas do cabecalho
#  deixando os nomes das colunas
for fname in $(ls $DIRETORIO_DADOS_ORIGEM/dados*-v1.csv)
do
    /bin/ls $fname
    fname_new=$(echo $fname | sed 's/v1/v2/g' | sed 's/v2.csv/v2-nomes-colunas.csv/')
    echo $fname_new
    /bin/cat $fname | sed '1,8 d' > ${fname_new}
done



# /bin/cat $fname | sed '1,10 d' | grep -v "null" > $fname-r1.csv: também extrai
#      as linhas com null (NÃO É O CASO ATUAL)

