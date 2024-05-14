#!/bin/bash

sed -i $'s/\t/    /g' ./*.asm
sed -i $'s/\t/    /g' cores/*.asm

