function induction_mag = calculBregion(c0, I, xmir, ymir, mur, k, node)

    B1 = 0;
    B2 = 0;
    B0 = 0;

    imagesys = generateimage_brouillon(c0, I, xmir, ymir, mur, k);
    %imagesys = generateimage(c0, I, xmir, ymir, mur, k);
    id1 = (node(2,:) > ymir) & (node(1,:) <= xmir);
    id0 = (node(2,:) <= ymir) & (node(1,:) <= xmir);
    id2 = (node(2,:) <= ymir) & (node(1,:) > xmir);

    node1 = node(:,id1);
    node0 = node(:,id0);
    node2 = node(:,id2);



  if ~isempty(node1)
        figure;
        sgtitle(" region 1")
    for i = 1:length(imagesys.imageregion1)
        B1 = B1 + fB(imagesys.imageregion1{i}.pos, node1, imagesys.imageregion1{i}.I);
       
        subplot(length(imagesys.imageregion1),2,2*i-1);
        plot(node1(1,:), B1(1,:))
        title([' Bx Image ', num2str(i)])

         subplot(length(imagesys.imageregion1),2,2*i);
        plot(node1(1,:), B1(2,:))
        title([' By Image ', num2str(i)])
    end
  end



  if ~isempty(node0)
      figure;
      sgtitle("region 0")
    for i = 1:length(imagesys.imageregion0)
        B0 = B0 + fB(imagesys.imageregion0{i}.pos, node0, imagesys.imageregion0{i}.I);
        subplot(length(imagesys.imageregion0),2,2*i-1);
        plot(node0(1,:), B0(1,:))
        title([' Bx Image ', num2str(i)])

         subplot(length(imagesys.imageregion0),2,2*i);
        plot(node0(1,:), B0(2,:))
        title([' By Image ', num2str(i)])
    end
  end

  if ~isempty(node2)
      figure;
      sgtitle(" region 2")
    for i = 1:length(imagesys.imageregion2)
        B2 = B2 + fB(imagesys.imageregion2{i}.pos, node2, imagesys.imageregion2{i}.I);
        subplot(length(imagesys.imageregion2),2,2*i-1);
        plot(node2(1,:), B2(1,:))
        title(['Bx Image ', num2str(i)])

        subplot(length(imagesys.imageregion2),2,2*i);
        plot(node2(1,:), B2(2,:))
        title([' By Image ', num2str(i)])
    end
  end
    induction_mag = struct("region0", B0, "region1", B1, "region2", B2);

end