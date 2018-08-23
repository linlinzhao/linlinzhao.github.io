---
layout: post
comment: true
title: Understanding backward() in PyTorch (Updated for V0.4) 
key: 10004
tags: PyTorch, backward 
category: tech
date: 2017-10-24
---
Update for PyTorch 0.4:

Earlier versions used ``Variable`` to wrap tensors with different properties. Since version 0.4, ``Variable`` is merged with ``tensor``, in other words, ``Variable`` is NOT needed anymore. The flag ``require_grad`` can be directly set in ``tensor``. Accordingly, this post is also updated. 

------------

<!--more-->
Having heard about the announcement about Theano from Bengio lab , as a Theano user, I am happy and sad to see the fading of the old hero, caused by many raising stars. Sad to see it is too old to compete with its industrial competitors, and happy to have so many excellent deep learning frameworks to choose from. Recently I started translating some of my old codes to Pytorch and have been really impressed by its dynamic nature and clearness. But at the very beginning, I was very confused by the ``backward()`` function when reading the tutorials and documentations. This motivated me to write this post in order for other Pytorch beginners to ease the understanding a bit. And I'll assume that you already know the [``autograd``](http://pytorch.org/docs/master/autograd.html) module and what a [``Variable``](http://pytorch.org/docs/0.1.12/_modules/torch/autograd/variable.html) is, but are a little confused by definition of ``backward()``. 

First let's recall the gradient computing under mathematical notions. 
For an independent variable $$x$$ (scalar or vector), the whatever operation on $$x$$ is $$y = f(x)$$. Then the gradient of $$y$$ w.r.t $$x_i$$s is

$$
\begin{align}
\nabla y&=\begin{bmatrix}
\frac{\partial y}{\partial x_1}\\
\frac{\partial y}{\partial x_2}\\
\vdots
\end{bmatrix}
\end{align}.
$$

Then for a specific point of $$x=[X_1, X_2, \cdots]$$, we'll get the gradient of $$y$$ on that point as a vector. 
With these notions in mind, the following things are a bit confusing at the beginning

1. Mathematically, we would say "The gradients of a function w.r.t. the independent variables", whereas the ``.grad`` is attached to the leaf ``tensor``s. In Theano and Tensorflow, the computed gradients are stored separately in a variable. But with a moment of adjustment, it is fairly easy to buy that. In Pytorch it is also possible to get the ``.grad`` for intermediate ``Variable``s with help of ``register_hook`` function

2. The parameter ``grad_variables`` of the function ``torch.autograd.backward(variables, grad_tensors=None, retain_graph=None, create_graph=None, retain_variables=None, grad_variables=None)`` is not straightforward for knowing its functionality. **note that ``grad_variables`` is deprecated, use ``grad_tensors`` instead. 

3. What is ``retain_graph`` doing?


```python
import torch as T
import torch.autograd
import numpy as np
```

### Simplicity of using ``backward()``


```python
'''
Define a scalar variable, set requires_grad to be true to add it to backward path for computing gradients

It is actually very simple to use backward()

first define the computation graph, then call backward()
'''

x = T.randn(1, 1, requires_grad=True) #x is a leaf created by user, thus grad_fn is none
print('x', x)
#define an operation on x
y = 2 * x
print('y', y)
#define one more operation to check the chain rule
z = y ** 3
print('z', z)

```

    x tensor([[-0.6955]], requires_grad=True)
    y tensor([[-1.3911]], grad_fn=<MulBackward>)
    z tensor([[-2.6918]], grad_fn=<PowBackward0>)


The simple operations defined a forward path $$z=(2x)^3$$, $$z$$ will be the final output ``tensor`` we would like to compute gradient: $$dz=24x^2dx$$, which will be passed to the parameter ``tensors`` in ``backward()`` function. 


```python
#yes, it is just as simple as this to compute gradients:
z.backward()
```


```python
print('z gradient:', z.grad)
print('y gradient:', y.grad)
print('x gradient:', x.grad, 'Requires gradient?', x.grad.requires_grad) # note that x.grad is also a tensor
```

    z gradient None
    y gradient None
    x gradient tensor([[11.6105]]) Requires gradient? False


The gradients of both $$y$$ and $$z$$ are None, since the function returns the gradient for the leaves, which is $$x$$ in this case. At the very beginning, I was assuming something like this:

```python
x gradient: None

y gradient: None

z gradient: tensor([11.6105])
```

since the gradient is calculated for the final output $$z$$.

