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

| filename     | part of the project         |
|--------------|-----------------------------|
| neuralnet1.R | simple neuralnet classifier |
| neuralnet2.R | simple neuralnet regression |
| neuralnet3.R | medium neuralnet classifier |
| neuralnet4.R | another classifier			 |


Sources used in scripts:

- [x] link to [simple NN classifier] for `neuralnet1.R`;  
- [x] link to [simple NN regression] for `neuralnet2.R`;  
- [x] link to [manual neuralnet package] for `neuralnet3.R`;  
- [x] link to [customer classifier] for `neuralnet4.R`;  

Sources non-specific to scripts:

- [ ] part 01: [deep learning overview] for all NN;  
- [ ] part 02: [machine learning] for recommendation systems;  
- [ ] part 03: [intro into deep learning] for all NN;  
- [ ] part 04: [deep learning] book;  
- [ ] part 05: [adaptive resample] in caret;  
- [ ] part 06: [class imbalances] in caret;  
- [ ] part 07: [neural networks] in caret;  
- [ ] part 08: [Mikhail Pankov] github repo;
- [ ] part 09: [vidhya blog] basic NN;  
- [ ] part 10: [finnstats] blog;  
- [ ] part 11: [stock price 1] part;  
- [ ] part 12: [stock price 2] part;  
- [ ] part 13: [stock price 3] part;  


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

Neural network has *3* basic tuning params and *5* advanced tuning features.
Basic tuning params include: algorithm, learning rate limit, learning rate 
factor. Advanced tuning parameters: threshold, stepmax, startweights, 
lifesign and lifesign step.









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


