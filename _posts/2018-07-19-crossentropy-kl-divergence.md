---
layout: post
comment: true
title: Why can cross entropy be loss function?
key: 10006
tags: probability, KL-divergence, entropy
category: machine learning
date: 2018-07-19
---


>This post is an expansion of my answer on [Cross Validated](https://stats.stackexchange.com/a/357974/41910)

Intuitively we can take Kullbach-Leibler(KL) divergence which quantifies the distance between two distributions as the error function, but why the cross entropy arises for classification problems? For answering it, let us first recall that entropy is used to measure the uncertainty of a system, which is defined as 
<!--more-->
$$
\begin{equation}
	S(v)=-\sum_ip(v_i)\log p(v_i)\label{eq:entropy},
\end{equation}
$$

for $$p(v_i)$$ as the probabilities of different states $$v_i$$ of the system. From an information theory point of view, $$S(v)$$ is the amount of information is needed for removing the uncertainty. For instance, the event A ``I will die eventually`` is almost certain (maybe we can solving the aging problem for word ``almost``), therefore it has low entropy which requires only the information of ``might solve the aging problem`` to make it certain. However, the event B ``The president will die in 50 years`` is much more uncertain than A, thus it needs more information to remove the uncertainties.

Now look at the definition of KL divergence between events A and B

$$
\begin{equation}
	D_{KL}(A\parallel B) = \sum_ip_A(v_i)\log p_A(v_i) - p_A(v_i)\log p_B(v_i)\label{eq:kld}, 
\end{equation}
$$

where the first term of the right hand side is the entropy of event A, the second term can be interpreted as the expectation of event B in terms of event A. And the $$D_{KL}$$ describes how different B is from A from the perspective of A.   

To relate cross entropy to entropy and KL divergence, we need to reformalize the cross entropy in terms of events A and B as

$$
\begin{equation}
	H(A, B) = -\sum_ip_A(v_i)\log p_B(v_i)\label{eq:crossentropy}. 
\end{equation}
$$

From the definitions, we can easily see

$$
\begin{equation}
	H(A, B) = D_{KL}(A\parallel B)+S_A\label{eq:entropyrelation}. 
\end{equation}
$$

From the relation, the fact that if $$S_A$$ is a constant, then minimizing $$H(A, B)$$ is equivalent to minimizing $$D_{KL}(A\parallel B)$$ can answer why the cross entropy error function arises from the likelihood function of the model. 
A further question follows naturally as how the entropy can be a constant. In a machine learning task, we start with a dataset (denoted as $$P(\mathcal D)$$) which represent the problem to be solved, and the learning purpose is to make the model estimated distribution (denoted as $$P(model)$$) as close as possible to true distribution of the problem (denoted as $$P(truth)$$). 
$$P(truth)$$ is unknown and represented by $$P(\mathcal D)$$. Therefore in an ideal world, we expect

$$
\begin{equation}
	P(model)\approx P(\mathcal D) \approx P(truth)
\end{equation}
$$

and minimize $$D_{KL}(P(\mathcal D)\parallel P(model))$$.

Luckily, in practice $$\mathcal D$$ is given, which means its entropy $$S(D)$$ is fixed as a constant. Now we see that the equivalence of minimizing cross entropy and KL divergence in a classification problem for given dataset, which shows the cross entropy can be the proper error function.   


