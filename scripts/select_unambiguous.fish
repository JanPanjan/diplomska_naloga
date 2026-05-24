#!/bin/fish

cat sword_output/1a62_A_A/SWORD2_summary.json |\
    jq '.["Ambiguity index"]'
