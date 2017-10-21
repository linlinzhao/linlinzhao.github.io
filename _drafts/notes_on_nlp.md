###Simple way

The simplest way of dealing with text is building a frequency matrix where the rows are words, the columns are the articles, and entries are the frequencies of the words in the corresponding articles. If SVD or non-negative matrix factorization is applied on such matrix, $U$ matrix the reduced-dimension representation of the columns, i.e., the articles, $V$ matrix is for words. Further, if we would like to visualize the $U$ or $V$ matrix, techniques such as tSNE can be applied to project the matrices to lower dimension by some kind of recombination and transformation. The columns of $U$ are the bases of articles, the rows of $V$ are the bases of words.

###Word2vec and GloVe

They are based on the idea of Co-occurence matrix in order to capture the context information. A window size is required to construct such a matrix, which is a hyper-parameter need to be tuned during learning. The window length could be somehow interpreted as a correlation length. With a fixed window size, the corpus is transformed a large co-occurrence matrix. 

###Continuous bag of words and skip-gram

CBOW predicts the current word according to its context while skip-gram predicts the current word's context. 

The core idea of CBOW is to use neural network to predict the probability of the current word given its context, i.e. $p(w|c)$, noting that the output layer is softmax which needs a normalization term which summarize all words. The natural choice of objective function for training then becomes the maximum likelihood.  

###Problem in practice
Usually the size corpus is very large, which makes the normalization term intractable to calculate in practice. To resolve this problem, researcher came up the idea of negative sampling.

The idea here is to treat the problem as a classification problem.

	-Given a fixed length window, we can construct a set $D$ of pairs (w, c) in the text, i.e. the word and its context truly appear in the text
	-Similarly, we can also construct another set $D'$ of pairs (w, c) which are not in the text.
	-Then the classification problem becomes to classify if the given pair (w, c) shows up the text. 
 
