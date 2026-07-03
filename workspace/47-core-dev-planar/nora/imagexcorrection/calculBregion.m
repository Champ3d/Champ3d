function induction_mag = calculBregion(c0,I,z1primaire,z1secondaire,epaisseur,mur,imagelevel,node)

    B1 = 0;
    B2 = 0;
    B3 = 0;
    B4 = 0;
    B5 = 0;

    imagesys = generateimage(c0,I,z1primaire,z1secondaire,epaisseur,mur,imagelevel);
    zinterface = [z1primaire - epaisseur;z1primaire;z1secondaire;z1secondaire + epaisseur];
    id1 = (node(2,:) < zinterface(1)) ;
    id2 = (node(2,:) >= zinterface(1)) & (node(2,:) <zinterface(2));
    id3 = (node(2,:) >= zinterface(2)) & (node(2,:) < zinterface(3));
    id4 = (node(2,:) >= zinterface(3)) & (node(2,:) < zinterface(4));
    id5 = (node(2,:) >= zinterface(4)) ;




    node1 = node(:,id1);
    node2 = node(:,id2);
    node3 = node(:,id3);
    node4 = node(:,id4);
    node5 = node(:,id5);


  if ~isempty(node1)
      
    for i = 1:length(imagesys.imageregion1)
        B1 = B1 + fB(imagesys.imageregion1{i}.pos, node1, imagesys.imageregion1{i}.I);
       
    end
  end


  if ~isempty(node2)
    
    for i = 1:length(imagesys.imageregion2)
        B2 = B2 + fB(imagesys.imageregion2{i}.pos, node2, imagesys.imageregion2{i}.I);
        
    end
  end

  if ~isempty(node3)
     
    for i = 1:length(imagesys.imageregion3)
        B3 = B3 + fB(imagesys.imageregion3{i}.pos, node3, imagesys.imageregion3{i}.I);
        
    end
  end


  if ~isempty(node4)
     
    for i = 1:length(imagesys.imageregion4)
        B4 = B4 + fB(imagesys.imageregion4{i}.pos, node4, imagesys.imageregion4{i}.I);
        
    end
  end

  if ~isempty(node5)
     
    for i = 1:length(imagesys.imageregion5)
        B5 = B5 + fB(imagesys.imageregion5{i}.pos, node5, imagesys.imageregion5{i}.I);
        
    end
  end



    induction_mag = struct("region3", B3, "region1", B1, "region2", B2, "region4", B4, "region5", B5);

end