install.packages("dplyr")
library(dplyr)

url_variables <- "features.txt"
var_names <- read.table(url_variables,  stringsAsFactors=TRUE)

test_setY_url <- "./test/y_test.txt"
test_setX_url <- "./test/X_test.txt"
test_setSubj_url <- "./test/subject_test.txt"

test_setY <- read.table(test_setY_url,  stringsAsFactors=FALSE)
test_setX <- read.table(test_setX_url,  stringsAsFactors=FALSE)
test_setSubj <- read.table(test_setSubj_url,  stringsAsFactors=FALSE)

train_setY_url <- "./train/y_train.txt"
train_setX_url <- "./train/X_train.txt"
train_setSubj_url <- "./train/subject_train.txt"

train_setY <- read.table(train_setY_url,  stringsAsFactors=FALSE)
train_setX <- read.table(train_setX_url,  stringsAsFactors=FALSE)
train_setSubj <- read.table(train_setSubj_url,  stringsAsFactors=FALSE)


completesetActivity<-rbind(test_setY,train_setY)
completeset<-rbind(test_setX,train_setX)
completesubjects<-rbind(test_setSubj,train_setSubj)

mean_and_std_vector<-grep("mean\\(|std\\(", var_names[,2], value=F)
vector_names<-grep("mean\\(|std\\(", var_names[,2], value=TRUE)


filteredset<-subset(completeset, select=mean_and_std_vector)

activity_labels<-read.table("activity_labels.txt",  stringsAsFactors=FALSE)
activity_labels<-select(activity_labels, ActNum=V1, Activity=V2)
completesetActivity<-select(completesetActivity, ActNum=V1)
completesubjects<-select(completesubjects, Subjects=V1)


totalset<-cbind(completesetActivity,completesubjects,filteredset)

totalset$tempId <- 1:nrow(totalset)
rtotal<-merge(activity_labels,totalset,by="ActNum")
rtotal <- rtotal[order(rtotal$tempId),]
rtotal<-rtotal[,-1]
rtotal<-rtotal[,-69]


Fullvectornames <-c("Activity","Subject",vector_names)
colnames(rtotal)<-Fullvectornames

grouped_set<-group_by(rtotal, Subject, Activity)
summary_result<-summarise_each(grouped_set,funs(mean))

write.table(summary_result, file="tidy_data.txt", row.names=FALSE) 
