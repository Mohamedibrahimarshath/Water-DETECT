global cluster1;global he;global mask1;
%% Load Data
data=load('mydata');
T=data.T;

%% Apriori
MST=0.22;   % Minimum Support Threshold
MCT=0.6;    % Minimum Confidence Threshold
[FinalRules, Rules]=Apriori(T,MST,MCT);
axes(handles.axes6);imshow(cluster1);title('Apriori');
cluster1 = he .* uint8(mask1);
aa=mean2(cluster1);
acc=100/aa;
a=(aa*acc)-28.1598;
set(handles.edit9,'String',a);
   ina=std2(cluster1);avg_boby=ina/8;
    set(handles.edit14,'String',avg_boby);