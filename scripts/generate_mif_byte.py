
import glob
files = glob.glob('./*txt')
print ('read test vectors:', files)

vec = []

for fil in files:
    with open(fil) as f:
        lines = f.readlines()
        s = []
        for line in lines:
            s.append("%02x"%int('0b'+line.strip("\n"), 2))
        vec.append(s)
        print(fil, " -  Total Length:", len(s))

print(vec)
        
    
name = 'ref_output.mif'
print ('generating:', name)

print ('WIDTH=', str(len(vec) * 8))
print ('DEPTH=' + str(len(vec[0])))

with open(name, 'w') as fw:
    fw.write('\n')
    fw.write('WIDTH=' + str(len(vec)* 8) + ';\n')
    fw.write('DEPTH=' + str(len(vec[0])) + ';\n')
    fw.write('\n')
    fw.write('ADDRESS_RADIX=UNS' + ';\n')
    fw.write('DATA_RADIX=HEX' + ';\n')
    fw.write('\n')
    fw.write('CONTENT BEGIN\n')

    for si in range(len(vec[0])):
        fw.write('\t' + str(si) + '    :   ')
        for vec_t in vec:
            fw.write(vec_t[len(vec[0]) - si - 1])
        fw.write(';\n')

    fw.write('END;\n')
    fw.write('\n')
print ()

