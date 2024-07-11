fid = fopen(strcat(exportdir,filesep,strcat(filename,'_av.csv') ),'w');
fprintf( fid,'phi_av; +-; h_av; +-\n' );
for j=1:1:length(phi_av)
    fprintf(fid,'%e; ',phi_av(j) );
    fprintf(fid,'%e; ',error1(j) );
    fprintf(fid,'%e; ',1-r_av(j)/R2 );
    fprintf(fid,'%e',error2(j)/R2 );
    fprintf(fid,'%s\n',[]);
end
fclose(fid);