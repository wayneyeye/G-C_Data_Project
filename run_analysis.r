rm(list=ls())

library(dplyr)
#load files from the master
act_labels<-read.table("./Samsung_data/activity_labels.txt")
features<-read.table("./Samsung_data/features.txt")
test_data<-read.table("./Samsung_data/test/X_test.txt")
train_data<-read.table("./Samsung_data/train/X_train.txt")
test_subject<-read.table("./Samsung_data/test/subject_test.txt" )
train_subject<-read.table("./Samsung_data/train/subject_train.txt")
test_activity<-read.table("./Samsung_data/test/y_test.txt" )
train_activity<-read.table("./Samsung_data/train/y_train.txt")

raw_alldata<-rbind(test_data,train_data)
names(raw_alldata)<-features[,2] #adhere feature list to colname
rm(list=c("test_data","train_data"))#remove the raw data to save some memmory
mean_features<-grep("mean\\(\\)|std\\(\\)",features$V2)
my_data<- raw_alldata[,mean_features]
rm(list=c("raw_alldata"))#remove the raw data to save some memmory
#add variable to identify activity and subject
activity_id<-rbind(test_activity,train_activity)
subject_id<-rbind(test_subject,train_subject)
my_data$activity_id<-activity_id$V1
my_data$subject_id<-subject_id$V1
#clean up the act_labels
names(act_labels)<-c("activity_id","activity")
#merge act_label with my_data
new_my_data<-merge(my_data,act_labels,by="activity_id")
rm(list=c("act_labels","activity_id","subject_id"))#remove the raw data to save some memmory
rm(list=c("test_subject","train_subject","my_data"))#remove the raw data to save some memmory
##
feature_names<-names(new_my_data)
new_feature_names<-gsub("^t","time_",feature_names)
new_feature_names<-gsub("^f","frequency_",new_feature_names)
new_feature_names<-gsub("Acc","Accelerometer_",new_feature_names)
new_feature_names<-gsub("Gyro","Gyroscope_",new_feature_names)
new_feature_names<-gsub("Body","Body_",new_feature_names)
new_feature_names<-gsub("Jerk","Jerk_",new_feature_names)
new_feature_names<-gsub("Gravity","Gravity_",new_feature_names)
new_feature_names<-gsub("Mag","Magnitude_",new_feature_names)
new_feature_names<-gsub("-mean\\(\\)","Mean",new_feature_names)
new_feature_names<-gsub("-std\\(\\)","StD",new_feature_names)
names(new_my_data)<-new_feature_names

##Group by subject and activity type
mydata_grouped<-group_by(new_my_data,subject_id,activity)
mydata_2<-summarize_each(mydata_grouped,funs(mean))
mydata_2<-arrange(mydata_2,subject_id,activity_id)
write.table(mydata_2,file="clean_data.txt",row.names = FALSE) # save table
