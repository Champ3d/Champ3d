function WfVF = f_wfvf(mesh,varargin)
% F_WFVF returns the mass matrix related to Wf.VF
%--------------------------------------------------------------------------
% WfVF = F_WFVF(mesh,'vector_field',VF,'IDElem',[1 2 3]);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'mesh','vector_field','id_elem'};

% --- default input value
id_elem   = [];
vector_field = [];


for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
con = f_connexion(mesh.elem_type);
nbFa_inEl = con.nbFa_inEl;
nbElem    = mesh.nbElem;
nbFace    = mesh.nbFace;
if isempty(id_elem)
    id_elem = 1:nbElem;
end
%--------------------------------------------------------------------------
SWfVF = zeros(nbFa_inEl,nbElem);
if ~isempty(vector_field)
    for iG = 1:con.nbG
        for i = 1:nbFa_inEl
            SWfVF(i,id_elem) = SWfVF(i,id_elem) + ...
                                con.Weigh(iG).*mesh.detJ{iG}(1,id_elem) .* ...
                                (f_torowv(mesh.Wf{iG}(1,i,id_elem)).*vector_field(1,id_elem)+...
                                 f_torowv(mesh.Wf{iG}(2,i,id_elem)).*vector_field(2,id_elem)+...
                                 f_torowv(mesh.Wf{iG}(3,i,id_elem)).*vector_field(3,id_elem));
        end
    end
end
%--------------------------------------------------------------------------
WfVF = sparse(nbFace,1);

for i = 1:nbFa_inEl
    WfVF = WfVF + sparse(mesh.face_in_elem(i,:),1,SWfVF(i,:),nbFace,1);
end



end