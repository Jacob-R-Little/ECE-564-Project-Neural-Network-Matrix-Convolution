# # -*- coding: utf-8 -*-
# """
# Created on Mon Feb 21 00:01:53 2022

# @author: jasteve4
# """


import numpy as np
import skimage.measure
import yaml
import sys


def convolution(image, kernel, padding = 0, stride = 1):
    kernel_height, kernel_width = kernel.shape
    image_height, image_width = image.shape

    
    H_out = 1+ int((image_height+2*padding - kernel_height)/stride)
    W_out = 1+ int((image_width+2*padding-kernel_width)/stride)
    
    out = np.zeros((H_out, W_out))
    
    for i in range(H_out):
        for j in range(W_out):
            out[i][j] = np.sum(image[i*stride:i+ kernel_height, j*stride:j + kernel_width ] * kernel)
    return out       
          
# ReLU function
def ReLU(x):    
    arr = np.clip(x, 0, 127)
    return arr


def pooling(image):
    max_pool =  skimage.measure.block_reduce(image, (2,2), np.max)
    return max_pool

def fully_connected(weights, pooled):
             
    out = weights.dot(pooled)
    
    return out

if (__name__ == "__main__"):         
    images = []
    outputs = []
    weights = []

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    with open(input_file) as yf :
        yaml_data = yaml.safe_load(yf)
        for img in yaml_data['images'] :
            images.append(yaml_data["images"][img])
        for wgh in yaml_data['weights'] :
            weights.append(yaml_data["weights"][wgh])

    with open(output_file,'w') as yf :
        outputs = {}
        outputs["base-outputs"] = {}
        outputs["outputs"] = {}
        kernel = weights[0]
        for i in range(len(images)):
            conv_im = convolution(np.array(images[i]), np.array(kernel))
            relu_im= ReLU(conv_im)
            if("564" in output_file):
              im_pool = pooling(relu_im)
              fully_im = fully_connected(np.array(weights[i+1]), im_pool)
              fully_im_relu = ReLU(fully_im)
              outputs["base-outputs"]["base-output{}".format(i)] = im_pool.astype(int).tolist()
              outputs["outputs"]["output{}".format(i)] = fully_im_relu.astype(int).tolist()
            else:
              outputs["base-outputs"]["base-output{}".format(i)] = conv_im.astype(int).tolist()
              outputs["outputs"]["output{}".format(i)] = relu_im.astype(int).tolist()
              break
        yf.write(yaml.safe_dump(outputs))

# print(conv_im)
# print(relu_im)
# print(im_pool)
# print(fully_im)
#print(fully_im_relu)
