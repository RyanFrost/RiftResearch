%This function finds the moving RMS of a signal over an integral window
%using various numerical integration techniques. It can also plot the 
%signal together with the envelope estimate
%
%It is intended for use in estimating the amplitude of an EMG signal. 
%
%It is possible to select from the trapezoid rule and Simpson's 1/3rd rule
%in numerical integration
%
%Simpson's is more accurate, but the trapezoid rule is fast and possibly
%could be used in real time through a modification of this function
%
%


function RMS=AmplitudeEstimator(emgdata, window, Hz,  method)
%INPUT: signal, moving frame in seconds, sample rate, integration method
%method = 1; %is trapezoid rule which consumes one point per step
%method = 2 %is simpson's 1/3 rule which consumes 2 points per step
%Hz=1000;    %1000Hz refresh rate
%window=.25; %This is 50ms.


sampleemg = emgdata;

integral_window=round(window*Hz/method); %Steps in integral window. The method unit accounts for the number of points used per estimate
signallength=length(sampleemg);
h=method/Hz; % #steps / (steps/second) = duration of time step


if method == 1
   I=zeros(1,signallength);
   for a=2:signallength
       I(a)=h*(sampleemg(a-1)^2+sampleemg(a)^2)/2;
   end
   cuml=zeros(1,signallength);
   cuml(1)=I(1);
   RMS=zeros(1,signallength);
   RMS(1)=sqrt(cuml(1)/h);
   for b=2:(integral_window)
        cuml(b)=cuml(b-1)+I(b);
        RMS(b)=sqrt(cuml(b)/(b*h));
   end    
   for b=(integral_window+1):length(I)
        cuml(b)=cuml(b-1)+I(b)-I(b-integral_window);
        RMS(b)=sqrt(cuml(b)/window);
   end
end


if method == 2 
    
    I=zeros(1,ceil(signallength/2));

    for a=1:floor(signallength/2-1)
        I(a)=simpson13(h,sampleemg(a*2-1)^2, sampleemg(a*2)^2, sampleemg(a*2+1)^2); %Integral of square of function
    end 

    cuml=zeros(1,length(I)); %cumulative integral
    cuml(1)=I(1);
    RMS=zeros(1,length(I)); %RMS value
    RMS(1)=sqrt(cuml(1)/h); %cumulative integral needs to be divided by the integral window)
    for b=2:(integral_window)
        cuml(b)=cuml(b-1)+I(b);
        RMS(b)=sqrt(cuml(b)/(b*h));
    end 
    
    for b=(integral_window+1):length(I)
        cuml(b)=cuml(b-1)+I(b)-I(b-integral_window);
        RMS(b)=sqrt(cuml(b)/window);
    end
end 

[RMS,t] = time_resample2(RMS, 0.002:0.002:0.002*(length(RMS)));


% if doplot == 1
%     signaltime=linspace(0,signallength/(Hz/100),signallength);
%     RMStime=linspace(h/2,signallength/((Hz-h/2)/100),length(RMS));
%     %figure
%     %plot(RMS)
%     figure
%     plot(signaltime,sampleemg,'g',RMStime,RMS,'r')
%     %plot(RMStime,RMS,'r')
% end
