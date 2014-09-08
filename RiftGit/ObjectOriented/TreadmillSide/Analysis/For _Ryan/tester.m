clear
close

t = linspace(0,4*pi,100000);
y = sin(t);
yDiff = [diff(y),diff(y(end-1:end))];
yGrad = gradient(y,2*pi/length(t));


plot(t,y,'--k');
hold on
plot(t,yDiff,'-b');
plot(t,yGrad,'-r');
hold off