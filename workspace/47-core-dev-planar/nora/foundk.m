function k=foundk(epsilon,z1,z2)

S=z1+z2;
M=max(z1,z2);

 if epsilon/2 <= M
       error('Erreur : votre epsilon est trop petit');

 end

k1=floor((epsilon-M)/(2*S))+1;
k2=floor((epsilon/2-M)/(2*S)+1)+1;
k=max(k1,k2);


end