With a blink of thinking, we could figure out it would be practically chaos if $$x$$ is a multi-dimensional vector. ``x.grad`` should be interpreted as the gradient of $$z$$ at $$x$$.  

### How do we use ``grad_tensors``?

``grad_tensors`` should be a list of torch tensors. In default case, the ``backward()`` is applied to scalar-valued function, the default value of ``grad_tensors`` is thus ``torch.FloatTensor([0])``. But why is that? What if we put some other values to it?

Keep the same forward path, then do ``backward`` by only setting ``retain_graph`` as ``True``. 


```python
x = T.randn(1, 1, requires_grad=True) #x is a leaf created by user, thus grad_fn is none
print('x', x)
#define an operation on x
y = 2 * x
#define one more operation to check the chain rule
z = y ** 3

z.backward(retain_graph=True)
print('Keeping the default value of grad_tensors gives')
print('z gradient:', z.grad)
print('y gradient:', y.grad)
print('x gradient:', x.grad)
```

    x tensor([[-0.7207]], requires_grad=True)
    Keeping the default value of grad_tensors gives
    z gradient: None
    y gradient: None
    x gradient: tensor([[12.4668]])


Testing the explicit default value, which should give the same result. For the same graph which is retained, DO NOT forget to zero the gradient before recalculate the gradients. 


```python
x.grad.data.zero_()
z.backward(T.Tensor([[1]]), retain_graph=True)
print('Set grad_tensors to 1 gives')
print('z gradient:', z.grad)
print('y gradient:', y.grad)
print('x gradient:', x.grad)
```

    Set grad_tensors to 0 gives
    z gradient: None
    y gradient: None
    x gradient: tensor([[12.4668]])


Then what about other values, let's try 0.1 and 0.5.


```python
x.grad.data.zero_()
z.backward(T.Tensor([[0.1]]), retain_graph=True)
print('Set grad_tensors to 0.1 gives')
print('z gradient:', z.grad)
print('y gradient:', y.grad)
print('x gradient:', x.grad)
```

    Set grad_tensors to 0.1 gives
    z gradient: None
    y gradient: None
    x gradient: tensor([[1.2467]])



```python
x.grad.data.zero_()
z.backward(T.FloatTensor([[0.5]]), retain_graph=True)
print('Modifying the default value of grad_variables to 0.1 gives')
print('z gradient', z.grad)
print('y gradient', y.grad)
print('x gradient', x.grad)
```

    Modifying the default value of grad_variables to 0.5 gives

    z gradient None
    
    y gradient None
    
    x gradient tensor([[6.2334]])


It looks like the elements of ``grad_tensors`` act as scaling factors. Now let's set $$x$$ to be a $$2\times 2$$ matrix. Note that $$z$$ will also be a matrix. (Always use the latest version, ``backward`` had been improved a lot from earlier version, becoming much easier to understand.)


```python
x = T.randn(2, 2, requires_grad=True) #x is a leaf created by user, thus grad_fn is none
print('x', x)
#define an operation on x
y = 2 * x
#define one more operation to check the chain rule
z = y ** 3

print('z shape:', z.size())
z.backward(T.FloatTensor([[1, 1], [1, 1]]), retain_graph=True)
print('x gradient for its all elements:\n', x.grad)

print()
x.grad.data.zero_() #the gradient for x will be accumulated, it needs to be cleared.
z.backward(T.FloatTensor([[0, 1], [0, 1]]), retain_graph=True)
print('x gradient for the second column:\n', x.grad)

print()
x.grad.data.zero_()
z.backward(T.FloatTensor([[1, 1], [0, 0]]), retain_graph=True)
print('x gradient for the first row:\n', x.grad)

```

    x tensor([[-2.5212,  1.2730],
            [ 0.0366, -0.0750]], requires_grad=True)
    z shape: torch.Size([2, 2])
    x gradient for its all elements:
     tensor([[152.5527,  38.8946],
            [  0.0322,   0.1349]])
    
    x gradient for the second column:
     tensor([[ 0.0000, 38.8946],
            [ 0.0000,  0.1349]])
    
    x gradient for the first row:
     tensor([[152.5527,  38.8946],
            [  0.0000,   0.0000]])


 We can clearly see the gradients of $$z$$ are computed w.r.t to each dimension of $$x$$, because the operations are all element-wise. 

Then what if we render the output one-dimensional (scalar) while $$x$$ is two-dimensional. This is a real simplified scenario of neural networks. 

$$f(x)=\frac{1}{n}\sum_i^n(2x_i)^3$$

$$f'(x)=\frac{1}{n}\sum_i^n24x_i^2$$


