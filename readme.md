## Learn neural nets in R

### Executive summary

The purpose of this project is to learn how to make neural networks models in 
`R`. The project covers the programming part only. This project does not cover
the concepts behind neural networks. You can see a good explanation of how the
neural nets work in the [StatQuest] video. 

There are two ideas that motivate the learning of neural networks. The first is
to find out if it is possible to improve my earlier projects with more 
sophisticated tools. The second is to find new area of interest in the data 
science.

This project has *4* parts:

- building basic models with `neuralnet` package;  
- tuning of models built with `neuralnet` package;  
- building models with cross validation in `caret` package;  
- tuning of `caret` based models;  

The files in this repo corresponding to the parts of the project:

| filename                    | part of the project         |
|-----------------------------|-----------------------------|
| 01_neuralnet1.R             | simple neuralnet classifier |
| 02_neuralnet2.R             | simple neuralnet regression |
| 03_neuralnet3.R             | medium neuralnet classifier |
| 04_neuralnet4.R             | another classifier	    |
| 05_height_predictor.R       | predict height from gender  |
| 06_breas_cancer.R           | basic NN comparison         |
| 07_adaptive_resample.R      | adaptive resampling         |
| 08_class_imbalances.R       | resampling                  |
| 09_subsampling_resampling.R | resampling                  |
| 10_cereals_nn.R             | simple neuralnet regression |
| 11_regression_tuning.R      | full regression tuning      |

Sources used in scripts:

- [x] link to [simple NN classifier] for `neuralnet1.R`;  
- [x] link to [simple NN regression] for `neuralnet2.R`;  
- [x] link to [manual neuralnet package] for `neuralnet3.R`;  
- [x] link to [customer classifier] for `neuralnet4.R`;  

Sources non-specific to scripts:

- [x] part 01: [deep learning overview] for all NN;  
- [x] part 02: [machine learning] for recommendation systems;  
- [x] part 03: [intro into deep learning] for all NN;  
- [x] part 04: [deep learning] book;  
- [x] part 05: [adaptive resample] in caret;  
- [x] part 06: [class imbalances] in caret;  
- [x] part 07: [neural networks] in caret;  
- [x] part 08: [Mikhail Pankov] github repo;
- [x] part 09: [vidhya blog] basic NN;  
- [x] part 10: [finnstats] blog;  
- [x] part 11: [stock price 1] part;  
- [x] part 12: [stock price 2] part;  
- [x] part 13: [stock price 3] part;  

### Architecture

**Multilayer perceptron** is a *feed-forward* artificial network that maps the
sets of inputs with a set of appropriate outputs. It consists of multiple layers
of nodes with each layer fully connected to the next one. It uses the non-linear
activation function and backpropagation for training. *MLP* can distinguish data
with non-linear dependencies.

**Recurrent neural network** is a network where units' connections create a
directed cycle. *RNN* exhibits dynamic temporal behavior. It can use internal
memory to process inputs. An example of such network is *LSTM* network.

**Convolutional neural network** is a network where connections between neurons
are organized in patterns, inspired by animal visual cortex. This way *CNN* is
reacting to overlapping regions tiling the visual field.

### Data preprocessing

`Neuralnet` package requires numeric inputs. It works poorly with factor vars.
Activation function requires scaling the data. Data preprocessing algorithm:

1. split numeric and factor variables;  
2. scale numeric variables using your method of choice;  
3. convert factor variables to dummy variables -- one hot encoding;  
4. check if dummy variable column names are consistent with `R` -- see below;  
5. convert response to numeric -- *important* for classification;  
6. split the data into training and testing;  

Neural network uses activation functions. Activation functions outputs are in a
range *[-1; +1]* always. The function will scale the data on every iteration if
you have not scaled it prior to training the neural net. Since this is not very
effective, the best way is to scale the variables upfront.

There is no difference which scaling method you use. Theoretically it is not
going to affect the result of the modeling. The rule of thumb here is to use
the method depending on if you need to go back to original values in order to
predict the response variable. If yes, then probably the `min - max` method is
the best choice.

Check if column names contain signs not appropriate for use in `R` -- such
may be `-` sign. It is better to stick with traditional conventions and also
change the `.` for the `_` sign in the name of the columns -- this way we do
not confuse them with `S3` methods.

### Neuralnet tuning params

Neural network has *3* basic tuning params and *3* advanced tuning features.
Basic tuning params include: algorithm, learning rate limit, learning rate 
factor. Advanced tuning parameters: threshold, stepmax, startweights.

 - `algorithm`              the type of backpropagation to compute the network  
 - `learning rate limit`    a vector with lowest and highest limit of *LR*  
 - `learning rate factor`   a vector of multiplication for *LR*  
 - `threshold`              a size of an error when *NN* stops learning  
 - `stepmax`                a length of training session  
 - `startweights`           a vector with starting values for the weights  

`Neuralnet` by default uses `rprop+` algorithm for backpropagation. This
algorithm's tuning parameters are learning rate limit and learning rate
factor. Perform full grid search to setup learning rate parameters. Here
the recommendation is to not use too high min learning rate limit, as this
might stop model training.
 
