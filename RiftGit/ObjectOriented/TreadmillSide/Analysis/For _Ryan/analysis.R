dat[,time:=time_vst_absolute-dat$time_vst_absolute[1]]

heelstrike <- c(0,diff(dat$movingForward))
heelstrike[heelstrike==1] <- 0

dat[,cycle:=cumsum(-heelstrike)]

dat[,perturb:= as.integer(median(perturb)),by=cycle]
dat2<-dat
dat2[,time:=time-min(time),by=cycle]
dat2 <- dat2[hip_right < 1000]

nSpline <- 100


myfunc <- function(x,y,sequence)
{
    
    y=spline(x=x,y=y,xout=sequence,method="natural")$y
    list(y=y,x=sequence)
}



splines <- dat2[tspeed_desired==700,
                list(cycle,
                     perturb,
                     time,
                     xf,
                     xfr,
                     hip_right,
                     knee_right,
                     ankle_right,
                     hip_left,
                     knee_left,
                     ankle_left)][cycle > 60,
                                  myfunc(time,
                                         xf,
                                         seq(0,max(time),length.out=nSpline)),
                                  by=list(cycle,perturb)]
splines[,pgc:=seq(0,100,length.out=nSpline)]




avgs <- splines[,list(mn=mean(y),std=sd(y),sse=sum((y-mean(y))^2)),by=list(pgc,perturb)]

xfmax <- dat[,max(xf),by=perturb]

nSamples <- table(splines$perturb)/nSpline
n0 <- unname(nSamples[names(nSamples)=='0'])
n1 <- unname(nSamples[names(nSamples)=='1'])
n2 <- unname(nSamples[names(nSamples)=='2'])
n3 <- unname(nSamples[names(nSamples)=='3'])



nh02 <- 2/(1/n0+1/n2)
df02 <- (n0+n2)/2

tmp <- avgs[perturb %in% c(0,2)][,dm:=diff(mn),by=pgc][,s:=sqrt(2*sum(sse)/df02/nh02),by=pgc]
diffStd_0_2 <- tmp[,list(pgc,dm,s)]
setkey(diffStd_0_2,s)
diffStd_0_2 <- unique(diffStd_0_2)

tcrit <- qt(0.975,df02)

diffStd_0_2[,upper:=dm+s*tcrit][,lower:=dm-s*tcrit]





probs <- pt(diffStd_0_2$dm/diffStd_0_2$s,df02)
probsCorrected <- p.adjust(sort(probs),method="none")


mins <- splines[,list(lowpt=min(y)),by=list(perturb,cycle)]
mins2 <- mins[,list(lowmn=mean(lowpt),lowsd=sd(lowpt)),by=list(perturb)]

maxs <- splines[,list(highpt=max(y)),by=list(perturb,cycle)]
maxs2 <- maxs[,list(highmn=mean(highpt),highsd=sd(highpt)),by=list(perturb)]

extrema <- splines[,list(low=min(y),high=max(y)),by=list(perturb,cycle)] %>%
  gather(extreme,value,high,low)
extrema2 <- extrema[,list(mn=mean(value),std=sd(value)),by=list(perturb,extreme)]


fit <- lm(lowpt~factor(perturb)+cycle,mins[perturb%in%c(0,1,2)])
print(anova(fit))
print(summary(fit))
p <- ggplot(avgs[perturb %in% c(0,1,2)],aes(x=pgc,y=mn,colour=factor(perturb))) +
    geom_line() +
    geom_ribbon(aes(ymin=mn-std,ymax=mn+std,fill=factor(perturb)),alpha=0.3,colour=NA)

p2 <- ggplot(diffStd_0_2,aes(x=pgc,y=dm)) +
  geom_line() +
  geom_ribbon(aes(ymin=lower,ymax=upper),fill="gray",alpha=0.4,colour=NA)

p3 <- ggplot(,aes(x=1:nSpline,y=probsCorrected)) +
  geom_point()

p4 <- ggplot(splines[perturb %in% c(0,2)],aes(x=pgc,y=y,colour=factor(perturb),group=cycle)) +
  geom_line()

p5 <- ggplot(mins,aes(lowpt,fill=as.factor(perturb))) +
    geom_density(alpha=0.5)

p6 <- ggplot(mins,aes(x=cycle,y=lowpt,colour=factor(perturb))) +
    geom_point() +
    stat_smooth(method="lm")

p7 <- ggplot(extrema,aes(x=cycle,y=value,colour=factor(perturb)))+
  geom_point() +
  stat_smooth(method="lm") +
  facet_grid(extreme~.,scales="free_y")

print(p7)
