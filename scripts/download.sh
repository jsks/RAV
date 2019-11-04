#!/usr/bin/env zsh

mkdir -p data/{legacy,v1}

typeset -a v1_urls

for i in {04..10}; do
    v1_urls+="https://data.urbansharing.com/oslobysykkel.no/trips/v1/2019/$i.csv"
done

print $v1_urls | xargs -I{} -t -n 1 -P 4 \
                       sh -c 'wget -O - -q {} | gzip > data/v1/$(basename {}).gz'

for i in {2016..2019}; do
    mkdir -p data/legacy/$i
    unset legacy_urls; typeset -a legacy_urls

    for j in {04..11}; do
        [[ $i == 2019 && j > 3 ]] && continue

        legacy_urls+=("https://data-legacy.urbansharing.com/oslobysykkel.no/$i/$j.csv.zip")
    done

    print $legacy_urls | xargs -t -n 1 -P 4 wget -nc -q -P data/legacy/$i/

done
