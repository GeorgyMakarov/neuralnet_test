# Link: http://www.learnbymarketing.com/tutorials/neural-networks-in-r-tutorial/

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(caret))
suppressPackageStartupMessages(library(neuralnet))

mydata = data.table::fread("bank.csv", stringsAsFactors = T)
mydata = as.data.frame(mydata)


# Split numeric and factor variables. This approach helps to scale the numeric
# variables and convert factors to dummy variables.
data_num = 
    mydata %>% 
    select(age, balance, day, duration, 
           campaign, pdays, previous)

f_cols  = setdiff(colnames(mydata), colnames(data_num))
data_fc = mydata %>% select(f_cols)
rm(f_cols)


# Scale numeric variables. Use max - min method because it is easy to go back
# to original data if you need it.
maxs   = apply(data_num, 2, max)
mins   = apply(data_num, 2, min)
data_num = as.data.frame(scale(x      = data_num, 
                               center = mins, 
                               scale  = maxs - mins))


# Convert factor variables to one hot encoding variables using `caret` package.
# Do not convert the response variable -- keep it separately.
resp_y  = data_fc$y
data_fc = data_fc %>% select(-y)
dummies = dummyVars(formula = ~., data = data_fc)
dummies = as.data.frame(predict(dummies, newdata = data_fc))


# Make new dataset with from response, numeric and dummy variables
mydata = cbind(resp_y, data_num, dummies)
rm(data_fc, data_num, dummies, resp_y)


# Check if column names contain signs not appropriate for use in `R` -- such
# may be '-' sign. It is better to stick with traditional conventions and also
# change the '.' for the '_' sign in the name of the columns -- this way we do
# not confuse them with `S3` methods.
names(mydata) = gsub(x = names(mydata), pattern = "-", replacement = "_")
names(mydata) = gsub(x = names(mydata), pattern = "\\.", replacement = "")