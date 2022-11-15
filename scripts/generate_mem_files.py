# -*- coding: utf-8 -*-
"""
Created on Wed Mar  9 11:48:02 2022

@author: bitsf
"""

import numpy as np
import math
import yaml
import sys
import os
import errno



def hex_conversion(array):
    op = np.array(array)
    op1 = np.array(op).flatten().tolist()
    
    op_bin = []
    op_golden = []
    
    for i in op1:
        if(i < 0):
            op_bin.append('{0:02x}'.format(i & 0xFF))
        else:    
            op_bin.append('{0:02x}'.format(i))
    if(len(op_bin) % 2 == 1):
        op_bin.append('{0:02x}'.format(0))
    op_group = [op_bin[n:n+2] for n in range(0, len(op_bin), 2)]
    
    for i in op_group:
        op_golden.append(''.join(i))

    return op_golden    

def convert_dimension_to_binary(bin):
    dimension = int(math.sqrt(2*(len(bin))))
    bin_convert = '{0:016b}'.format(dimension)
    return bin_convert
    
def convert_dimension_to_hex(bin):
    dimension = int(math.sqrt(2*(len(bin))))
    hex_convert = '{0:04x}'.format(dimension)
    return hex_convert

def write_section(f,image,cnt,input_section):
    if(input_section):
        f.write('@')
        cnt = cnt+1
        f.write(hex(cnt).replace('0x',''))
        f.write('\t')
        f.write(convert_dimension_to_hex(image))
        f.write("\n")
    for i in image:
        cnt = cnt+1
        f.write('@')
        a_1 = hex(cnt).replace('0x','')
        f.write(a_1)
        f.write('\t')
        f.write(i + "\n")
    return cnt

if (__name__ == "__main__"):         
    images = []
    outputs = []
    base_outputs = []
    weights = []

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    path = sys.argv[3]
    if(path[-1] != '/'):
        path = path + '/'
    
    if not os.path.exists(os.path.dirname(path)):
        try:
            os.makedirs(os.path.dirname(path))
        except OSError as exc: # Guard against race condition
            if exc.errno != errno.EEXIST:
                raise
    with open(input_file) as yf :
        yaml_data = yaml.safe_load(yf)
        for img in yaml_data['images'] :
            images.append(yaml_data["images"][img])
        for wgh in yaml_data['weights'] :
            weights.append(yaml_data["weights"][wgh])

    with open(output_file) as yf :
        yaml_data = yaml.safe_load(yf)
        for out in yaml_data['outputs'] :
            outputs.append(yaml_data["outputs"][out])
        for out in yaml_data['base-outputs'] :
            base_outputs.append(yaml_data["base-outputs"][out])

    if("564" in path):
      input_file_name = 'input_sram_564.dat'
    else: 
      input_file_name = 'input_sram_464.dat'
    with open(path + input_file_name, 'w') as F:
        cnt_1 = -1
        if("564" in output_file):
          for img in images :
              cnt_1 = write_section(F,hex_conversion(img),cnt_1,True)
          cnt_1 = cnt_1+1
          F.write('@')
          a_1 = hex(cnt_1).replace('0x','')
          F.write(a_1)
          F.write('\t')
          F.write("FFFF" + "\n")
        else:
          cnt_1 = write_section(F,hex_conversion(images[0]),cnt_1,False)
      
    if("564" in path):
      weight_file_name = 'weight_sram_564.dat'
    else: 
      weight_file_name = 'weight_sram_464.dat'
    with open(path + weight_file_name, 'w') as F:
      cnt_1 = -1
      if("564" in output_file):
        for wgh in weights :
            cnt_1 = write_section(F,hex_conversion(wgh),cnt_1,False)
      else:
        cnt_1 = write_section(F,hex_conversion(weights[0]),cnt_1,False)

            
    if("564" in path):
      output_file_name = 'golden_outputs_564.dat'
    else: 
      output_file_name = 'golden_outputs_464.dat'
    with open(path + output_file_name, 'w') as F:
      cnt_1 = -1
      for out in outputs :
          cnt_1 = write_section(F,hex_conversion(out),cnt_1,False)
    if("564" in path):
      output_file_name = 'golden_base_outputs_564.dat'
      with open(path + output_file_name, 'w') as F:
        cnt_1 = -1
        for out in base_outputs :
            cnt_1 = write_section(F,hex_conversion(out),cnt_1,False)
    else: 
      output_file_name = 'golden_base_outputs_464.dat'
      with open(path + output_file_name, 'w') as F:
        cnt_1 = -1
        for out in base_outputs :
          base_out = []
          for i, row in enumerate(out):
            temp = []
            for j, val in enumerate(row):
              temp.append((val >> 8) & 0xFF)
              temp.append(val & 0xFF)
              temp.append((val >> 24) & 0xFF)
              temp.append((val >> 16) & 0xFF)
            base_out.append(temp)
          cnt_1 = write_section(F,hex_conversion(base_out),cnt_1,False)


    #with open(path + output_file_name, 'w') as F:
    #  cnt_1 = -1
    #  for out in outputs :
    #      cnt_1 = write_section(F,hex_conversion(out),cnt_1,False)
        
        
        
        


