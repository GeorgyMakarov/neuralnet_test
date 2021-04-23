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


Sources:

- [simple NN classifier] for `neuralnet1.R`;  
- [simple NN regression] for `neuralnet2.R`;  
- [manual neuralnet package] for `neuralnet3.R`;  
- [customer classifier] for `neuralnet4.R`;  


<br />
<br />

[StatQuest]: https://www.youtube.com/watch?v=CqOfi41LfDw&list=PLblh5JKOoLUIxGDQs4LFFD--41Vzf-ME1
[simple NN classifier]: https://www.r-bloggers.com/2018/10/neuralnet-train-and-test-neural-networks-using-r/
[simple NN regression]: https://www.r-bloggers.com/2015/09/fitting-a-neural-network-in-r-neuralnet-package/
[manual neuralnet package]: https://rdrr.io/cran/neuralnet/man/neuralnet-package.html
[customer classifier]: http://www.learnbymarketing.com/tutorials/neural-networks-in-r-tutorial/

