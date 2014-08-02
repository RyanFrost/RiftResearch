%%
function plot_muscle_activity(pgcEMG, taave, tastd, flag, location, transparent)

HS = 'HS';
TO = 'TO';
toHere = 15;
hsHere = toHere+40;
pertTiming = [0 60];

limits = ylim; 
frac = .5;
fracPert = .05;
yPert = (limits(2)-limits(1))*fracPert;
yText = (limits(2)-limits(1))*frac;
xPertText = round( (pertTiming(2) - pertTiming(1)) / 2 );
yPertText = 1.5*yPert;

%% TA
figure(1); clf;
title({'Tibialis Anterior muscle activity';'Contralateral (Right) Leg'});
hold all;

if flag == 1
    plot(pgcEMG, taave{1},'r','LineWidth',2);
    plot(pgcEMG, taave{2},'g','LineWidth',2);
    plot(pgcEMG, taave{3},'b','LineWidth',2);
    plot(pgcEMG, taave{4},'c','LineWidth',2);
    legend('1e4 N/m','5e4 N/m','1e5 N/m','1e6 N/m');
elseif flag == 2
    h1 = shadedErrorBar(pgcEMG,taave{1},tastd{1},{'r','LineWidth',2},0);
    h2 = shadedErrorBar(pgcEMG,taave{2},tastd{2},{'g','LineWidth',2},0);
    h3 = shadedErrorBar(pgcEMG,taave{3},tastd{3},{'b','LineWidth',2},0);
    h4 = shadedErrorBar(pgcEMG,taave{4},tastd{4},{'c','LineWidth',2},0);
    legend( [h1.mainLine,h2.mainLine,h3.mainLine,h4.mainLine] ,...
        '1e4 N/m','5e4 N/m','1e5 N/m','1e6 N/m');
end

line([hsHere hsHere],ylim,'Color',[0 0 0],'LineStyle',':')
line([toHere toHere],ylim,'Color',[0 0 0],'LineStyle',':')
line(pertTiming,[yPert yPert],'Color',[0 0 0],'LineWidth',3)
text(xPertText,yPertText,'Low Stiffness Perturbation','HorizontalAlignment','center');
text(hsHere,yText,HS);
text(toHere,yText,TO);

xlabel('Gait Cycle [%]')
ylabel('EMG amplitude')

set(gca,'FontSize',14,'fontWeight','bold')
set(findall(gcf,'type','text'),'FontSize',14,'fontWeight','bold')

return
%% individual cycles
val = 1;
figure(2); clf;
hold all;
for i = 1:length(taAct{val})
    plot(taAct{val}{i});
end
title('TA inf stiffness')

%% Find outliers

each cycle with mean
corrcoef
rank
plot against mean

end