function [pphi, rr, fig, fig1] = ...
    anlz_photo_bw(path, filename, epsilon, ROI, center, ...
    R2, showfig, exportfig, exportprof, R_min, R_max, exportdir)
    
%% Obtaining interface coordinates from a grayscale photograph.
% v.0.9.1.1 (2024-08-02)
% Nick Kozlov
    
    % Get the image
    image1 = imread(strcat(path,filesep,filename));
%     image2 = double(imread(strcat(path,filesep,filename))); % You will
%     need it to take the negative derivatives
    
    % Check the coordinates
    if isempty(ROI)
        ROI = [1, 1, size(image1,2), size(image1,1)]; % ???
    end
    if isempty(center)
        center = [round(0.5*size(image1,2)), round(0.5*size(image1,1))]; % ???
    end
    if isempty(R_min)
        R_min=0;
    end
    if isempty(R_max)
        R_max=R2;
    elseif R_max==0 || R_max<=R_min
        R_max=R2;
    end
    
    %% Get the limits
    find_limits_x; % produces max_x0, min_x0
%         msgbox({'min_x0';num2str(min_x0);'max_x0';num2str(max_x0)}); % DEBUG
    find_limits_y; % produces max_y0, min_y0
%         msgbox({'min_y0';num2str(min_y0);'max_y0';num2str(max_y0)}); % DEBUG
    
    %% Find the interface
    counter=0;
    % scan left to right
    for j=min_y0:1:max_y0 % j=ROI(2):1:ROI(4)
        deriv=zeros(ROI(3)-center(1),1);
        for i=center(1):1:ROI(3)-1
            deriv(i)=0.5*(image1(j,i,1)-image1(j,i-1,1)...
                +image1(j,i+1,1)-image1(j,i,1));
        end
        norm=mean(deriv);
        limit1=0;
%         limit2=0;
        for i=center(1):1:ROI(3)-1 % <---
            if limit1==0 && deriv(i)-norm>=epsilon
                limit1=i;
            end
            if limit1~=0 && deriv(i)-norm<=epsilon
                limit2=i;
                counter=counter+1;
                xintfc(counter)=limit1-1+find(deriv(limit1:limit2)==max(deriv(limit1:limit2)),1);
                yintfc(counter)=j;
                break
            end
        end
    end
    % scan upwards
    for i=min_x0:1:max_x0
        deriv=zeros(center(2)-ROI(2),1);
        for j=center(2):-1:ROI(2)+1
            deriv(j)=0.5*(image1(j,i,1)-image1(j+1,i,1)...
                +image1(j-1,i,1)-image1(j,i,1));
        end
%         msgbox({'deriv';num2str(length(deriv))}); % DEBUG
        norm=mean(deriv);
        limit1=0;
%         limit2=0;
        for j=center(2):-1:ROI(2) % <---
            if limit1==0 && deriv(j)-norm>=epsilon
                limit1=j;
            end
            if limit1~=0 && deriv(j)-norm<=epsilon
                limit2=j;
                counter=counter+1;
                xintfc(counter)=i;
                yintfc(counter)=limit2-1+find(deriv(limit2:limit1)==max(deriv(limit2:limit1)),1);
                break
            end
        end
    end
    % scan rigth to left
    for j=min_y0:1:max_y0
%     for j=min_y0:round((max_y0-min_y0)/5):max_y0 % DEBUG
        deriv=zeros(center(1)-ROI(1),1);
        for i=center(1):-1:ROI(1)+1
            deriv(i)=0.5*(image1(j,i,1)-image1(j,i+1,1)...
                +image1(j,i-1,1)-image1(j,i,1));
        end
        norm=mean(deriv);
        limit1=0;
%         limit2=0;
        for i=center(1):-1:ROI(1)
            if limit1==0 && deriv(i)-norm>=epsilon
                limit1=i;
            end
            if limit1~=0 && deriv(i)-norm<=epsilon
                limit2=i;
                counter=counter+1;
                xintfc(counter)=limit2-1+find(deriv(limit2:limit1)==max(deriv(limit2:limit1)),1);
                yintfc(counter)=j;
                break
            end
        end
