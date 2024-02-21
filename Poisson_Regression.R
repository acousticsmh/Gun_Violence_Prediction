df = read.csv('Final_Data.csv')
df['Death'] = df['Death_Rate']*df['Population']
df['Death'] = df['Death']/100000
df1 = df[,c(-1)]
df1$Type = as.factor(df1$Type)

initial_model <- glm(Death ~ Type + Time + Registered_Firearms +
                     Median_Income +  offset(log(Population)), data = df1, family = poisson)

final_model <- glm(Death ~ Type + Time + Registered_Firearms +
                     Median_Income + Unemployment_Rates + Median.Age + Literacy_Rate
                   + Conviction.Rates + High_School_Education
                  +  offset(log(Population)), data = df1, family = poisson)

all_model <- glm(Death ~ Type + Time + Registered_Firearms +
                       Median_Income + Unemployment_Rates + Median.Age + Literacy_Rate
                     + Conviction.Rates + High_School_Education
                     + Mental_Health_Issues +  offset(log(Population)), data = df1, family = poisson)

cat("Data used for Forward Stepwise Regression",'\n')

cat("Initial Model ",AIC(initial_model),'\n')
cat("Final Model ",AIC(final_model),'\n')
cat("Model with all Variables ",AIC(all_model),'\n','\n')

cat("Deviance for Assessing performance",'\n')

cat("Initial Model ",deviance(initial_model),'\n')
cat("Final Model ",deviance(final_model),'\n')
cat("Model with all Variables ",deviance(all_model),'\n','\n')

cat("Goodness of Fit",'\n')
cat("Initial Model",'\n')
with(initial_model, cbind(res.deviance = deviance, df = df.residual,
                          p = 1- pchisq(deviance, df.residual)))
cat("Final Model",'\n')
with(final_model, cbind(res.deviance = deviance, df = df.residual,
                          p = 1- pchisq(deviance, df.residual)))

cat("Model with all variables",'\n')
with(all_model, cbind(res.deviance = deviance, df = df.residual,
                        p = 1- pchisq(deviance, df.residual)))

