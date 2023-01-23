function f_femm_setbc_rect(center,dimension,bc)

%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

sfac = 1e3; % scale factor

%--------------------------------------------------------------------------
%---left
cx = center(1) - dimension(1)/2;
cy = center(2);
dx = dimension(1) / sfac;
dy = dimension(2) * (1+sfac);
mi_selectrectangle(cx-dx/2,cy-dy/2,cx+dx/2,cy+dy/2,1);
%---right
cx = center(1) + dimension(1)/2;
cy = center(2);
dx = dimension(1) / sfac;
dy = dimension(2) * (1+sfac);
mi_selectrectangle(cx-dx/2,cy-dy/2,cx+dx/2,cy+dy/2,1);
%---bottom
cx = center(1);
cy = center(2) - dimension(2)/2;
dx = dimension(1) * (1+sfac);
dy = dimension(2) / sfac;
mi_selectrectangle(cx-dx/2,cy-dy/2,cx+dx/2,cy+dy/2,1);
%---up
cx = center(1);
cy = center(2) + dimension(2)/2;
dx = dimension(1) * (1+sfac);
dy = dimension(2) / sfac;
mi_selectrectangle(cx-dx/2,cy-dy/2,cx+dx/2,cy+dy/2,1);
%--------------------------------------------------------------------------
mi_setsegmentprop(bc,0,1,0,0);
%--------------------------------------------------------------------------
mi_clearselected;


% %--------------------------------------------------------------------------
% mi_selectsegment(center(1),center(2)-dimension(2)/2);
% mi_selectsegment(center(1),center(2)+dimension(2)/2);
% mi_selectsegment(center(1)-dimension(1)/2,center(2));
% mi_selectsegment(center(1)+dimension(1)/2,center(2));
% %--------------------------------------------------------------------------
% mi_setsegmentprop(bc,0,1,0,0);
% %--------------------------------------------------------------------------
% mi_clearselected;
