# -*- coding: utf-8 -*-
"""
Created on Tue Feb  8 18:09:02 2022

@author: bitsf
"""

import numpy as np
import yaml
import sys
def generate_randomint_NxN_array(N,_min,_max):
  array = np.random.randint(_min, _max, size=(N, N))
  return array.tolist()

def generate_randomnormal_NxN_array(N,_min,_max):
  array = np.random.uniform(_min, _max, size=[N,N]).astype(int)
  return array.tolist()

def generate_input(N):
  _img =  generate_randomint_NxN_array(N,0,127)
  _weights =  generate_randomnormal_NxN_array(int((N-2)/2),-126*.05,127*.05)
  return [_img, _weights]


if (__name__ == "__main__"):         
  output_file = sys.argv[1]
  num_of_sections = sys.argv[2]
  with open(output_file,'w') as yf :
      outputs = {}
      outputs["images"] = {}
      outputs["weights"] = {} 
      outputs["weights"]["kernel"] = generate_randomint_NxN_array(3,-3,3)
      for i in range(int(num_of_sections)):
        N = np.random.randint(3, 8)
        N = N*2
        [_img,_weights] = generate_input(N)
        outputs["images"]["image"+str(i)] = _img
        outputs["weights"]["weight" + str(i)] = _weights
      yf.write(yaml.safe_dump(outputs))
