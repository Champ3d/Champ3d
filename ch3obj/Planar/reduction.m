function [ri2,ro2,thetai2 ,thetao2]=reduction(ri1,ro1,thetai1,thetao1,d1,d)

    ri2 = ri1 + d1  ;               
    ro2 = ro1 - d1;               

    
    if ~(ri2 > 0 && ro2 > 0)
        error('Rayons non positifs: ri2=%.6g, ro2=%.6g', ri2, ro2);
    end
    if ~(ri2 < ro2)
        error('il faut ri2 < ro2 .');
    end
    if ~(d1 < (ro1 - ri1)/2)
        error('d1 trop grand' , (ro1-ri1)/2);
    end

   
    Pi1_haut = [ri1*cosd(thetai1/2),  ri1*sind(thetai1/2)];
    Pi1_bas  = [ri1*cosd(thetai1/2), -ri1*sind(thetai1/2)];
    Po1_haut = [ro1*cosd(thetao1/2),  ro1*sind(thetao1/2)];
    Po1_bas  = [ro1*cosd(thetao1/2), -ro1*sind(thetao1/2)];

   





    u_haut = (Po1_haut - Pi1_haut) / norm(Po1_haut - Pi1_haut);
    u_bas  = (Po1_bas  - Pi1_bas ) / norm(Po1_bas  - Pi1_bas );

  
    n_haut = [-u_haut(2),  u_haut(1)];
    n_bas  = [-u_bas(2),   u_bas(1)];

   
    c1_haut = dot(n_haut, Pi1_haut);
    c1_bas  = dot(n_bas,  Pi1_bas);

   
    c2_haut = c1_haut - d;
    c2_bas  = c1_bas  + d;

    
  
   dmax_haut = min(c1_haut + ri2, c1_haut + ro2); 
   dmax_bas  = min(ri2 - c1_bas , ro2 - c1_bas ); 

   dmax = min(dmax_haut, dmax_bas);
   if d < 0 || d > dmax
    error('d hors plage: 0 <= d <= %.6g', dmax);
   end








    root = @(R2,C2) sqrt(R2 - C2.^2);

   
    Pi2_haut = c2_haut*n_haut + root(ri2^2, c2_haut)*u_haut;
    Pi2_bas  = c2_bas *n_bas  + root(ri2^2, c2_bas )*u_bas;  
    Po2_haut = c2_haut*n_haut + root(ro2^2, c2_haut)*u_haut;
    Po2_bas  = c2_bas *n_bas  + root(ro2^2, c2_bas )*u_bas;

   
    Li2 = norm(Pi2_bas - Pi2_haut);
    Lo2 = norm(Po2_bas - Po2_haut);
    arg_i = Li2/(2*ri2);
    arg_o = Lo2/(2*ro2);

   


    % --- angle interne
   x1 = Pi2_haut(1); 
   y1 = Pi2_haut(2);
   x2 = Pi2_bas(1); 
   y2 = Pi2_bas(2);
   thetai2 = atan2d(abs(x1*y2 - y1*x2), x1*x2 + y1*y2);

    % --- angle externe
    x1 = Po2_haut(1);
    y1 = Po2_haut(2);
    x2 = Po2_bas(1);  
    y2 = Po2_bas(2);
    thetao2 = atan2d(abs(x1*y2 - y1*x2), x1*x2 + y1*y2);









end