install.packages('tidyverse')
install.packages('dagitty')
install.packages('ggdag')
install.packages('DoubleML')
install.packages('mlr3')
install.packages('mlr3learners')
install.packages('reticulate')
install.packages("xgboost")

# Map the Causal Theory

library(ggdag)
library(ggplot2)
## Theoretical Model
## Education Causes Income, but Ability affects both!
project_dag <- dagify(
  Income ~ Education + Ability,
  Education ~ Ability,
  exposure = 'Education',
  outcome = 'Income'
)
ggdag_status(project_dag) +
  theme_dag() +
  ## Make the lines (edges) thicker and the arrows larger
  geom_dag_edges(edge_width = 1.5, 
                 arrow_directed = grid::arrow(length = grid::unit(15, 'pt'), type = 'closed')) +
  ## Make the nodes (circles) bigger
  geom_dag_node(size = 27) +
  ## Make the text inside white and bold
  geom_dag_text(color = 'white', size = 4, fontface = 'bold') +
  ggtitle('Causal Theory: The Effect of Education on Income',
          subtitle = 'Bolded Arrows for Presentation Clarity')

# Simulate Complex Data

set.seed(2025)
n <- 5000
## Ability is a hidden complex factor
ability <- rnorm(n, 100, 15)
## Education depends on ability in a non-linear way
education <- 10 + 0.05 * (ability^1.2) + rnorm(n, 0, 2)
## Income is the outcome we want to study
income <- 2.5 * education + 0.1 * (ability^1.5) + rnorm(n, 0, 10)
df <- data.frame(education, income, ability)

# Set up the Deep Learning Model

library(DoubleML)
library(mlr3)
library(mlr3learners)
## Initialize the data
dml_data = double_ml_data_from_data_frame(df, y_col = 'income', d_cols = 'education', x_cols = 'ability')
## Set up the Deep Learning Learners(using the 'mlr3' framework)
## Using a Gradient Boosting approach
learner_main = lrn('regr.xgboost')
learner_nuisance = lrn('regr.xgboost')
## Create the Double ML Model
dml_model = DoubleMLPLR$new(dml_data, learner_main, learner_nuisance)
## Train the model
dml_model$fit()
## Checking results
print(dml_model)
