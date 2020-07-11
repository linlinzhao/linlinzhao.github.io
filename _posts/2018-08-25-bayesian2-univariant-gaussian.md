---
layout: post
comment: true
title: Bayesian basics II - Inference for univariate Gaussian, Maximum a Posteriori vs Maximum likelihood
key: 10009
tags: probability bayesian inference
category: stats
date: 2018-08-25
---

*In an earlier [post](https://linlinzhao.com/probability/2015/07/12/Bayesian-basics1-way-of-reasoning.html), we get to know the concept of Bayesian reasoning. In this post we show Bayesian way of inferring basic statistics and briefly compare the Maximum a Posteriori to Maximum likelihood.*

As simple example of Bayesian inference in action, we estimate the expectation $$\mu$$ of univariate Gaussian with known variance $$\sigma^2$$ as an example. 
Assuming $$N$$ observations as $$X=(x_1,\cdots, x_N)$$, maximum likelihood estimate gives $$\mu=\sum_kx_k/N=\bar X$$, of which the calculation details are neglected. Now we focus on Bayesian estimate. 

<!--more-->
Since $$X$$ is Gaussian distributed $$p(X\mid \mu)\sim \mathcal N(\mu, \sigma^2)$$, the likelihood function is

$$
\begin{equation}
p(x\mid \mu)=\prod_{k=1}^N p(x_k\mid \mu)=(2\pi\sigma^2)^{\frac{N}{2}}\exp\left (-\frac{1}{2}\sum_{k=1}^N(\frac{x_k-\mu}{\sigma})^2\right).
\end{equation}
$$

The conjugate prior can be $$p(\mu)\sim \mathcal N(\mu_0, \sigma_0^2)$$, specifically 

$$
\begin{equation}
p(\mu)=(2\pi \sigma_0^2)^{-1/2}\exp\left (-\frac{1}{2}(\frac{\mu-\mu_0}{\sigma_0})^2\right ).
\end{equation}
$$

Then applying Bayes rule yields the posterior

$$
\begin{align}
\nonumber p(\mu\mid x)&=\frac{p(x\mid \mu)p(\mu)}{\int_u p(x\mid \mu)p(\mu)d\mu}\\
 &=c\exp\left(-\frac{1}{2}\left((\frac{N}{\sigma^2}+\frac{1}{\sigma_0^2})\mu^2-2(\frac{1}{\sigma^2}\sum_{k=1}^Nx_k+\frac{\mu_0}{\sigma_0^2})\mu\right)\right)\label{p1},
\end{align}
$$

where $$c$$ is a constant. The quadratic form of $$\mu$$ in the exponential function makes us safe to assume $$p(\mu\mid x)\sim \mathcal N(\mu_N, \sigma_N^2)$$ which gives

$$
\begin{equation}
p(\mu\mid x)=(2\pi \sigma_N^2)^{-1/2}\exp\left (-\frac{1}{2}(\frac{\mu-\mu_N}{\sigma_N})^2\right )=\alpha \exp\left(-\frac{1}{2}\left(\frac{\mu^2}{\sigma_N2}-\frac{2\mu_N}{\sigma_N^2}\right)\right).
\end{equation}
$$

Comparing two expressions for posterior $$p(\mu\mid x)$$, we have

$$
\begin{align*}
\sigma_N^2&=\frac{\sigma^2\sigma_0^2}{N\sigma_0^2+\sigma^2}\\
\mu_N&=\frac{\sigma_0^2\sum_kx_k}{N\sigma_0^2+\sigma^2}+\frac{\sigma^2\mu_0}{N\sigma_0^2+\sigma^2}.
\end{align*}
$$

Then using the posterior we can estimate $$\mu$$ 

$$
\begin{equation}
\hat \mu=\int_{-\infty}^{\infty}\mu p(\mu\mid x)d\mu=\mu_N=\frac{\sigma_0^2\sum_kx_k}{N\sigma_0^2+\sigma^2}+\frac{\sigma^2\mu_0}{N\sigma_0^2+\sigma^2}.
\end{equation}
$$

Notice that as the data size $$N$$ is getting larger, the Bayesian estimation is getting closer to the estimation of maximum likelihood. When our data size is small, the prior of Bayesian estimation drives the parameter away from its maximum likelihood estimation for avoiding extreme cases (e.g. over-fitting). 

In theory and general, after posterior is obtained, the prediction of novel data can be viewed as the ensemble of all possible parameters. In the case of Bayesian learning, we can make prediction for output $$y$$ given new input $$x$$ as

$$
\begin{equation}
p(y\mid x, D)=\int p(y\mid x, w)p(w\mid D)dw,
\end{equation}
$$

where $$p(w\mid D)$$ is the posterior with $$w$$ the parameter vector and $$D$$ the training data. 
This is the so-called full Bayesian approach where the difficulty for application lies on the estimation of the integral. 
Alternatively Maximum a Posteriori (MAP) estimate is utilized widely for practical purposes, which is a point-wise estimate and gives the most probable parameter set given the training data. The MAP usually works better than maximum likelihood since a suitable prior can render the fitting curve smoother thanks to its regularization on complex models.

