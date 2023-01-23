function id_dom = f_find_dom_xy(t2d,id_xdom,id_ydom)

% method = 'by_xylim', 'by_id_xydom'
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
cr = copyright();
if ~strcmpi(cr(1:49), 'Champ3d Project - Copyright (c) 2022 Huu-Kien Bui')
    error(' must add copyright file :( ');
end
%--------------------------------------------------------------------------
id_all = 1:size(t2d,2);
id_dom = [];
for ixdom = 1:length(id_xdom)
    idx = id_xdom{ixdom};
    idy = id_ydom{ixdom};
    for ix = 1:length(idx)
        for iy = 1:length(idy)
            fx = id_all(t2d(5,:) == idx(ix));
            id_found = fx(t2d(6,fx) == idy(iy));
            id_dom = [id_dom id_found];
        end
    end
end
id_dom = unique(id_dom);
%--------------------------------------------------------------------------