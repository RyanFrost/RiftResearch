rm(list=ls())
library(data.table)
library(ggplot2)

dat <- fread("erinData3_22_15.txt")
dat[,V54:=NULL]
setnames(dat, c(
"motorv_int",
"lcR_lbs",
"lcL_lbs",
"time",
"tspeed_desired",
"xd_raw",
"xact",
"perturb",
"angle_enc",
"Kd",
"Kact",
"Fb_raw",
"elapsed",
"numEMG",
"cycle",
"time_vst_absolute",
"zero_time_absolute",
"joint_angles1",
"joint_angles2",
"joint_angles3",
"joint_angles4",
"joint_angles5",
"joint_angles6",
"xf",
"movingBackward",
"movingForward",
"distance",
"currentPatch",
"patchType",
"marker_x_l_1",
"marker_x_l_2",
"marker_x_l_3",
"marker_x_l_4",
"marker_x_l_5",
"marker_x_l_6",
"marker_y_l_1",
"marker_y_l_2",
"marker_y_l_3",
"marker_y_l_4",
"marker_y_l_5",
"marker_y_l_6",
"marker_x_r_1",
"marker_x_r_2",
"marker_x_r_3",
"marker_x_r_4",
"marker_x_r_5",
"marker_x_r_6",
"marker_y_r_1",
"marker_y_r_2",
"marker_y_r_3",
"marker_y_r_4",
"marker_y_r_5",
"marker_y_r_6"))



p <-ggplot(dat[perturb>0],aes(x=perturb)) +
  geom_histogram()

print(p)