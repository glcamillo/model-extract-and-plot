#!/bin/bash

if [ -z $1 ]; then
	echo "Erro. Faltou parâmetro de diretório."
	echo "./$0 DIRETORIO"
	exit
fi

#for i in $(ls $1/dados*.csv); do
#	/bin/cat $1 | grep -r -v "null" > $i-r1.csv
#done

# Precisa ir para o diretório destino
cd $1

# Retira as dez primeiras linhas do cabecalho
# [a-zA-Z]: para evitar de trabalhar com os arquivos já trabalhados,
#       terminados em r[1-9].csv
for f in $(ls dados*-v1.csv); do
    /bin/ls $f
    NEW_FILENAME=$(echo $f | sed '1 s/v1/v2/1')
    echo $NEW_FILENAME
    /bin/cat $f | sed '1,8 d' > $NEW_FILENAME
done

# /bin/cat $i | sed '1,10 d' | grep -v "null" > $i-r1.csv: também extrai
#      as linhas com null (NÃO É O CASO ATUAL)

# Volta ao diretório inicial
cd -
