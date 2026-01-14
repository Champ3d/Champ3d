function [M,A]=fun_calcul_mutuel_segment(xsi,ysi,zsi,xsf,ysf,zsf,xdi,ydi,zdi,xdf,ydf,zdf)
%calcul de la mutuel inductance créée par
%un fil ([xsi ysi zsi] [xsf ysf zsf]) 
%sur un autre fil ([xdi ydi zdi] [xdf ydf zdf])
mu0=pi*4e-7;
%nombre de points sur le fil destination 
alpha=(xsf-xsi).^2+(ysf-ysi).^2+(zsf-zsi).^2;
var=(mu0./(4*pi*sqrt(alpha)));
ndec=1;
A = 0;
for ii=1:ndec
    Ax=zeros(1,length(xdi));
    Ay=zeros(1,length(xdi));
    Az=zeros(1,length(xdi));
    dl=[xdf-xdi;ydf-ydi; zdf-zdi];
    x=xdi+0.5*dl(1,:)*ii/ndec;
    y=ydi+0.5*dl(2,:)*ii/ndec;
    z=zdi+0.5*dl(3,:)*ii/ndec;
    beta=2*((xsf-xsi).*(xsi-x)+(ysf-ysi).*(ysi-y)+(zsf-zsi).*(zsi-z));
    gamma=(x-xsi).^2+(y-ysi).^2+(z-zsi).^2;
    omega=((4*gamma.*alpha)-(beta).^2)./(4*(alpha).^2);
    var1=var.*(log(abs(1+(beta./(2*alpha))+sqrt((1+(beta./(2*alpha))).^2+omega))./...
              abs(beta./(2*alpha)+sqrt((beta./(2*alpha)).^2+omega))));
    Ax=Ax+(xsf-xsi).*var1;
    Ay=Ay+(ysf-ysi).*var1;
    Az=Az+(zsf-zsi).*var1;
   %calcul de L
   dm(ii,:)=(Ax.*dl(1,:)+Ay.*dl(2,:)+Az.*dl(3,:))/ndec;
end
A = [Ax;Ay;Az];
M=sum(dm);


