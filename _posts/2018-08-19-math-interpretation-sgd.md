---
layout: post
comment: true
title: Mathematical interpretation of why Gradient descent works
key: A10007
tags: optimization gradient-descent
category: optimization
date: 2018-08-19
---



For minimizing a differentiable multivariable function $$f(\mathbf x)$$ with initial value of $$\mathbf x_0$$, the fastest decreasing would be the direction of negative gradient of $$f(x)$$ since its gradient points to fastest ascending direction. The updating rule 
<!--more-->

$$
\begin{equation}
\mathbf	x_{t+1} = \mathbf x_t - \eta\nabla f(\mathbf x_t), t=1,2~\cdots
\end{equation}
$$

with sufficiently small $$\eta$$ leads to $$f(\mathbf x_{t+1})<f(\mathbf x_t)$$. 
The scalar constant $$\eta$$ is the step size determining how far the updating moves in the negative gradient direction, which is usually called learning rate in machine learning model training. 

### But, why $$\eta$$ has to be small?

To gain the mathematical interpretation, assume the general context of 

$$
\begin{equation}
	\min_{\mathbf x}f(\mathbf x), \mathbf x\in \mathcal R^m
\end{equation}
$$

with initial condition $$\mathbf x=\mathbf x_0$$. 

The goal of first updating is to find $$\mathbf x_1=\mathbf x_0+\Delta\mathbf x$$ such that 

$$
\begin{equation}
	f(\mathbf x_1) \le f(\mathbf x_0), 
\end{equation}
$$

where $$\Delta\mathbf x$$ is the updating vector.

First we approximate $$f(\mathbf x_1)$$ with the first-order Taylor expansion as 

$$
\begin{equation}
	f(\mathbf x_1) = f(\mathbf x_0 + \Delta\mathbf x)=f(\mathbf x_0)+\Delta\mathbf x^T\nabla f(\mathbf x_0), 
\end{equation}
$$

which leads to 

$$
\begin{equation}
	f(\mathbf x_1) - f(\mathbf x_0)=\Delta\mathbf x^T\nabla f(\mathbf x_0). 
\end{equation}
$$

Now to ensure the semi-negative definite of $$f(\mathbf x_1) - f(\mathbf x_0)$$, we can simply choose 

$$
\begin{equation}
	\Delta\mathbf x = -\eta\nabla f(\mathbf x_0)
\end{equation}
$$

and then we have

$$
\begin{equation}
	f(\mathbf x_1) - f(\mathbf x_0)=-\eta\|\nabla f(\mathbf x_0)\|^2 \le 0, 
\end{equation}
$$

for some scalar constant $$\eta$$, and $$\|\nabla f(\mathbf x_0)\|^2=0$$ if and only if $$f(\mathbf x_0)$$ is already the minimum. 


To sum up and generalize to step $$t$$, the updating rule

$$
\begin{equation}
	\mathbf x_{t+1} = \mathbf x_t - \eta \nabla f(\mathbf x_t)
\end{equation}
$$

drives the searching towards the minimum given that the proper value of $$\eta$$ can ensure that $$x_{t+1}$$ is close enough to $$x_t$$ such that first-order approximate is a valid approximate with tolerable error.  

