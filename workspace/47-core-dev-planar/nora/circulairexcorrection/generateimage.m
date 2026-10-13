function imagesys = generateimage(c0,I,z1primaire,z1secondaire,epaisseur,mur,imagelevel)

   imagesys_sg1 = generateimage_sg1(c0,I,z1primaire,z1secondaire,epaisseur,mur,imagelevel);
   imagesys_sg2 = generateimage_sg2(c0,I,z1primaire,z1secondaire,epaisseur,mur,imagelevel);
   imagesys = imagesys_sg1.fusionner(imagesys_sg2);

end