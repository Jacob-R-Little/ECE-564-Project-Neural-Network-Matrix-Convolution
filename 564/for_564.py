# -*- coding: utf-8 -*-
"""
Created on Wed Mar  9 11:48:02 2022

@author: bitsf
"""

import numpy as np
import math

# list it in two 
# each eight bit


############### for inputs ################


image1 = [[23, 39, 13, 37, 33, 15, 36, 21], [11, 29, 37, 26, 11, 23, 30, 31], [12, 0, 24, 29, 19, 0, 8, 38], [37, 6, 8, 35, 34, 29, 6, 24], [34, 39, 36, 8, 20, 16, 23, 18], [23, 37, 35, 15, 6, 12, 9, 12], [39, 32, 13, 39, 7, 38, 21, 11], [0, 3, 20, 12, 0, 0, 15, 8]]

image2 = [[10, 7, 11, 11, 10, 4, 0, 8, 2, 9, 8, 1, 8, 5, 10, 9], [9, 10, 3, 1, 3, 10, 2, 1, 1, 3, 1, 5, 11, 11, 5, 6], [1, 9, 5, 0, 2, 7, 9, 6, 7, 7, 0, 10, 7, 4, 1, 0], [3, 7, 9, 3, 11, 4, 6, 1, 8, 6, 1, 1, 0, 11, 11, 4], [1, 10, 0, 11, 6, 5, 0, 9, 3, 1, 0, 3, 6, 11, 7, 7], [0, 4, 3, 2, 9, 7, 6, 7, 0, 8, 3, 5, 2, 7, 7, 6], [11, 8, 2, 8, 2, 6, 6, 4, 3, 4, 10, 7, 7, 9, 0, 1], [2, 6, 4, 10, 10, 4, 8, 2, 0, 7, 6, 2, 9, 4, 3, 10], [5, 1, 10, 7, 7, 10, 6, 3, 11, 1, 3, 10, 1, 11, 11, 5], [11, 6, 10, 2, 4, 1, 1, 5, 10, 3, 8, 3, 2, 6, 10, 6], [8, 1, 2, 8, 8, 5, 8, 1, 7, 3, 6, 2, 10, 4, 4, 2], [11, 7, 3, 3, 7, 3, 4, 0, 11, 8, 10, 0, 7, 7, 4, 9], [10, 10, 8, 4, 7, 11, 4, 3, 2, 2, 0, 8, 9, 8, 9, 5], [5, 5, 9, 7, 9, 8, 7, 0, 2, 7, 8, 2, 10, 11, 0, 3], [7, 1, 3, 3, 0, 9, 11, 9, 10, 0, 1, 9, 0, 7, 5, 5], [10, 10, 6, 3, 7, 5, 8, 6, 8, 11, 7, 7, 6, 8, 11, 9]]

image3 = [[1, 8, 5, 4, 8, 9, 2, 8, 1, 0, 3, 7, 2, 5, 8, 0], [6, 3, 9, 4, 7, 6, 1, 9, 10, 10, 3, 7, 2, 0, 2, 9], [5, 9, 10, 11, 8, 0, 3, 3, 11, 7, 0, 1, 9, 6, 1, 10], [1, 7, 6, 1, 9, 4, 8, 8, 8, 8, 4, 3, 7, 6, 6, 0], [10, 8, 3, 1, 7, 3, 7, 4, 7, 9, 5, 11, 10, 0, 8, 9], [3, 5, 9, 1, 5, 8, 5, 8, 9, 4, 10, 0, 2, 7, 4, 8], [3, 11, 11, 8, 3, 5, 9, 11, 1, 3, 4, 5, 11, 7, 9, 5], [0, 11, 5, 10, 0, 6, 4, 1, 0, 8, 11, 9, 6, 6, 11, 11], [9, 2, 8, 11, 4, 5, 5, 9, 4, 2, 5, 9, 11, 11, 11, 10], [6, 2, 11, 3, 9, 1, 5, 7, 0, 0, 0, 1, 7, 11, 6, 7], [9, 6, 5, 9, 6, 1, 6, 1, 3, 8, 3, 11, 5, 7, 4, 4], [3, 5, 5, 11, 9, 7, 6, 3, 3, 0, 2, 9, 1, 10, 10, 6], [2, 2, 7, 7, 0, 2, 11, 6, 7, 6, 5, 8, 11, 3, 1, 2], [2, 5, 2, 9, 9, 0, 4, 1, 1, 5, 4, 9, 5, 3, 3, 11], [10, 6, 3, 1, 1, 4, 6, 10, 8, 2, 3, 0, 8, 2, 3, 1], [3, 10, 5, 10, 8, 4, 3, 6, 8, 2, 7, 11, 6, 2, 3, 4]]   



