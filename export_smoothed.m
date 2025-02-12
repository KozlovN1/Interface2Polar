fid = fopen(strcat(exportdir,filesep,strcat(filename,'.csv') ),'w');
fprintf( fid,'phi; h\n' );
for j=1:1:length(phi_ed)
    fprintf(fid,'%e; ',phi_ed(j) );
    fprintf(fid,'%e',1-r_ed(j)/R2 );
    fprintf(fid,'%s\n',[]);
end
fclose(fid);
% scrsz = get(0,'ScreenSize');
% fig2=figure('Name', strcat('Azimuthal profiles: ',filename) ,'Position',...
%         [0 0 scrsz(3) scrsz(4)]); % ,'Visible','off');
% % set(fig2,'Visible','off');
% hold on;
% errorbar(phi_av./pi,1-r_av/R2,error2./R2,'.');
% plot(phi_ed./pi,1-r_ed/R2,'LineWidth',2);
% xlim([-1 1]);
% title('Azimuthal profile');
% xlabel('\phi/\pi'); 
% ylabel('{\it h}/{\it R}_2');
print(strcat(exportdir,filesep,filename,'_profile.svg'),'-dsvg','-painters');