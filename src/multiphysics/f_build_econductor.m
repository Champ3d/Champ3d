function c3dobj = f_build_econductor(c3dobj,varargin)
% F_BUILD_ECONDUCTOR returns the matrix system
% related to econductor for A-phi formulation. 
%--------------------------------------------------------------------------
% c3dobj = F_BUILD_ECONDUCTOR(c3dobj,option);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_emdesign3d','id_econductor'};

% --- default input value
id_emdesign3d = [];
id_econductor = '_all';

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(id_emdesign3d)
    id_emdesign3d = fieldnames(c3dobj.emdesign3d);
    id_emdesign3d = id_emdesign3d{1};
end
%--------------------------------------------------------------------------
id_emdesign3d = f_to_scellargin(id_emdesign3d);
id_econductor = f_to_scellargin(id_econductor);
%--------------------------------------------------------------------------
for iem3d = 1:length(id_emdesign3d)
    if any(strcmpi(id_econductor,{'_all'}))
        id_econductor = fieldnames(c3dobj.emdesign3d.(id_emdesign3d{iem3d}).econductor);
    end
    for iec = 1:length(id_econductor)
        %------------------------------------------------------------------
        fprintf(['Building econ ' id_econductor{iec}]);
        tic;
        %------------------------------------------------------------------
        econ = c3dobj.emdesign3d.(id_emdesign3d{iem3d}).econductor.(id_econductor{iec});
        %------------------------------------------------------------------
        sig = econ.sigma;
        param_type = f_paramtype(sig);
        %------------------------------------------------------------------
        switch param_type
            case {'num_iso_coef'}
            case {'num_iso_array'}
            case {'fun_iso_array'}
            case {'num_aniso_coef'}
            case {'fun_aniso_array'}
                ltensor.main_value = f_callparameter(c3dobj,sig.main_value,'id_elem',IDElem);
                ltensor.ort1_value = f_callparameter(c3dobj,sig.ort1_value,'id_elem',IDElem);
                ltensor.ort2_value = f_callparameter(c3dobj,sig.ort2_value,'id_elem',IDElem);
                ltensor.main_dir   = f_callparameter(c3dobj,sig.main_dir,'id_elem',IDElem);
                ltensor.ort1_dir   = f_callparameter(c3dobj,sig.ort1_dir,'id_elem',IDElem);
                ltensor.ort2_dir   = f_callparameter(c3dobj,sig.ort2_dir,'id_elem',IDElem);
                gtensor = f_gtensor(ltensor);
        end
        %------------------------------------------------------------------
        % --- Log message
        fprintf(' --- in %.2f s \n',toc);
    end
end















%--------------------------------------------------------------------------
nbElem = c3dobj.mesh.nbElem;
nbEdge = c3dobj.mesh.nbEdge;
nbFace = c3dobj.mesh.nbFace;
nbNode = c3dobj.mesh.nbNode;
con = f_connexion(c3dobj.mesh.elem_type);
%--------------------------------------------------------------------------
if ~isfield(c3dobj.aphi,'SWeWe') || isempty(id_dom3d)
    c3dobj.aphi.SWeWe = sparse(nbEdge,nbEdge);
end
%--------------------------------------------------------------------------
% TODO : loop for each mesh type
iNoPhi = [];
if isfield(c3dobj,'econductor')
    nb_dom = length(c3dobj.econductor);
    if isempty(id_dom3d)
        for i = 1:nb_dom
            %---------------------------------------------
            fprintf(['Building econ ' c3dobj.econductor(i).id_dom3d '\n']);
            %---------------------------------------------
            IDElem = c3dobj.econductor(i).id_elem;
            iNoPhi = [iNoPhi reshape(c3dobj.mesh.elem(1:con.nbNo_inEl,IDElem),...
                                     1,con.nbNo_inEl*length(IDElem))];
            %---------------------------------------------
            sig = c3dobj.econductor(i).sigma;
            if isstruct(sig)
                ltensor.main_value = f_callparameter(c3dobj,sig.main_value,'id_elem',IDElem);
                ltensor.ort1_value = f_callparameter(c3dobj,sig.ort1_value,'id_elem',IDElem);
                ltensor.ort2_value = f_callparameter(c3dobj,sig.ort2_value,'id_elem',IDElem);
                ltensor.main_dir   = f_callparameter(c3dobj,sig.main_dir,'id_elem',IDElem);
                ltensor.ort1_dir   = f_callparameter(c3dobj,sig.ort1_dir,'id_elem',IDElem);
                ltensor.ort2_dir   = f_callparameter(c3dobj,sig.ort2_dir,'id_elem',IDElem);
                gtensor = f_gtensor(ltensor);
                c3dobj.econductor(i).gtensor = gtensor;
                c3dobj.aphi.SWeWe = c3dobj.aphi.SWeWe + ...
                        f_cwewe(c3dobj.mesh,'coef',c3dobj.econductor(i).gtensor,...
                          'id_elem',IDElem);
            elseif numel(sig) == 9
                c3dobj.econductor(i).gtensor = sig;
                c3dobj.aphi.SWeWe = c3dobj.aphi.SWeWe + ...
                        f_cwewe(c3dobj.mesh,'coef',c3dobj.econductor(i).gtensor,...
                          'id_elem',IDElem);
            end
        end
    else
        for i = 1:nb_dom
            if strcmpi(c3dobj.econductor(i).id_dom3d,id_dom3d)
                %---------------------------------------------
                fprintf(['Building econ ' c3dobj.econductor(i).id_dom3d '\n']);
                %---------------------------------------------
                IDElem = c3dobj.econductor(i).id_elem;
                iNoPhi = [iNoPhi reshape(c3dobj.mesh.elem(1:con.nbNo_inEl,IDElem),...
                                         1,con.nbNo_inEl*length(IDElem))];
                %---------------------------------------------
                sig = c3dobj.econductor(i).sigma;
                if isstruct(sig)
                    ltensor.main_value = f_calparam(c3dobj,sig.main_value,'id_elem',IDElem);
                    ltensor.ort1_value = f_calparam(c3dobj,sig.ort1_value,'id_elem',IDElem);
                    ltensor.ort2_value = f_calparam(c3dobj,sig.ort2_value,'id_elem',IDElem);
                    ltensor.main_dir   = f_calparam(c3dobj,sig.main_dir,'id_elem',IDElem);
                    ltensor.ort1_dir   = f_calparam(c3dobj,sig.ort1_dir,'id_elem',IDElem);
                    ltensor.ort2_dir   = f_calparam(c3dobj,sig.ort2_dir,'id_elem',IDElem);
                    gtensor = f_gtensor(ltensor);
                    c3dobj.econductor(i).gtensor = gtensor;
                    c3dobj.aphi.SWeWe = c3dobj.aphi.SWeWe + ...
                            f_cwewe(c3dobj.mesh,'coef',c3dobj.econductor(i).gtensor,...
                              'id_elem',IDElem);
                elseif numel(sig) == 9
                    c3dobj.econductor(i).gtensor = sig;
                    c3dobj.aphi.SWeWe = c3dobj.aphi.SWeWe + ...
                            f_cwewe(c3dobj.mesh,'coef',c3dobj.econductor(i).gtensor,...
                              'id_elem',IDElem);
                end
            end
        end
    end
    iNoPhi(iNoPhi == 0) = [];
    iNoPhi = unique(iNoPhi);
end
%--------------------------------------------------------------------------
c3dobj.aphi.id_node_phi = unique([c3dobj.aphi.id_node_phi iNoPhi]);
%--------------------------------------------------------------------------




