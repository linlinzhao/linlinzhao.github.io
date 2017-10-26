---
layout: post
title: Understanding backward() in PyTorch
key: 10001
tags: PyTorch Deep-learning
category: Tech
date: 2017-10-21 23:15:00 +08:00
---

<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>

Having heard about the announcement about [Theano](https://github.com/Theano/Theano) from Bengio lab , as a Theano user, I am happy and sad to see the fading of the old hero, caused by many raising stars. Sad to see it is too old to compete with its industrial competitors, and happy to have so many excellent deep learning frameworks to choose from. Recently I started translating some of my old codes to Pytorch and have been really impressed by its dynamic nature and clearness. But at the very beginning, I was very confused by the ``backward()`` function when reading the tutorials and documentations. This motivated me to write this post in order for other Pytorch beginners to ease the understanding a bit. And I'll assume that you already know the [``autograd``](http://pytorch.org/docs/master/autograd.html) module and what a [``Variable``](http://pytorch.org/docs/0.1.12/_modules/torch/autograd/variable.html) is, but are a little confused by definition of ``backward()``.
<!--more-->
First let's recall the gradient computing under mathematical notions. For an independent variable $$x$$ (scalar or vector), the whatever operation on $$x$$ is $$y = f(x)$$. The gradient of $$y$$ w.r.t $$x_i$$s is

$$
\begin{align}\nabla y&=\begin{bmatrix}
\frac{\partial y}{\partial x_1}\\
\frac{\partial y}{\partial x_2}\\
\vdots
\end{bmatrix}
\end{align}.
$$

Then for a specific point of $$x=[X_1, X_2, \dots]$$, we'll get the gradient of $$y$$ on that point as a vector. With these notions in my mind, those things are a bit confusing at the beginning

1. Mathematically, we would say "The gradients of a function w.r.t. the independent variables", whereas the ``.grad`` is attached to the leaf ``Variable``s. In Theano and Tensorflow, the computed gradients are stored separately in a variable. But with a memont of adjustment, it is fairly easy to buy that.

2. The parameter ``grad_variables`` of the function ``torch.autograd.backward(variables, grad_variables=None, retain_graph=None, create_graph=None, retain_variables=None)`` is not straightforward for knowing its functionality.

3. What is ``retain_graph`` doing?


```python
from __future__ import print_function
import torch as T
import torch.autograd
from torch.autograd import Variable
import numpy as np
```

### Simplicity of using ``backward()``


```python
'''
Define a scalar variable, set requires_grad to be true to add it to backward path for computing gradients

It is actually very simple to use backward()

first define the computation graph, then call backward()
'''

x = Variable(T.randn(1, 1), requires_grad=True) #x is a leaf created by user, thus grad_fn is none
print('x', x)
#define an operation on x
y = 2 * x
print('y', y)
#define one more operation to check the chain rule
z = y ** 3
print('z', z)

```

    x Variable containing:
     0.6194
    [torch.FloatTensor of size 1x1]

    y Variable containing:
     1.2388
    [torch.FloatTensor of size 1x1]

    z Variable containing:
     1.9013
    [torch.FloatTensor of size 1x1]



The simple operations defined a forward path $$z=(2x)^3$$, $$z$$ will be the final output ``Variable`` we would like to compute gradient: $$dz=24x^2dx$$, which will be passed to the parameter ``Variables`` in ``backward()`` function.


```python
#yes, it is just as simple as this to compute gradients:
z.backward()
```


```python
print('z gradient', z.grad)
print('y gradient', y.grad)
print('x gradient', x.grad) # note that x.grad is also a Variable
```

    z gradient None
    y gradient None
    x gradient Variable containing:
     9.2083
    [torch.FloatTensor of size 1x1]

The gradients of both $$y$$ and $$z$$ are None, since the function returns the gradient for the leaves, which is $$x$$ in this case. At the very beginning, I was assuming something like this:

    x gradient None
    y gradient None
    z gradient Variable containing:
    128.3257
    [torch.FloatTensor of size 1x1],

since the gradient is for the final output $$z$$. With a blink of thinking, we could figure out it would be practically chaos if $$x$$ is a multi-dimensional vector. ``x.grad`` should be interpreted as the gradient of $$z$$ at $$x$$.

With flexibility in PyTorch's core, it is easy to get the ``.grad`` for intermediate ``Variable``s with help of ``register_hook`` function.

### How do we use ``grad_variables``?

``grad_variables`` should be a list of torch tensors. In default case, the ``backward()`` is applied to scalar-valued function, the default value of ``grad_variables`` is thus ``torch.FloatTensor([1])``. But why is that? What if we put some other values to it?


```python
x = Variable(T.randn(1, 1), requires_grad=True) #x is a leaf created by user, thus grad_fn is none
print('x', x)
#define an operation on x
y = 2 * x
#define one more operation to check the chain rule
z = y ** 3

z.backward(T.FloatTensor([1]), retain_graph=True)
print('Keeping the default value of grad_variables gives')
print('z gradient', z.grad)
print('y gradient', y.grad)
print('x gradient', x.grad)
```

    x Variable containing:
    -0.2782
    [torch.FloatTensor of size 1x1]

    Keeping the default value of grad_variables gives
    z gradient None
    y gradient None
    x gradient Variable containing:
     1.8581
    [torch.FloatTensor of size 1x1]




```python
x.grad.data.zero_()
z.backward(T.FloatTensor([0.1]), retain_graph=True)
print('Modifying the default value of grad_variables to 0.1 gives')
print('z gradient', z.grad)
print('y gradient', y.grad)
print('x gradient', x.grad)
```

    Modifying the default value of grad_variables to 0.1 gives
    z gradient None
    y gradient None
    x gradient Variable containing:
     0.1858
    [torch.FloatTensor of size 1x1]



Now let's set $$x$$ to be a matrix. Note that $$z$$ will also be a matrix.


```python
'''
Try to set x to be column vector or row vector! You'll see different behaviors.

'''

x = Variable(T.randn(2, 2), requires_grad=True) #x is a leaf created by user, thus grad_fn is none
print('x', x)
#define an operation on x
y = 2 * x
#define one more operation to check the chain rule
z = y ** 3

print('z shape:', z.size())

z.backward(T.FloatTensor([1, 0]), retain_graph=True)
print('x gradient', x.grad)

x.grad.data.zero_() #the gradient for x will be accumulated, it needs to be cleared.

z.backward(T.FloatTensor([0, 1]), retain_graph=True)
print('x gradient', x.grad)

x.grad.data.zero_()

z.backward(T.FloatTensor([1, 1]), retain_graph=True)
print('x gradient', x.grad)

```

    x Variable containing:
     1.3689 -1.6859
     1.0549 -0.9156
    [torch.FloatTensor of size 2x2]

    z shape: torch.Size([2, 2])
    x gradient Variable containing:
     44.9719   0.0000
     26.7060   0.0000
    [torch.FloatTensor of size 2x2]

    x gradient Variable containing:
      0.0000  68.2102
      0.0000  20.1196
    [torch.FloatTensor of size 2x2]

    x gradient Variable containing:
     44.9719  68.2102
     26.7060  20.1196
    [torch.FloatTensor of size 2x2]

 We can clearly see the gradients of $$z$$ are computed w.r.t to each dimension of $$x$$, because the operations are all element-wise. ``T.FloatTensor([1, 0])`` will give the gradients for first column of $$x$$.

Then what if we render the output one-dimensional (scalar) while $$x$$ is two-dimensional. This is a real simplified scenario of neural networks.

$$f(x)=\frac{1}{n}\sum_i^n(2x_i)^3$$

$$f'(x)=\frac{1}{n}\sum_i^n24x_i^2$$


```python
x = Variable(T.randn(2, 2), requires_grad=True) #x is a leaf created by user, thus grad_fn is none
print('x', x)
#define an operation on x
y = 2 * x
#print('y', y)
#define one more operation to check the chain rule
z = y ** 3
out = z.mean()
print('out', out)
out.backward(T.FloatTensor([1]), retain_graph=True)
print('x gradient', x.grad)
x.grad.data.zero_()
out.backward(T.FloatTensor([0.1]), retain_graph=True)
print('x gradient', x.grad)
```

    x Variable containing:
     0.0192 -0.1596
    -1.1868 -0.1631
    [torch.FloatTensor of size 2x2]

    out Variable containing:
    -3.3603
    [torch.FloatTensor of size 1]

    x gradient Variable containing:
     0.0022  0.1528
     8.4515  0.1596
    [torch.FloatTensor of size 2x2]

    x gradient Variable containing:
     0.0002  0.0153
     0.8451  0.0160
    [torch.FloatTensor of size 2x2]

### What is ``retain_graph`` doing?

When training a model, the graph will be re-generated for each iteration. Therefore each iteration will consume the graph if the ``retain_graph`` is false, in order to keep the graph, we need to set it be true.


```python
x = Variable(T.randn(2, 2), requires_grad=True) #x is a leaf created by user, thus grad_fn is none
print('x', x)
#define an operation on x
y = 2 * x
#print('y', y)
#define one more operation to check the chain rule
z = y ** 3
out = z.mean()
print('out', out)
out.backward(T.FloatTensor([1]))  #without setting retain_graph to be true, this gives an error.
print('x gradient', x.grad)
x.grad.data.zero_()
out.backward(T.FloatTensor([0.1]))
print('x gradient', x.grad)
```

    x Variable containing:
     0.3358 -1.0588
    -0.4989 -0.9955
    [torch.FloatTensor of size 2x2]

    out Variable containing:
    -4.5198
    [torch.FloatTensor of size 1]

    x gradient Variable containing:
     0.6765  6.7261
     1.4936  5.9466
    [torch.FloatTensor of size 2x2]


    ---------------------------------------------------------------------------

    RuntimeError                              Traceback (most recent call last)

    <ipython-input-27-0ae5673f71fa> in <module>()
         11 print('x gradient', x.grad)
         12 x.grad.data.zero_()
    ---> 13 out.backward(T.FloatTensor([0.1]))
         14 print('x gradient', x.grad)


    /usr/local/lib/python2.7/dist-packages/torch/autograd/variable.pyc in backward(self, gradient, retain_graph, create_graph, retain_variables)
        154                 Variable.
        155         """
    --> 156         torch.autograd.backward(self, gradient, retain_graph, create_graph, retain_variables)
        157
        158     def register_hook(self, hook):


    /usr/local/lib/python2.7/dist-packages/torch/autograd/__init__.pyc in backward(variables, grad_variables, retain_graph, create_graph, retain_variables)
         96
         97     Variable._execution_engine.run_backward(
    ---> 98         variables, grad_variables, retain_graph)
         99
        100


    /usr/local/lib/python2.7/dist-packages/torch/autograd/function.pyc in apply(self, *args)
         89
         90     def apply(self, *args):
    ---> 91         return self._forward_cls.backward(self, *args)
         92
         93


    /usr/local/lib/python2.7/dist-packages/torch/autograd/_functions/basic_ops.pyc in backward(ctx, grad_output)
        207     def backward(ctx, grad_output):
        208         if ctx.tensor_first:
    --> 209             var, = ctx.saved_variables
        210             return grad_output.mul(ctx.constant).mul(var.pow(ctx.constant - 1)), None
        211         else:


    RuntimeError: Trying to backward through the graph a second time, but the buffers have already been freed. Specify retain_graph=True when calling backward the first time.


### Wrap up

1. The ``backward()`` function made differentiation very simple. It provides much flexibility for some uncommon differentiation needs.
2. For non-scalar ``Variable``s, we need to specify ``grad_variables``.
3. If you need to backward() twice on a graph or subgraph, you will need to set ``retain_graph`` to be true, since the computation of graph will consume itself if it is false.
4. Remember that gradient for ``Variable`` will be accumulated, zero it if do not need accumulation.

### Some discussions about ``backward()`` from [PyTorch](https://discuss.pytorch.org/)

[clarification-using backward on non scalars](https://discuss.pytorch.org/t/clarification-using-backward-on-non-scalars/1059)

[How the backward works for torch variable](https://discuss.pytorch.org/t/how-the-backward-works-for-torch-variable/907)

[understanding backward of variables for complex operations](https://discuss.pytorch.org/t/understanding-backward-of-variables-for-complex-operations/3569)

[multiple calls to backward with requires grad true](https://discuss.pytorch.org/t/multiple-calls-to-backward-with-requires-grad-true/1688/7)

[why need implementation of backward method](https://discuss.pytorch.org/t/why-need-implementation-of-backward-method/9013)

[what exactly does retain-variables true in loss backward do](https://discuss.pytorch.org/t/what-exactly-does-retain-variables-true-in-loss-backward-do/3508/5) Note that ``retain_variables`` will be replaced with ``retain_graph``!

[which is freed which is not](https://discuss.pytorch.org/t/which-is-freed-which-is-not/8636/3)

[how to use torch autograd backward when variables are non scalar](https://discuss.pytorch.org/t/how-to-use-torch-autograd-backward-when-variables-are-non-scalar/4191)
