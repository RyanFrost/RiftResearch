


dat[,time:=time_vst_absolute-dat$time_vst_absolute[1]]

heelstrike <- c(0,diff(dat$movingForward))
heelstrike[heelstrike==1] <- 0

dat[,cycle:=cumsum(-heelstrike)]

dat[,perturb:= as.integer(median(perturb)),by=cycle]
dat2<-dat
dat2[,time:=time-min(time),by=cycle]

myfunc <- function(x,y,sequence)
{
    
    y=spline(x=x,y=y,xout=sequence,method="natural")$y
    list(y=y,x=sequence)
}



splines <- dat2[cycle >600 & cycle < 1000,
                list(cycle,
                     perturb,
                     time,
                     xf)][,myfunc(time,
                                  marker_y_r_6,
                                  seq(0,max(time),length.out=1000)),by=list(cycle,perturb)]
splines[,pgc:=seq(0,100,length.out=1000)]


avgs <- splines[,list(mn=mean(y),std=sd(y)),by=list(pgc,perturb)]

xfmax <- dat[,max(xf),by=perturb]
#dat <- dat[xf>(-10000)][tspeed_desired==700]


print(summary(avgs))

p <- ggplot(avgs,aes(x=pgc,y=mn,colour=factor(perturb))) +
    geom_line() +
    geom_ribbon(aes(ymin=mn-std,ymax=mn+std,fill=factor(perturb),),alpha=0.2)


print(p)