```python
x = T.randn(2, 2, requires_grad=True) #x is a leaf created by user, thus grad_fn is none
print('x', x)
#define an operation on x
y = 2 * x
#print('y', y)
#define one more operation to check the chain rule
z = y ** 3
out = z.mean()
print('out', out)
out.backward(retain_graph=True)
print('x gradient:\n', x.grad)

```

    x tensor([[ 1.8528,  0.2083],
            [-1.5296,  0.3136]], requires_grad=True)
    out tensor(5.6434, grad_fn=<MeanBackward1>)
    x gradient:
     tensor([[20.5970,  0.2604],
            [14.0375,  0.5903]])


We will get complaints if the ``grad_tensors`` is specified for the scalar function. 


```python
x.grad.data.zero_()
out.backward(T.FloatTensor([[1, 1], [1, 1]]), retain_graph=True)
print('x gradient', x.grad)
```


    ---------------------------------------------------------------------------

    RuntimeError                              Traceback (most recent call last)

    <ipython-input-78-db7cccdf3863> in <module>()
          1 x.grad.data.zero_()
    ----> 2 out.backward(T.FloatTensor([[1, 1], [1, 1]]), retain_graph=True)
          3 print('x gradient', x.grad)


    /usr/lib/python3.7/site-packages/torch/tensor.py in backward(self, gradient, retain_graph, create_graph)
         91                 products. Defaults to ``False``.
         92         """
    ---> 93         torch.autograd.backward(self, gradient, retain_graph, create_graph)
         94 
         95     def register_hook(self, hook):


    /usr/lib/python3.7/site-packages/torch/autograd/__init__.py in backward(tensors, grad_tensors, retain_graph, create_graph, grad_variables)
         88     Variable._execution_engine.run_backward(
         89         tensors, grad_tensors, retain_graph, create_graph,
    ---> 90         allow_unreachable=True)  # allow_unreachable flag
         91 
         92 


    RuntimeError: invalid gradient at index 0 - expected shape [] but got [2, 2]


### What is ``retain_graph`` doing?

When training a model, the graph will be re-generated for each iteration. Therefore each iteration will consume the graph if the ``retain_graph`` is false, in order to keep the graph, we need to set it be true. 


```python
x = T.randn(2, 2, requires_grad=True) #x is a leaf created by user, thus grad_fn is none
print('x', x)
#define an operation on x
y = 2 * x
#print('y', y)
#define one more operation to check the chain rule
z = y ** 3
out = z.mean()
print('out', out)
out.backward()  #without setting retain_graph to be true, it is alright for first time of backward.
print('x gradient', x.grad)

x.grad.data.zero_()
out.backward() #Now we get complaint saying that no graph is available for tracing back. 
print('x gradient', x.grad)
```

    x tensor([[-0.7452,  1.5727],
            [ 0.1702,  0.7374]], requires_grad=True)
    out tensor(7.7630, grad_fn=<MeanBackward1>)
    x gradient tensor([[ 3.3323, 14.8394],
            [ 0.1738,  3.2623]])



    ---------------------------------------------------------------------------

    RuntimeError                              Traceback (most recent call last)

    <ipython-input-82-80a8d867d529> in <module>()
         12 
         13 x.grad.data.zero_()
    ---> 14 out.backward() #Now we get complaint saying that no graph is available for tracing back.
         15 print('x gradient', x.grad)


    /usr/lib/python3.7/site-packages/torch/tensor.py in backward(self, gradient, retain_graph, create_graph)
         91                 products. Defaults to ``False``.
         92         """
    ---> 93         torch.autograd.backward(self, gradient, retain_graph, create_graph)
         94 
         95     def register_hook(self, hook):


    /usr/lib/python3.7/site-packages/torch/autograd/__init__.py in backward(tensors, grad_tensors, retain_graph, create_graph, grad_variables)
         88     Variable._execution_engine.run_backward(
         89         tensors, grad_tensors, retain_graph, create_graph,
    ---> 90         allow_unreachable=True)  # allow_unreachable flag
         91 
         92 


    RuntimeError: Trying to backward through the graph a second time, but the buffers have already been freed. Specify retain_graph=True when calling backward the first time.


### Wrap up

1. The ``backward()`` function made differentiation very simple
2. For non-scalar ``tensor``, we need to specify ``grad_tensors``
3. If you need to backward() twice on a graph or subgraph, you will need to set ``retain_graph`` to be true. 
4. Note that grad will accumulate from excuting the graph multiple times. 
