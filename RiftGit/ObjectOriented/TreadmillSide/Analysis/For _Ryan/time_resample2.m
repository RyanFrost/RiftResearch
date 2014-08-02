function [y, t]=time_resample2(Data, time)

time=round(time*1000);
y=zeros(time(end),1);
t=1:time(end);

for i=1:length(time)-1
    
    lamda=(Data(i+1)-Data(i))/(time(i+1)-time(i));
    
    t1 = time(i)+1;
    t2 = time(i+1);
    yy = Data(i)+lamda*([(time(i):(time(i+1)-1))']-time(i));
    
    y(t1:t2) = yy;
    
end