### Adaptive resampling

We use grid search to find the best combination of tuning parameters. Searching
the full grid is a time consuming process. There is an alternative to full grid
search, which is to resample from a set of parameters that are in the nearest
neighborhood of the optimal settings.

Library `caret` allows adaptive resampling using **4** additional parameters:

- `min` -- minimum number of resamples used for each tuning parameter; defaults 
to **5** -- increase of this parameter slows down the algorithm, but increases
the likelihood of finding a good model;  
- `alpha` is a confidence level, which removes parameter settings; impact is
unknown;  
- `method` is a choice of two: *gls* for linear model, *BT* for a Bradley-Terry
model; the latter is useful when you expect $ROC ~ 1$;  
- `complete` a logical value: *T* -- if you want the trace of how the algorithm
found the best set of parameters; *F* -- if you want the results only;

### Subsampling for class imbalances

Class imbalance leads to model overfitting. There is an approach to resolve a 
class imbalance problem by subsampling the training data. There are **3** ways
to sample the training data in this approach:

- `down-sampling` -- randomly select observations from major class until its
the same size as minor class; this way leads to potential loss of valuable
patterns of the data;  

- `up-sampling` -- randomly select with replacement an observations from the 
minority class until its size is the same as the majority class;

- `hybrid` -- downsize the majority class and synthesize new data points in the
minority class;

**Never apply** any of this techniques to the **test set** -- you want the test
set to contain the original weights of each class. There are **2** pitfalls
which come along any of those ways:

1. class imbalance may appear during resampling when you tune a model;  
2. subsampling may increase model uncertainty -- we are not sure if a model
behavior follows the development of real event;

The **alternative** is to include the subsampling inside of the usual resampling
procedure. This method has its own drawbacks:

- there is no obvious answer if you have to do the subsampling before or after
the pre-processing; the default behavior is to subsample prior to pre-process;  

- sparsely represented factor categories turn into zero-variance predictors;  
- tuning the length of the model may end up in sub-optimal parameters;  

### Conclusions

Training a neural network in R using `neuralnet` package algorithm:

1. neural network accepts *numeric* inputs only;  
2. scale numeric variables;  
3. convert factor variables to dummy variables;  
4. convert response to numeric;  
5. split data to training and testing;  
6. resample the training data for class imbalances;  
7. split training set to training and validation;  
7. train neural net using a number of parameters:  
        - `algorithm`  
        - `learning rate limit`  
        - `learning rate factor`    
        - `threshold`   
        - `stepmax`              
        - `startweights`  
8. use grid search to find best set of parameters.  

**Avoid** activation functions: `tanh`, `sigmoid`  
**Use** activation function: `ReLU`  

Manual tuning:

- increase hidden layers will increase capacity;  
- decrease in regularization will increase capacity;  
- decrease of dropout will increase capacity;  
- increase number of nodes will increase capacity;  

The most **important** tuning parameter is **learning rate** -- tune it first;


<br />
<br />

[StatQuest]: https://www.youtube.com/watch?v=CqOfi41LfDw&list=PLblh5JKOoLUIxGDQs4LFFD--41Vzf-ME1
[simple NN classifier]: https://www.r-bloggers.com/2018/10/neuralnet-train-and-test-neural-networks-using-r/
[simple NN regression]: https://www.r-bloggers.com/2015/09/fitting-a-neural-network-in-r-neuralnet-package/
[manual neuralnet package]: https://rdrr.io/cran/neuralnet/man/neuralnet-package.html
[customer classifier]: http://www.learnbymarketing.com/tutorials/neural-networks-in-r-tutorial/
[deep learning overview]: https://www.r-bloggers.com/2017/02/deep-learning-in-r-2/
[machine learning]: https://rafalab.github.io/dsbook/introduction-to-machine-learning.html
[intro into deep learning]: https://koalaverse.github.io/machine-learning-in-R/deep-neural-networks.html
[deep learning]: https://srdas.github.io/DLBook/
[adaptive resample]: https://topepo.github.io/caret/adaptive-resampling.html
[class imbalances]: https://topepo.github.io/caret/subsampling-for-class-imbalances.html
[neural networks]: https://topepo.github.io/caret/train-models-by-tag.html#neural-network
[Mikhail Pankov]: https://github.com/Mishkail/NeuralNetR
[vidhya blog]: https://www.analyticsvidhya.com/blog/2017/09/creating-visualizing-neural-network-in-r/
[finnstats]: https://www.r-bloggers.com/2021/04/deep-neural-network-in-r/
[stock price 1]: https://stackoverflow.com/questions/38010806/predicting-price-using-previous-prices-with-r-and-neural-networks-neuralnet
[stock price 2]: https://github.com/niki864/Simple-Stock-Predictor-xgboost-knn-
[stock price 3]: https://stats.stackexchange.com/questions/44962/r-neural-net-training-and-prediction


