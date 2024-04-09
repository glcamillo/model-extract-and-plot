#!/bin/bash

if [ -z $1 ]; then
	echo "Erro. Faltou parâmetro de diretório."
	echo "./$0 DIRETORIO"
	exit
fi

find $1 -type f -name 'dados*.csv' | xargs ls $1 

for f in $(ls $1/*.csv); do
    # ESTACAO=$(cat $f | head -1 | cut -d: -f 2 | tr -s ' ' | tr -d ' ')
    # echo $f | cut -d '_' -f 1,2 | xargs -i mv $f {}-$ESTACAO.csv
    echo $f | sed 's/_/-/1' | xargs -i mv $f dados-{} 
done

