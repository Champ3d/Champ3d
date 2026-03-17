function induction_mag = calculBregion(c0, I, xmir, ymir, mur, k, node)

    B1 = 0;
    B2 = 0;
    B0 = 0;

    imagesys = generateimage_brouillon(c0, I, xmir, ymir, mur, k);
%     imagesys = generateimage(c0, I, xmir, ymir, mur, k);
    id1 = (node(2,:) > ymir) & (node(1,:) <= xmir);
    id0 = (node(2,:) <= ymir) & (node(1,:) <= xmir);
    id2 = (node(2,:) <= ymir) & (node(1,:) > xmir);

    node1 = node(:,id1);
    node0 = node(:,id0);
    node2 = node(:,id2);



  if ~isempty(node1)

    for i = 1:length(imagesys.imageregion1)
        B1 = B1 + fB(imagesys.imageregion1{i}.pos, node1, imagesys.imageregion1{i}.I);
    end
  end



  if ~isempty(node0)
    for i = 1:length(imagesys.imageregion0)
        B0 = B0 + fB(imagesys.imageregion0{i}.pos, node0, imagesys.imageregion0{i}.I);
    end
  end

  if ~isempty(node2)
    for i = 1:length(imagesys.imageregion2)
        B2 = B2 + fB(imagesys.imageregion2{i}.pos, node2, imagesys.imageregion2{i}.I);
    end
  end
    induction_mag = struct("region0", B0, "region1", B1, "region2", B2);

end