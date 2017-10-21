
## Pytorch notebook

Pytorch has two design philosophies. 

I. A replacement for Numpy to use the powers of GPU.

II. A fast and flexible platform for deep learning research
### Basic functions
1. In-place functions are always post-fixed with "_"

2. Zoo of manipulations for torch can be found [here](http://pytorch.org/docs/master/torch.html)


```python
import torch
```


```python
x = torch.rand(4, 3) #randomly initialized
print x
x.t_() #transpose of x, note that x has been changed!
print x
```

    
     0.1916  0.0067  0.8545
     0.3716  0.9280  0.9058
     0.1115  0.8290  0.8737
     0.0272  0.1032  0.7673
    [torch.FloatTensor of size 4x3]
    
    
     0.1916  0.3716  0.1115  0.0272
     0.0067  0.9280  0.8290  0.1032
     0.8545  0.9058  0.8737  0.7673
    [torch.FloatTensor of size 3x4]
    



```python
z = torch.Tensor(3, 4)
z.copy_(x) #copy x to z
print z
```

    
     0.1916  0.3716  0.1115  0.0272
     0.0067  0.9280  0.8290  0.1032
     0.8545  0.9058  0.8737  0.7673
    [torch.FloatTensor of size 3x4]
    



```python
z.add_(x)
```




    
     0.3831  0.7433  0.2230  0.0545
     0.0134  1.8560  1.6579  0.2064
     1.7090  1.8116  1.7473  1.5346
    [torch.FloatTensor of size 3x4]



### Connection to Numpy
As a replacement for Numpy, Pytorch is nicely bridged and connected with Numpy. It supports all numpy-style indexing, and its tensor datatype can be simply converted to numpy ndarrays. For example:


```python
a= torch.ones(3)
print a
```

    
     1
     1
     1
    [torch.FloatTensor of size 3]
    



```python
b = a.numpy()
print b
```

    [ 1.  1.  1.]



```python
a.add_(2)
print a, b  #Note that both a and b are changed!
```

    
     5
     5
     5
    [torch.FloatTensor of size 3]
     [ 5.  5.  5.]


Torch tensors can be moved to GPU using ``.cuda`` function


```python
if torch.cuda.is_available():
    a = a.cuda()
    b = b.cuda()
    c = a + b
```


```python

```