%         monitor_fig; % DEBUG
    end
    % scan downwards
    for i=min_x0:1:max_x0
        deriv=zeros(ROI(4)-center(2),1);
        for j=center(2):1:ROI(4)-1
            deriv(j)=0.5*(image1(j,i,1)-image1(j-1,i,1)...
                +image1(j+1,i,1)-image1(j,i,1));
        end
%         msgbox({'deriv';num2str(length(deriv))}); % DEBUG
        norm=mean(deriv);
        limit1=0;
%         limit2=0;
        for j=center(2):1:ROI(4)-1 % <---
            if limit1==0 && deriv(j)-norm>=epsilon
                limit1=j;
            end
            if limit1~=0 && deriv(j)-norm<=epsilon
                limit2=j;
                counter=counter+1;
                xintfc(counter)=i;
                yintfc(counter)=limit1-1+find(deriv(limit1:limit2)==max(deriv(limit1:limit2)),1);
                break
            end
        end
    end
    
    % Show me the raw results
%     show_raw_results; % DEBUG

    %% Transfer to polar coordinates
    r=zeros(1,counter);
    phi=zeros(1,counter);
    fid50=fopen(strcat(path,filesep,'../report.txt'),'w'); % DEBUG
    fprintf(fid50,'ho-ho\n'); % DEBUG
    for i=1:1:counter
        % let's skip the near-wall (fake) interface points %
        if (1-sqrt((xintfc(i)-center(1))^2+(yintfc(i)-center(2))^2)/R2)<0.01
            fprintf(fid50,'bad point detected\n'); % DEBUG
            r(i)=NaN;
            phi(i)=NaN;
            continue
        elseif sqrt((xintfc(i)-center(1))^2+(yintfc(i)-center(2))^2)<R_min
            fprintf(fid50,'bad point detected\n'); % DEBUG
            r(i)=NaN;
            phi(i)=NaN;
            continue
        elseif sqrt((xintfc(i)-center(1))^2+(yintfc(i)-center(2))^2)>R_max
            fprintf(fid50,'bad point detected\n'); % DEBUG
            r(i)=NaN;
            phi(i)=NaN;
            continue
        end
        % let's skip: done %
        r(i)=sqrt((xintfc(i)-center(1))^2+(yintfc(i)-center(2))^2);
        % quadrants:
        if (xintfc(i)-center(1))>0 && (yintfc(i)-center(2))>0 %right-bottom
            phi(i) = atan((xintfc(i)-center(1))/(yintfc(i)-center(2)));
        end
        if (xintfc(i)-center(1))>0 && (yintfc(i)-center(2))<0 %right-top
            phi(i) = 0.5*pi + atan(-(yintfc(i)-center(2))/(xintfc(i)-center(1)));
        end
        if (xintfc(i)-center(1))<0 && (yintfc(i)-center(2))<0 %left-top
            phi(i) =-0.5*pi + atan(-(yintfc(i)-center(2))/(xintfc(i)-center(1)));
        end
        if (xintfc(i)-center(1))<0 && (yintfc(i)-center(2))>0 %left-bottom
            phi(i) = atan((xintfc(i)-center(1))/(yintfc(i)-center(2)));
        end
        % intersections:
        if (xintfc(i)-center(1))==0 && (yintfc(i)-center(2))>0 %center-bottom
            phi(i) = 0;
        end
        if (xintfc(i)-center(1))>0 && (yintfc(i)-center(2))==0 %right-center
            phi(i) = 0.5*pi;
        end
        if (xintfc(i)-center(1))<0 && (yintfc(i)-center(2))==0 %left-center
            phi(i) =-0.5*pi;
        end
        if (xintfc(i)-center(1))==0 && (yintfc(i)-center(2))<0 %center-top
            phi(i) = -pi;
        end
    end
    fclose(fid50); % DEBUG
