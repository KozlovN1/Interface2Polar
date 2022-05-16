function [pphi, rr, fig, fig1] = ...
    anlz_photo(path, filename, epsilon, cl_pair, ROI, center, ...
    R2, showfig, exportprof, exportdir)

%% Obtaining an interface coordinates from a colour photograph.
% v.0.7.2 (2022-05-16)
% Nick Kozlov

    % Get the image
    image1 = imread(strcat(path,filesep,filename));
    
    % Check the coordinates
    if isempty(ROI)
        ROI = [1, 1, size(image1,2), size(image1,2)];
    end
    if isempty(center)
        center = [0.5*size(image1,2), 0.5*size(image1,2)];
    end
    
    % Find the interface
    counter=0;
    % scan left to right
    for j=ROI(2):1:ROI(4)
        for i=ROI(1):1:center(1)
            if image1(j,i,cl_pair(1) )/image1(j,i,cl_pair(2) ) >= epsilon
                counter=counter+1;
                xintfc(counter)=i;
                yintfc(counter)=j;
                break;
            end
        end
    end
    % scan upwards
    for i=ROI(1):1:ROI(3)
        j=ROI(4);
        while j>center(2)
            if image1(j,i,cl_pair(1) )/image1(j,i,cl_pair(2) ) >= epsilon
                counter=counter+1;
                xintfc(counter)=i;
                yintfc(counter)=j;
                break;
            end
            j=j-1;
        end
    end
    % scan rigth to left
    j=ROI(4);
    while j>ROI(2)
        i=ROI(3);
        while i>center(1)
            if image1(j,i,cl_pair(1) )/image1(j,i,cl_pair(2) ) >= epsilon
                counter=counter+1;
                xintfc(counter)=i;
                yintfc(counter)=j;
                break;
            end
            i=i-1;
        end
        j=j-1;
    end
    % scan downwards
    i=ROI(3);
    while i>=ROI(1)
        j=ROI(2);
        while j<center(2)
            if image1(j,i,cl_pair(1) )/image1(j,i,cl_pair(2) ) >= epsilon
                counter=counter+1;
                xintfc(counter)=i;
                yintfc(counter)=j;
                break;
            end
            j=j+1;
        end
        i=i-1;
    end
    
    % Transfer to polar coordinates
    r=zeros(1,counter);
    phi=zeros(1,counter);
    for i=1:1:counter
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
