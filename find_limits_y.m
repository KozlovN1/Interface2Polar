deriv=zeros(ROI(4)-ROI(2),1);
for j=center(2):1:ROI(4)-1
    deriv(j)=0.5*(image1(j,center(1),1)-image1(j-1,center(1),1)...
        +image1(j+1,center(1),1)-image1(j,center(1),1));
end
for j=center(2):-1:1+1
    deriv(j)=0.5*(image1(j,center(1),1)-image1(j+1,center(1),1)...
        +image1(j-1,center(1),1)-image1(j,center(1),1));
end
norm=mean(deriv);

limit1=0;
limit2=0;
for j=center(2):1:ROI(4)
    if limit1==0 && deriv(j)-norm>=epsilon
        limit1=j;
    end
    if limit1~=0 && deriv(j)-norm<=epsilon
        limit2=j;
        break
    end
end
max_y0=limit1-1+find(deriv(limit1:limit2)==max(deriv(limit1:limit2)),1);

limit1=0;
limit2=0;
for j=center(2):-1:1
    if limit1==0 && deriv(j)-norm>=epsilon
        limit1=j;
    end
    if limit1~=0 && deriv(j)-norm<=epsilon
        limit2=j;
        break
    end
end
min_y0=limit2-1+find(deriv(limit2:limit1)==max(deriv(limit2:limit1)),1);