%         % Show me what you've got
%         figure('Name','DEBUG'); % DEBUG
%         plot(phi,r); %DEBUG
    % Remove the bad points
    r(isnan(r))=[];
    phi(isnan(phi))=[];
%         % Show me what you've got
%         figure('Name','DEBUG'); % DEBUG
%         plot(phi,r); %DEBUG

    %%% Interpolation is necessary to remove "inclined" regions of profile
    % Remove non-unique values, thus enabling the interpolation
    cnt1 = 1;
    cnt2 = 0;
    ppphi = 0;
    rrr = 0;
    for i =1:1:length(phi)
        if length(find(phi == phi(i) ) ) > 1
            if ~ ppphi( ppphi == phi(i) )
                for j = find(phi == phi(i) )
                    ppphi(cnt1) = ppphi(cnt1) + phi(j);
                    rrr(cnt1) = rrr(cnt1) + r(j);
                    cnt2 = cnt2 + 1;
                end
                ppphi(cnt1) = ppphi(cnt1)/cnt2;
                rrr(cnt1) = rrr(cnt1)/cnt2;
                cnt2 = 0;
            end
        else
            ppphi(cnt1) = phi(i);
            rrr(cnt1) = r(i);
            cnt1 = cnt1 + 1;
        end
    end
    
    % Interpolate the azimuthal interface profile
    pphi = linspace(-pi,pi, ceil( 0.01*length(rrr) )*100 );
    rr = interp1( ppphi,rrr,pphi,'linear','extrap');
    %_%
    % Median filter could be applied here to make the profile smoother
    %_%

    %% Figures and plotting
    if showfig == true
        %Prepare figures%
        scrsz = get(0,'ScreenSize');
        fig = figure('Name', strcat('Photo: ',filename) ,'Position',[0 0 0.5*scrsz(3) scrsz(4)]);
        fig1 = figure('Name', strcat('Azimuthal profiles: ',filename) ,'Position',...
            [0.5*scrsz(3) 0 0.5*scrsz(3) scrsz(4)]);
        %_%

        figure(fig);
        image(image1);
        axis image;
        hold on;
        ROIrect = rectangle('Position', [ROI(1) ROI(2) ROI(3)-ROI(1) ROI(4)-ROI(2)]);
        ROIrect.LineStyle = '--';
        ROIrect.EdgeColor = 'g';
        plot(xintfc,yintfc,'r.','MarkerSize',3);
        
        figure(fig1); 
        subplot(2,1,1); plot(r); title('Raw signal'); xlabel('Point number'); 
            ylabel('{\it r}, pix');
        subplot(2,1,2); plot(pphi./pi,1 - rr/R2); title('Azimuthal profile');
            xlabel('\phi/\pi'); ylabel('{\it h}/{\it R}_2');
    elseif showfig==false && exportfig==true
        scrsz = get(0,'ScreenSize');
        fig = figure('Name', strcat('Photo: ',filename) ,'Position',[0 0 0.5*scrsz(3) scrsz(4)]);
        set(fig,'Visible','off');
        image(image1);
        axis image;
        hold on;
        ROIrect = rectangle('Position', [ROI(1) ROI(2) ROI(3)-ROI(1) ROI(4)-ROI(2)]);
        ROIrect.LineStyle = '--';
        ROIrect.EdgeColor = 'g';
        plot(xintfc,yintfc,'r.','MarkerSize',3);
        fig1 = '';
    else
        fig = '';
        fig1 = '';
    end
    
    %% The export of interface profile
    if exportprof == true
        fid = fopen(strcat(exportdir,filesep,strcat(filename,'.csv') ),'w');
        fprintf( fid,strcat( 'phi; h\n' ) );
        for i=1:1:length(pphi)
            fprintf(fid,'%e; ',pphi(i) );
            fprintf(fid,'%e\n',1 - rr(i)/R2);
        end
        fclose(fid);
    end
end
