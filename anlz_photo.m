function [pphi, rr, fig, fig1] = ...
    anlz_photo(path, filename, epsilon, cl_pair, ROI, center, ...
    R2, showfig, exportfig, exportprof, do_circshift, exportdir)
    
%% Obtaining an interface coordinates from a colour photograph.
% v.0.9.10 (2025-03-18)
% Nick Kozlov
    
    % Get the image
    image1 = imread(strcat(path,filesep,filename));
    
    % Check the coordinates
    if isempty(ROI)
        ROI = [1, 1, size(image1,2), size(image1,2)]; % ???
    end
    if isempty(center)
        center = [0.5*size(image1,2), 0.5*size(image1,2)]; % ???
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
    fid50=fopen(strcat(path,filesep,'../report.txt'),'w'); % DEBUG
    fprintf(fid50,'ho-ho\n'); % DEBUG
    for i=1:1:counter
        % let's skip the near-wall (fake) interface points %
        if (1-sqrt((xintfc(i)-center(1))^2+(yintfc(i)-center(2))^2)/R2)<0.01
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
    % Remove the bad points
    r(isnan(r))=[];
    phi(isnan(phi))=[];
    
    % Check if any coordinate points were found and throw error if not
    if isempty(r) || isempty(phi)
        msgbox(['Interface could not be found. ' ...
            'You may try different parameters or another image.'],'Error','error')
        assert(false, 'STOP: Interface not found.')
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
    nsteps = ceil( 0.01*length(rrr) )*100;
    % fprintf('%s %d\n','length(rrr) = ',length(rrr)) % DEBUG %
    % fprintf('%s %d\n','nsteps = ',nsteps) % DEBUG %
    % fprintf('%s','find(isnan(rrr)) = ')   % DEBUG %
    % find(isnan(rrr))                      % DEBUG %
    % Below: I do not know why I had to subtract 2 steps from pi, but it
    % works => TEMPORARY WORKAROUND
    % pphi = linspace(-pi,pi*(1-2*2/nsteps), nsteps );
    % pphi = linspace(-pi,pi-2*pi/nsteps, nsteps );
    pphi = linspace(-pi,pi, nsteps );
    % fprintf('%s','find(isnan(pphi)) = ')     % DEBUG %
    % find(isnan(pphi))                        % DEBUG %
    if do_circshift == false
        rr = interp1( ppphi,rrr,pphi,'linear','extrap');
    else
        % Below: Interpolate => interpolate with the circular shift => shift it
        % back and take the average.
        K = nsteps/2;
        % rr1 = interp1( circshift(ppphi,K),circshift(rrr,K),...
        %     circshift(pphi,K),'linear');
        ppphi1 = circshift(ppphi,K);
        for i=1:1:K
            ppphi1(i) = ppphi1(i) - pi;
        end
        for i=K+1:1:length(ppphi1)
            ppphi1(i) = ppphi1(i) + pi;
        end
        rrr1 = circshift(rrr,K);
        pphi1 = circshift(pphi,K);
        rr1 = interp1(ppphi1,rrr1,pphi,'linear');
        % fprintf('%s','find(isnan(rr1)) = ')      % DEBUG %
        % find(isnan(rr1))                         % DEBUG %
    
        rr = interp1( ppphi,rrr,pphi,'linear');
        % rr = interp1( pphi,circshift(rr1,-K),pphi,'linear');
        % fprintf('%s','find(isnan(rr)) = ')       % DEBUG %
        % find(isnan(rr))                          % DEBUG %
        
        rr = (rr + circshift(rr1,-K))/2;
        % rr = circshift(rr1,-K);
    end
    % fprintf('%s','AGAIN find(isnan(rr)) = ') % DEBUG %
    % find(isnan(rr))                          % DEBUG %
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
        fig = figure('Name', strcat('Photo: ',filename), ...
            'Position',[0 0 0.5*scrsz(3) scrsz(4)],'Visible','off');
        % set(fig,'Visible','off');
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