####### TRIAL CODE #######

# ip = np.array(image)

# img1 = np.array(ip).flatten().tolist()

# ip_bin = []
# ip_sram = []
# total_ip = []

# for i in img1:
#     ip_bin.append('{0:08b}'.format(i))
    

# ip_group =  [ip_bin[n:n+2] for n in range(0, len(ip_bin), 2)]   

# for i in ip_group:
#     ip_sram.append(''.join(i))
    
 
# print(ip_sram)    
    
##############################

############# for outputs #########################


# op = np.array(output)

# op1 = np.array(op).flatten().tolist()

# op_bin = []
# op_golden = []
# total =[]

# for i in op1:
#     op_bin.append('{0:08b}'.format(i))
    
  
    
# op_group = [op_bin[n:n+2] for n in range(0, len(op_bin), 2)]  

# for i in op_group:
#     op_golden.append(''.join(i))

        

############### for kernels and weights ##############


# kernel = [[-1, 1, 0], [2, 3, 0], [-2, -2, -1]]


# weights1 = [[-1, 2, 0], [1, 0, 0], [1, -1, 1]]


# weights2 = [[-1, 0, 2, 1, -1, -2, 1], [-1, 0, 2, 0, -1, 2, -1], [0, 1, -2, 2, 1, 1, 0], [-1, 2, 1, -1, 0, -1, 2], [2, 1, 0, -2, 2, 0, -1], [1, -1, 2, 1, 2, -1, 0], [-2, -1, -2, 1, 0, 2, 0]]    

# weights3 = [[1, 3, 1, 1, -2, -1, -2], [-1, 1, -2, -2, 2, 2, 2], [0, -1, 0, -1, 3, 3, 1], [2, 0, 2, -1, -2, 0, 3], [3, -1, 1, 0, -1, 3, 1], [-2, 2, -1, -1, -2, 3, -1], [-1, 3, -1, -1, 0, -2, 1]]   



# def bindigits(n, bits):
#     s = bin(n & int("1"*bits, 2))[2:]
#     return ("{0:0>%s}" % (bits)).format(s)
        
# temp_kernel = []
# temp_weights1 = []
# temp_weights2 = []
# temp_weights3 = []


# for k in kernel:
#     for l in k:
#         temp_kernel.append(bindigits(l, 8))
        
# temp_kernel.append('00000000')

# for i in weights1:
#     for j in i:
#         temp_weights1.append(bindigits(j, 8))
        
              
# temp_weights1.append('00000000')    

# for p in weights2:
#     for q in p:
#         temp_weights2.append(bindigits(q, 8))
        
# temp_weights2.append('00000000')  

# for a in weights3:
#     for b in a:
#         temp_weights3.append(bindigits(b, 8))
        
# temp_weights3.append('00000000')        
    
# def group(array):
#     op_weight = []
#     op_group = [array[n:n+2] for n in range(0, len(array), 2)]
    
#     for i in op_group:
#         op_weight.append(''.join(i))
        
#     return op_weight

# final_weights1 = group(temp_weights1)
# final_weights2 = group(temp_weights2)
# final_weights3 = group(temp_weights3)
# final_kernel = group(temp_kernel)

# print(final_weights1)
# print(final_weights2)
# print(final_weights3)
# print(final_kernel)
############## for positive signed bits #################


# output1 = [[  0, 127,   0],
#  [ 77,  51, 103],
#  [127,  27, 127]]

# output2 = [[  0,  34,  41,   0,   0,   0,   0],
#  [ 13,   0,   0,  39,  41,  10,   0],
#  [ 19,  80,  76,  38, 103,  22,  68],
#  [ 91,  75,  36,  21,  43,   0,  82],
#  [115,   0,   0,  77,   1,  57,  78],
#  [112,  43,  95,  74,   1,  90,  84],
#  [  0,   1,   0,   0,  40,   0,   0]]

# output3 = [[ 83,   0,  13,  32,   0,  98,   0],
#  [  0,  56,  41,   3,   0,  57,  51],
#  [ 19,  92,  82, 114,  84,  34, 127],
#  [ 83, 127,  76, 103,  36,  70,   0],
#  [ 80, 127, 127, 127,  94,  61, 112],
#  [  0,   7,  44,   0,   0,   0,  37],
#  [ 24,   0,   0,   0,   0,  84,   0]]
    
def bin_conversion(array):
    op = np.array(array)
    op1 = np.array(op).flatten().tolist()
    
    op_bin = []
    op_golden = []
    
    for i in op1:
        op_bin.append('{0:08b}'.format(i))
        
    op_group = [op_bin[n:n+2] for n in range(0, len(op_bin), 2)]
    
    for i in op_group:
        op_golden.append(''.join(i))

    return op_golden    
        
    
