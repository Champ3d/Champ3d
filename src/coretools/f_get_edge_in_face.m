function [edge_in_face, sign_edge_in_face] = f_get_edge_in_face(mesh3d,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'elem_type'};

% --- default input value
elem_type = [];

%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(elem_type) && isfield(mesh3d,'elem_type')
    elem_type = mesh3d.elem_type;
end
%--------------------------------------------------------------------------
if isempty(elem_type)
    nbnoinel = size(mesh3d.elem, 1);
    switch nbnoinel
        case 4
            elem_type = 'tet';
        case 6
            elem_type = 'prism';
        case 8
            elem_type = 'hex';
    end
    fprintf(['Build meshds for ' elem_type ' \n']);
end
%--------------------------------------------------------------------------
if ~isfield(mesh3d,'edge')
    mesh3d = f_get_edge(mesh3d);
elseif isempty(mesh3d.edge)
    mesh3d = f_get_edge(mesh3d);
end
%--------------------------------------------------------------------------
if ~isfield(mesh3d,'face')
    mesh3d = f_get_face(mesh3d);
elseif isempty(mesh3d.face)
    mesh3d = f_get_face(mesh3d);
end
%--------------------------------------------------------------------------
nbFace = size(mesh3d.face,2);
%--------------------------------------------------------------------------
if isempty(elem_type)
    error([mfilename ' : #elem_type must be given !']);
end
%--------------------------------------------------------------------------
con = f_connexion(elem_type);
siEd_inFa = con.siEd_inFa;
EdNo_inFa = con.EdNo_inFa;
nbEd_inFa = con.nbEd_inFa;
nbNo_inEd = con.nbNo_inEd;
%--------------------------------------------------------------------------
%----- face_edge
maxnbEd_inFa = max(cell2mat(nbEd_inFa));
fe = zeros(maxnbEd_inFa,nbNo_inEd,nbFace);
sign_edge_in_face = zeros(maxnbEd_inFa,nbFace);
itria = find(mesh3d.face(4,:) == 0);
iquad = setdiff(1:nbFace,itria);
for k = 1:2 %---- 2 faceType
    switch k
        case 1
            iface = itria;
        case 2
            iface = iquad;
    end
    for i = 1:nbEd_inFa{k}
        fet = [];
        for j = 1:nbNo_inEd
            fet = [fet; mesh3d.face(EdNo_inFa{k}(i,j),iface)];
        end
        fe(i,:,iface) = fet;
        sign_edge_in_face(i,iface) = siEd_inFa{k}(i) .* sign(fet(2,:)-fet(1,:));
    end
end

%--------------------------------------------------------------------------
edge_in_face = f_findvecnd(fe,mesh3d.edge,'position',2);
edge_in_face(isnan(edge_in_face)) = 0;
%--------------------------------------------------------------------------
% --- Outputs
% mesh3d.edge_in_face = edge_in_face;
% mesh3d.sign_edge_in_face = sign_edge_in_face;

end