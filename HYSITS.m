clc, clear all, close all
 
%The following three lines need to be adjusted by user
FileName = 'D:\AC\data_example_vsm.dat'; %Directory file
Param.SS = 20; %Smoothing span
Param.incr = 0.001; %Increment of H for interpolation
 
%Reading data
DataRead = char(fileread(FileName)); 
DataRead = strsplit(DataRead,{'\t','\r'}); 
Data.SampleName = DataRead(1); 
if length(Data.SampleName)>30
    Data.SampleName = Data.SampleName(1:30); 
end
DataRead(1) = {'0'}; 
DataRead = str2double(DataRead); 
Data.w = DataRead(2); 
Data.H = DataRead(3:2:end)';
Data.M = DataRead(4:2:end)'/Data.w;
[~,Data.ind_min] = min(Data.H);
[~,Data.ind_max] = max(Data.H);
 
%Sorting
Raw.H_desc = Data.H(Data.ind_max:Data.ind_min); 
Raw.M_desc = Data.M(Data.ind_max:Data.ind_min);
[Raw.H_desc,Raw.uH_desc] = unique(Raw.H_desc); 
Raw.M_desc = Raw.M_desc(Raw.uH_desc,:);
Raw.H_asc = Data.H(Data.ind_min:end); 
Raw.M_asc = Data.M(Data.ind_min:end);
[Raw.H_asc,Raw.uH_asc] = unique(Raw.H_asc); 
Raw.M_asc = Raw.M_asc(Raw.uH_asc,:);
 
%Interpolation and Smoothing
Interp.H2_desc = [Raw.H_desc(1):Param.incr:Raw.H_desc(end)]';
Interp.M2_desc = interp1(Raw.H_desc,Raw.M_desc,Interp.H2_desc); 
Interp.M2_desc = smooth(Interp.M2_desc,Param.SS);
Interp.H2_asc = [Raw.H_asc(1):Param.incr:Raw.H_asc(end)]';
Interp.M2_asc = interp1(Raw.H_asc,Raw.M_asc,Interp.H2_asc); 
Interp.M2_asc = smooth(Interp.M2_asc,Param.SS);
 
%Calculating delta_M and its 1st derivative
Cal.delta_m = (Interp.M2_desc-Interp.M2_asc);
Cal.deriv_1 = diff(Cal.delta_m)/Param.incr;
 
%Plots
figure
set(gcf,'Units','Normalized','OuterPosition',[0 0.3125 0.95 0.62])
subplot(1,3,1), 
plot(Interp.H2_desc,Interp.M2_desc,Interp.H2_asc,Interp.M2_asc,'b')
hold on, 
line(xlim, [0 0],'Color','k');  
line([0 0], ylim,'Color','k');  
xlabel('H (T)'),ylabel('M (emu/g)')
title ('Hysterisis Curve')
subplot(1,3,2),
plot(Interp.H2_asc,Cal.delta_m/max(Cal.delta_m))
xlim([0 max(xlim)]) 
hold on
line(xlim, [0 0],'Color','k'); 
line([0 0], ylim,'Color','k'); 
xlabel('H (T)'), ylabel('delta M (emu/g) (Normalized)')
title ('Delta M')
subplot(1,3,3), 
plot(Interp.H2_asc(1:end-1),-Cal.deriv_1/max(-Cal.deriv_1))
xlim([0 max(xlim)]) 
hold on
line(xlim, [0 0],'Color','k');  
line([0 0], ylim,'Color','k');  
xlabel('H (T)'), ylabel('d(delta M)/d(H) (Normalized)')
title ('1st Derivative of delta M')
suptitle(Data.SampleName )
Param.Annotation = {['[Increment : ' num2str(Param.incr) ...
    ']    [Smoothing span : ' num2str(Param.SS) ']']};
annotation('textbox',[0.6 0.78 0.4 0.2],'String', ...
    Param.Annotation,'FitBoxToText','on', 'FontSize', ...
    8,'LineStyle','none')
