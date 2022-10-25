# -*- coding: utf-8 -*-
"""
Created on Tue Feb  8 18:09:02 2022

@author: bitsf
"""

import numpy as np
N = 16
array = np.set_printoptions(formatter={'int':hex})
array = np.random.randint(0, 12, size=(16, 16))
lis = array.tolist()
list_h = [ [int(x) for x in l] for l in lis]
# list_bin = [ [bin(x) for x in l] for l in lis]
# list_b = [ [format(x, "b" ) for x in l] for l in list_h]
# list_hex = [[hex(x) for x in l] for l in list_h]





print(list_h)
# print(list_bin)

