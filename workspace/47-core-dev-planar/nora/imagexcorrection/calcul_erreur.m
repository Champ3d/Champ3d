function err=calcul_erreur(x,B_femm_primaire,B_femm_secondaire,B_analytique_primaire,B_analytique_secondaire,coeff)


%try
 
    gamma1 = x(1);
    gamma2 = x(2);
    gamma3 = x(3);
    gamma4 = x(4);
    
     [Bprimaire,Bsecondaire]=induction_analytique_image_correction(gamma1,gamma2,gamma3,gamma4,coeff);
    
     B_analytique_primaire.region3= B_analytique_primaire.region3+Bprimaire;
     B_analytique_secondaire.region3=B_analytique_secondaire.region3+Bsecondaire; 
     

     Dprimaire = B_analytique_primaire.region3(2,:) - B_femm_primaire(2,:);
     err_primaire =sqrt( sum(Dprimaire(:).^2));

     Dsecondaire = B_analytique_secondaire.region3(2,:) - B_femm_secondaire(2,:);
     err_secondaire =sqrt( sum(Dsecondaire(:).^2));

     err=coeff(1)*err_primaire+coeff(2)*err_secondaire;

    %if isnan(err) || isinf(err)
     %   err = 1e20;
    %end

    %catch
    %    err = 1e20;
   % end


end