# op_golden1 = bin_conversion(output1)
# op_golden2 = bin_conversion(output2)
# op_golden3 = bin_conversion(output3)
# print(op_golden1)
# print(op_golden2)
# print(op_golden3)
image_ip1 = bin_conversion(image1)
image_ip2 = bin_conversion(image2)
# print(image_ip2)
image_ip3 = bin_conversion(image3)
# print(image_ip)

    
# cnt_0 = -1
# with open('golden_outputs_564.dat', 'w') as f:
#     for i in op_golden1:
#         f.write('@')
#         cnt_0 = cnt_0+1
#         a_0 = hex(cnt_0).replace('0x','')
#         f.write(a_0)
#         f.write('	')
#         f.write(i + "\n")
#     for j in op_golden2:
#         f.write('@')
#         cnt_0 = cnt_0+1
#         a_0 = hex(cnt_0).replace('0x','')
#         f.write(a_0)
#         f.write('	')
#         f.write(j + "\n")
#     for k in op_golden3:
#         f.write('@')
#         cnt_0 = cnt_0+1
#         a_0 = hex(cnt_0).replace('0x','')
#         f.write(a_0)
#         f.write('	')
#         f.write(k + "\n")        
#     f.close()    
        
# dimension = int(math.sqrt(len(2*image_ip)))
# print(dimension)
# bin_ = '{0:016b}'.format(dimension)
# print(bin_)


def convert_dimension_to_binary(bin):
    dimension = int(math.sqrt(2*(len(bin))))
    bin_convert = '{0:016b}'.format(dimension)
    return bin_convert
    



cnt_1 = -1
with open('input_sram_564.dat', 'w') as f_i:
    f_i.write('@')
    cnt_1 = cnt_1+1
    f_i.write(str(cnt_1).replace('0x', ''))
    f_i.write('	')
    f_i.write(convert_dimension_to_binary(image_ip1))
    f_i.write("\n")
    for i in image_ip1:
        cnt_1 = cnt_1+1
        f_i.write('@')
        a_1 = hex(cnt_1).replace('0x','')
        f_i.write(a_1)
        f_i.write('	')
        f_i.write(i + "\n")
    f_i.write('@')
    cnt_1 = cnt_1 + 1
    f_i.write(hex(cnt_1).replace('0x', ''))
    f_i.write(' ')
    f_i.write(convert_dimension_to_binary(image_ip2))
    f_i.write("\n")
    for j in image_ip2:
        cnt_1 = cnt_1 + 1
        f_i.write('@')
        a_2 = hex(cnt_1).replace('0x','')
        f_i.write(a_2)
        f_i.write('	')
        f_i.write(j + "\n")
        cnt_1 = cnt_1 + 1
    f_i.write('@')
    cnt_1 = cnt_1 + 1
    f_i.write(hex(cnt_1).replace('0x', ''))
    f_i.write(' ')
    f_i.write(convert_dimension_to_binary(image_ip3))
    f_i.write("\n") 
    for k in image_ip3:
        cnt_1 = cnt_1 + 1
        f_i.write('@')
        a_2 = hex(cnt_1).replace('0x','')
        f_i.write(a_2)
        f_i.write('	')
        f_i.write(k + "\n")           
    f_i.close()    
  

# cnt_2 = -1
# with open('weight_sram_564.dat', 'w') as f_w:
#     for i in final_kernel:
#         f_w.write('@')
#         cnt_2 = cnt_2 +1
#         a_2 = hex(cnt_2).replace('0x','')
#         f_w.write(a_2)
#         f_w.write(' ')
#         f_w.write(i + "\n")
#     for j in final_weights1:
#         f_w.write('@')
#         cnt_2 = cnt_2 +1
#         a_2 = hex(cnt_2).replace('0x', '')
#         f_w.write(a_2)
#         f_w.write(' ')
#         f_w.write(j + "\n")
#     for k in final_weights2:
#         f_w.write('@')
#         cnt_2 = cnt_2 +1
#         a_2 = hex(cnt_2).replace('0x', '')
#         f_w.write(a_2)
#         f_w.write(' ')
#         f_w.write(k + "\n")          
#     for l in final_weights3:
#         f_w.write('@')
#         cnt_2 = cnt_2 +1
#         a_2 = hex(cnt_2).replace('0x', '')
#         f_w.write(a_2)
#         f_w.write(' ')
#         f_w.write(l + "\n")           
#     f_w.close()        
        
        
        
        
        
        


