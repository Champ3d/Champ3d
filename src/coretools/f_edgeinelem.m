function [id_edge_in_elem, ori_edge_in_elem, sign_edge_in_elem] = f_edgeinelem(elem,edge_list,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'elem_type','get'};

% --- default input value
elem_type = [];
get = [];

% --- default output value
id_edge_in_elem = [];
ori_edge_in_elem = [];
sign_edge_in_elem = [];
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(elem_type)
    error([mfilename ' : #elem_type must be given !']);
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
nbNo_inEd = con.nbNo_inEd;
nbEd_inEl = con.nbEd_inEl;
EdNo_inEl = con.EdNo_inEl;
%--------------------------------------------------------------------------
nbElem = size(elem,2);
%--------------------------------------------------------------------------
e = reshape([elem(EdNo_inEl(:,1),:); elem(EdNo_inEl(:,2),:)], ...
             nbEd_inEl, nbNo_inEd, nbElem);
% ---
if any(strcmpi(get,{'topo','ori','orientation'}))
    ori_edge_in_elem = squeeze(sign(diff(e, 1, 2))); % with unsorted e !
end
% ---
e = sort(e, 2);
%--------------------------------------------------------------------------
id_edge_in_elem = f_findvecnd(e,edge_list,'position',2);
%--------------------------------------------------------------------------
if any(elem_type,{'tri','quad'})

end


end