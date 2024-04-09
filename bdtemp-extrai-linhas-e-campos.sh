#!/bin/bash

if [ -z $1 ]; then
	echo "Erro. Faltou parâmetro de diretório."
	echo "./$0 DIRETORIO"
	exit
fi

# Lista o número de linhas em todos os arquivos.

# Precisa ir para o diretório destino
cd $1

for f in $(ls dados*-v2.csv); do
    /bin/ls $f
    NEW_FILENAME=$(echo $f | sed '1 s/v2/v3/1')
    /bin/cat $f | egrep "2020/08/14" > $NEW_FILENAME
done

# Aqui o ls lista os arquivos dentro do diretório
for f in $(ls dados*-v3.csv); do
    /bin/ls $f
    NEW_FILENAME=$(echo $f | sed '1 s/v3/v4/1')
    /bin/cat $f | cut -d \; -f 2,3 > $NEW_FILENAME-prp.csv
    /bin/cat $f | cut -d \; -f 2,8 > $NEW_FILENAME-tar-bulboseco.csv
    /bin/cat $f | cut -d \; -f 2,17 > $NEW_FILENAME-vnt-dir.csv
    /bin/cat $f | cut -d \; -f 2,18 > $NEW_FILENAME-vnt-rjd.csv
    /bin/cat $f | cut -d \; -f 2,19 > $NEW_FILENAME-vnt-veloc.csv
done

# Volta ao diretório inicial
cd -

# Data;Hora UTC;PRECIPITAÇÃO TOTAL, HORÁRIO (mm);PRESSAO ATMOSFERICA AO NIVEL DA ESTACAO, HORARIA (mB);PRESSÃO ATMOSFERICA MAX.NA HORA ANT. (AUT) (mB);PRESSÃO ATMOSFERICA MIN. NA HORA ANT. (AUT) (mB);RADIACAO GLOBAL (Kj/m²);TEMPERATURA DO AR - BULBO SECO, HORARIA (°C);TEMPERATURA DO PONTO DE ORVALHO (°C);TEMPERATURA MÁXIMA NA HORA ANT. (AUT) (°C);TEMPERATURA MÍNIMA NA HORA ANT. (AUT) (°C);TEMPERATURA ORVALHO MAX. NA HORA ANT. (AUT) (°C);TEMPERATURA ORVALHO MIN. NA HORA ANT. (AUT) (°C);UMIDADE REL. MAX. NA HORA ANT. (AUT) (%);UMIDADE REL. MIN. NA HORA ANT. (AUT) (%);UMIDADE RELATIVA DO AR, HORARIA (%);VENTO, DIREÇÃO HORARIA (gr) (° (gr));VENTO, RAJADA MAXIMA (m/s);VENTO, VELOCIDADE HORARIA (m/s);

# 3 PRECIPITAÇÃO TOTAL, HORÁRIO (mm)

# PRESSAO ATMOSFERICA AO NIVEL DA ESTACAO, HORARIA (mB);PRESSÃO ATMOSFERICA MAX.NA HORA ANT. (AUT) (mB);PRESSÃO ATMOSFERICA MIN. NA HORA ANT. (AUT) (mB);RADIACAO GLOBAL (Kj/m²);

# 8 TEMPERATURA DO AR - BULBO SECO, HORARIA (°C);

# TEMPERATURA DO PONTO DE ORVALHO (°C);TEMPERATURA MÁXIMA NA HORA ANT. (AUT) (°C);TEMPERATURA MÍNIMA NA HORA ANT. (AUT) (°C);TEMPERATURA ORVALHO MAX. NA HORA ANT. (AUT) (°C);TEMPERATURA ORVALHO MIN. NA HORA ANT. (AUT) (°C);UMIDADE REL. MAX. NA HORA ANT. (AUT) (%);UMIDADE REL. MIN. NA HORA ANT. (AUT) (%);UMIDADE RELATIVA DO AR, HORARIA (%);

# 17 VENTO, DIREÇÃO HORARIA (gr) (° (gr));
# 18 VENTO, RAJADA MAXIMA (m/s);
# 19 VENTO, VELOCIDADE HORARIA (m/s);

# 2020/01/01;1500 UTC;0;904,1;904,4;904,1;1698,8;26,2;19;26,6;25,3;19,3;17;66;57;65;213;5,9;2,3;




