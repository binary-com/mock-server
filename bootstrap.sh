#!/bin/bash

if [ $# -eq 0 ]; then
    echo "ERROR: Access token needs to be supplied as the first argument"
    exit 1
fi

URL="http://rmg-prod.apigee.net/v1/binary"
FSPATH="test/mock-api/GET/v1/binary"
TOKEN="$1"

# Set permissions
chmod a+x tools/json

# Delete top level directory
echo "Deleting top level directory ..."
rm -f /tmp/symbols

# Create relevant top level directories
echo "Creating top level directories ..."
mkdir -p "${FSPATH}"
mkdir -p "${FSPATH}/markets"
mkdir -p "${FSPATH}/symbols"

# Get market list
echo "Getting market list ..."
if ! [ -f "${FSPATH}/markets.json" ]; then

    printf "200 OK\n\n" > ${FSPATH}/markets.json
    curl -s -H "Authorization: Bearer ${TOKEN}" "${URL}/markets" | python -mjson.tool >> ${FSPATH}/markets.json

fi

# Get market details
echo "Getting market details ..."
markets=(randoms indices commodities forex stocks sectors)

for market in "${markets[@]}"; do

    if ! [ -f "${FSPATH}/markets/${market}.json" ]; then

        printf "200 OK\n\n" > ${FSPATH}/markets/${market}.json
        curl -s -H "Authorization: Bearer ${TOKEN}" "${URL}/markets/${market}" | python -mjson.tool >> ${FSPATH}/markets/${market}.json

    fi
done

# Get symbols list
echo "Getting symbols list ..."

if ! [ -f "${FSPATH}/symbols.json" ]; then

    printf "200 OK\n\n" > ${FSPATH}/symbols.json
    curl -s -H "Authorization: Bearer ${TOKEN}" "${URL}/symbols" | python -mjson.tool >> ${FSPATH}/symbols.json

fi

# Generating symbols file
cat ${FSPATH}/symbols.json | tail -n+3 | ./tools/json -a symbols | ./tools/json -a symbol > /tmp/symbols

# Get symbol details
echo "Getting symbol details ..."

for symbol in `cat /tmp/symbols`; do

    if ! [ -f "${FSPATH}/symbols/${symbol}.json" ]; then

        printf "200 OK\n\n" > ${FSPATH}/symbols/${symbol}.json
        curl -s -H "Authorization: Bearer ${TOKEN}" "${URL}/symbols/$symbol" | python -mjson.tool >> ${FSPATH}/symbols/${symbol}.json

    fi

done

# Get symbol price details
echo "Getting symbol price details ..."

for symbol in `cat /tmp/symbols`; do

    if ! [ -f "${FSPATH}/symbols/${symbol}/price.json" ]; then

        mkdir -p ${FSPATH}/symbols/${symbol}
        printf "200 OK\n\n" > ${FSPATH}/symbols/${symbol}/price.json
        curl -s -H "Authorization: Bearer ${TOKEN}" "${URL}/symbols/${symbol}/price" | python -mjson.tool >> ${FSPATH}/symbols/${symbol}/price.json

    fi
    
done

# Get historical ticks data
echo "Getting historical ticks data ..."

for symbol in `cat /tmp/symbols`; do

    if ! [ -f "${FSPATH}/symbols/${symbol}/ticks.json" ]; then

        printf "200 OK\n\n" > ${FSPATH}/symbols/${symbol}/ticks.json
        curl -s -H "Authorization: Bearer ${TOKEN}" "${URL}/symbols/${symbol}/ticks" | python -mjson.tool >> ${FSPATH}/symbols/${symbol}/ticks.json

    fi

    if ! [ -f "${FSPATH}/symbols/${symbol}/candles.json" ]; then

        printf "200 OK\n\n" > ${FSPATH}/symbols/${symbol}/candles.json
        curl -s -H "Authorization: Bearer ${TOKEN}" "${URL}/symbols/${symbol}/candles" | python -mjson.tool >> ${FSPATH}/symbols/${symbol}/candles.json
    
    fi
done

# Get contract discovery data
echo "Getting contract discovery data ..."
if ! [ -f "${FSPATH}/offerings.json" ]; then

    printf "200 OK\n\n" > ${FSPATH}/offerings.json
    curl -s -H "Authorization: Bearer ${TOKEN}" "${URL}/offerings" | python -mjson.tool >> ${FSPATH}/offerings.json

fi

for market in "${markets[@]}"; do

    if ! [ -f "${FSPATH}/markets/${market}/contract_categories.json" ]; then

        mkdir -p ${FSPATH}/markets/${market}
        printf "200 OK\n\n" > ${FSPATH}/markets/${market}/contract_categories.json
        curl -s -H "Authorization: Bearer ${TOKEN}" "${URL}/markets/${market}/contract_categories" | python -mjson.tool >> ${FSPATH}/markets/${market}/contract_categories.json

    fi
done

# Get contract negotiation data
echo "Getting contract negotiation data ..."
if ! [ -f "${FSPATH}/payout_currencies.json" ]; then

    printf "200 OK\n\n" > ${FSPATH}/payout_currencies.json
    curl -s -H "Authorization: Bearer ${TOKEN}" "${URL}/payout_currencies" | python -mjson.tool >> ${FSPATH}/payout_currencies.json

fi

# Remove temporary files
echo "Deleting temporary files ..."
rm -f /tmp/symbols
