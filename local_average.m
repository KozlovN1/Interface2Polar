function [average1,error1,average2,error2]=local_average(vector1,vector2,windoww,step)
% Smoothes a vector by means of averaging data locally.
% VibTechLib collection.
% Version 1.0.2 (2023-10-01)
% Nick Kozlov
%
% Updates:
% - check for missing data;
% - abs(vector1(RunAv)-vector1(RunAv+1))/step>=2
% - window --> windoww

if step==0
    testvector=zeros(size(vector1,1)-1,1);
    for i=1:1:size(vector1,1)-1
        testvector(i)=abs(vector1(i)-vector1(i+1));
    end
    step=mean(testvector);
%     msgbox(strcat('step = ',num2str(step))); % DBG
end

C1=0; C2=0;
average1=zeros(floor(size(vector1,1)/windoww),1);
error1=zeros(floor(size(vector1,1)/windoww),1);
average2=zeros(floor(size(vector1,1)/windoww),1);
error2=zeros(floor(size(vector1,1)/windoww),1);

buffer1=zeros(windoww,1);
buffer2=zeros(windoww,1);

if windoww < size(vector1,1)
     %% DBG %%
%     scrsz = get(0,'ScreenSize');
%     fig=figure('Position',[scrsz(3) scrsz(4) scrsz(3) scrsz(4)]);
%     hold on;
    %% %%
    for RunAv=1:size(vector1,1)
        C1=C1+1; %%counter to average by groups of $window pairs
        if C2+1>size(average1,1)
            average1(C2+1)=0;
            average2(C2+1)=0;
        end
        average1(C2+1)=average1(C2+1)+vector1(RunAv);
        average2(C2+1)=average2(C2+1)+vector2(RunAv);
        buffer1(C1)=vector1(RunAv);
        buffer2(C1)=vector2(RunAv);
        
        if RunAv==size(vector1,1)
            average1(C2+1)=average1(C2+1)/C1;
            error1(C2+1)=std(buffer1);
            average2(C2+1)=average2(C2+1)/C1;
            error2(C2+1)=std(buffer2);
            C1=0;
            C2=C2+1;
%             msgbox('END'); % DBG
        elseif C1==windoww || abs(vector1(RunAv)-vector1(RunAv+1))/step>=2
            average1(C2+1)=average1(C2+1)/C1;
            error1(C2+1)=std(buffer1);
            average2(C2+1)=average2(C2+1)/C1;
            error2(C2+1)=std(buffer2);
            C1=0;
            C2=C2+1;
        end
        %% DBG %%
%         figure(fig);
%         plot(RunAv,C1,'ko');
%         plot(RunAv,C2,'bx');
%         drawnow;
%         disp(C1);
%         disp(C2);
    end
else
    msgbox('The window is too large', 'Config error','error');
%     disp('The window is too large');
end
end