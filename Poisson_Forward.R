df = read.csv('Final_Data.csv')
df['Death'] = df['Death_Rate']*df['Population']
df['Death'] = df['Death']/100000
df1 = df[,c(-1)]
df1$Type = as.factor(df1$Type)

predictors = c("Unemployment_Rates","Median.Age","Literacy_Rate",
                     "Conviction.Rates","High_School_Education",
                     "Mental_Health_Issues")
initial_model <- glm(Death ~ Type + Time + Registered_Firearms +
                       Median_Income +  offset(log(Population)), data = df1, family = poisson)

model2 <- glm(Death ~ Type + Time + Registered_Firearms +
                Median_Income +  offset(log(Population)), data = df1, family = poisson)
print(AIC(model2))

for (col in predictors){
  temp_model = update(model2,. ~ . + df1[[col]])
  if(AIC(temp_model) < AIC(model2)){
    print(col)
    print(AIC(temp_model))
  }
}