#!/bin/bash

if [ -z $1 ]; then
	echo "Erro. Faltou parâmetro de diretório."
	echo "./$0 DIRETORIO"
	exit
fi

# Precisa ir para o diretório destino
cd $1

find . -type f -name '*.[cC][sS][vV]' | xargs ls $1 

for f in $(ls *.[cC][sS][vV]); do
    FILENAME=$(echo $f | tr [:upper:] [:lower:])
    echo $f | xargs -i mv $f dados-$FILENAME
done

# CAXIASDOSUL.CSV -> dados-caxiasdosul-v1.csv


for f in $(ls dados-*.csv); do
    echo $f | sed '1 s/.csv/-v1.csv/1' | xargs -i mv $f {}
done

find . -type f -name '*.csv' | xargs ls $1 

# Volta ao diretório inicial
cd -
