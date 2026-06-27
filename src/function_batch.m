function function_batch(filename, fig, exportdir, phi, r, windoww, resolution)
% v.1.6 (2026-06-27)
% Nick Kozlov

if do_exportfig==true
    % filename = filenames{i};
    print(fig,strcat(exportdir,filesep,filename,'.png'),'-dpng','-r300');
end
[phi_av,error1,r_av,error2] = local_average(phi',r',windoww,0);
phi_ed = linspace(-pi,pi,resolution);
r_ed = interp1(phi_av,r_av,phi_ed,'spline','extrap');
if do_exportprof==true
    % filename = filenames{i};
    export_averaged;

    if do_showfig==false 
        fig2 = figure('Position',[0 0 scrsz(3) scrsz(4)], ...
            'Name', strcat('Azimuthal profiles: ',filename),'Visible','off');
    else
        fig2 = figure('Position',[0 0 scrsz(3) scrsz(4)], ...
            'Name', strcat('Azimuthal profiles: ',filename));
    end
    hold on;
    errorbar(phi_av./pi,1-r_av/R2,error2./R2,'.');
    plot(phi_ed./pi,1-r_ed/R2,'LineWidth',2);
    xlim([-1 1]);
    title('Azimuthal profile');
    xlabel('\phi/\pi'); 
    ylabel('{\it h}/{\it R}_2');

    export_smoothed;
end
