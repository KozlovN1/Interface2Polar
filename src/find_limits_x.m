% v.0.9.6 (2025-03-05)
% Nick Kozlov

deriv=zeros(ROI(3)-ROI(1),1);
for i=center(1):1:ROI(3)-1
    deriv(i)=0.5*(image1(center(2),i,1)-image1(center(2),i-1,1)...
        +image1(center(2),i+1,1)-image1(center(2),i,1));
end
for i=center(1):-1:1+1
    deriv(i)=0.5*(image1(center(2),i,1)-image1(center(2),i+1,1)...
        +image1(center(2),i-1,1)-image1(center(2),i,1));
end
norm=mean(deriv);

limit1=0;
limit2=0;
for i=center(1):1:ROI(3)-1
    if limit1==0 && deriv(i)-norm>=epsilon
        limit1=i;
    end
    if limit1~=0 && deriv(i)-norm<=epsilon
        limit2=i;
        break
    end
end
max_x0=limit1-1+find(deriv(limit1:limit2)==max(deriv(limit1:limit2)),1);

limit1=0;
limit2=0;
for i=center(1):-1:1+1
    if limit1==0 && deriv(i)-norm>=epsilon
        limit1=i;
    end
    if limit1~=0 && deriv(i)-norm<=epsilon
        limit2=i;
        break
    end
end
min_x0=limit2-1+find(deriv(limit2:limit1)==max(deriv(limit2:limit1)),1);