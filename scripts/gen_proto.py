import os
import re

for filename in os.listdir():
    if os.path.isfile(filename) and 'Encoder.asm' in filename:
        with open(filename, 'r') as f:
            for line in f.readlines():
                match =  re.match(r'^(.*)\s+proc\s+uses.*$', line)
                if match:
                    print(match[1])
