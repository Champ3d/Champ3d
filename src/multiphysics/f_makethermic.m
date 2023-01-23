function dom3d = f_makethermic(dom3d,varargin)
% F_MAKETHERMIC returns the matrix system related to thermal formulation. 
%--------------------------------------------------------------------------
% System = F_MAKETHERMIC(dom3D,option);
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA (Institut de recherche en Energie Electrique de Nantes Atlantique)
% Dep. Mesures Physiques, IUT of Saint Nazaire, University of Nantes
% 37, boulevard de l Universite, 44600 Saint Nazaire, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------

for i = 1:(nargin-1)/2
    datin.(lower(varargin{2*i-1})) = varargin{2*i};
end


dom3d.Thermic.formulation = 'thermic';
dom3d.Thermic.delta_t     = datin.delta_t;
dom3d.Thermic.t_heat      = datin.t_heat;

if ~isfield(datin,'t_end')
    dom3d.Thermic.t_end = datin.t_heat;
else
    dom3d.Thermic.t_end = datin.t_end;
end




nbElem = dom3d.mesh.nbElem;
nbEdge = dom3d.mesh.nbEdge;
nbFace = dom3d.mesh.nbFace;
nbNode = dom3d.mesh.nbNode;
con = f_connexion(dom3d.mesh.elem_type);

%--------------------------------------------------------------------------
SWnWn = sparse(nbNode,nbNode);
iNoTemp = [];
iFa_sFlux = [];
iEl_sVolumic = [];
if isfield(dom3d,'tconductor')
    nb_dom = length(dom3d.tconductor);
    for i = 1:nb_dom
        %------------------------------------------------------------------
        iNoTemp = [iNoTemp reshape(dom3d.mesh.elem(1:con.nbNo_inEl,dom3d.tconductor(i).id_elem),...
                                   1,con.nbNo_inEl*length(dom3d.tconductor(i).id_elem))];
        %------------------------------------------------------------------
        if isfield(dom3d.Thermic,'sflux_onbof')
            if ismember(i,dom3d.Thermic.sflux_onbof)
                iFa_sFlux = [iFa_sFlux reshape(dom3d.mesh.face_in_elem(1:con.nbFa_inEl,dom3d.tconductor(i).id_elem),...
                                       1,con.nbFa_inEl*length(dom3d.tconductor(i).id_elem))];
            end
        end
        %------------------------------------------------------------------
        if isfield(dom3d.Thermic,'svolumic_in')
            if ismember(i,dom3d.Thermic.svolumic_in)
                iEl_sVolumic = [iEl_sVolumic dom3d.tconductor(i).id_elem];
            end
        end
        %------------------------------------------------------------------
        if isfield(datin,'update_rho')
            if isfield(datin.update_rho,'depend_on')
                dom3d.tconductor(i).rho = dom3d.tconductor(i).frho(dom3d.(datin.update_rho.from).(datin.update_rho.depend_on)(dom3d.tconductor(i).id_elem)); % faut accepter n arg
            elseif isfield(datin.update_rho,'value')
                dom3d.tconductor(i).rho = datin.update_rho.value;
            end
        end
        
        if isfield(datin,'update_cp')
            if isfield(datin.update_cp,'depend_on')
                dom3d.tconductor(i).cp = dom3d.tconductor(i).fcp(dom3d.(datin.update_cp.from).(datin.update_cp.depend_on)(dom3d.tconductor(i).id_elem)); % faut accepter n arg
            elseif isfield(datin.update_cp,'value')
                dom3d.tconductor(i).cp = datin.update_cp.value;
            end
        end
        
        SWnWn = SWnWn + ...
                f_coefWnWn(dom3d.mesh,'coef',dom3d.tconductor(i).rho .* dom3d.tconductor(i).cp ./ dom3d.Thermic.delta_t,...
                  'id_elem',dom3d.tconductor(i).id_elem,'elem_type',dom3d.mesh.elem_type);
        
    end
    iNoTemp(iNoTemp == 0) = [];
    iNoTemp = unique(iNoTemp);
    iFa_sFlux(iFa_sFlux == 0) = [];
    iFa_sFlux = unique(iFa_sFlux);
    iEl_sVolumic(iEl_sVolumic == 0) = [];
    iEl_sVolumic = unique(iEl_sVolumic);
end
%--------------------------------------------------------------------------
SWeWe = sparse(nbEdge,nbEdge);
if isfield(dom3d,'tconductor')
    nb_dom = length(dom3d.tconductor);
    for i = 1:nb_dom
        if isfield(datin,'update_lambda')
            if any(datin.update_lambda.id_tconductor == i)
                ltensor.main_value = dom3d.tconductor(i).flambda.main_value(dom3d.(datin.update_lambda.from).(datin.update_lambda.depend_on)(dom3d.tconductor(i).id_elem)); % faut accepter n arg
                ltensor.ort1_value = dom3d.tconductor(i).flambda.ort1_value(dom3d.(datin.update_lambda.from).(datin.update_lambda.depend_on)(dom3d.tconductor(i).id_elem));
                ltensor.ort2_value = dom3d.tconductor(i).flambda.ort2_value(dom3d.(datin.update_lambda.from).(datin.update_lambda.depend_on)(dom3d.tconductor(i).id_elem));
                ltensor.main_dir = dom3d.tconductor(i).flambda.main_dir;
                ltensor.ort1_dir = dom3d.tconductor(i).flambda.ort1_dir;
                ltensor.ort2_dir = dom3d.tconductor(i).flambda.ort2_dir;
                gtensor  = f_gtensor(ltensor); % accepter coef par mor?eau
            end
        else
            gtensor = f_gtensor(dom3d.tconductor(i).lambda);
        end
        dom3d.tconductor(i).gtensor = gtensor;
        SWeWe = SWeWe + ...
                f_coefWeWe(dom3d.mesh,'coef',dom3d.tconductor(i).gtensor,...
                  'id_elem',dom3d.tconductor(i).id_elem,'elem_type',dom3d.mesh.elem_type);
    end
end

%--------------------------------------------------------------------------
hWnWn = sparse(nbNode,nbNode);

if isfield(dom3d.Thermic,'id_bcon_temp')
    nb_bcon_temp = length(dom3d.Thermic.id_bcon_temp);
    for i = 1:nb_bcon_temp
        id_bcon = dom3d.Thermic.id_bcon_temp(i);
        switch lower(dom3d.bcon(id_bcon).bc_type)
            case 'fixed'
            case 'neumann'
                %----- face
                hWnWn = hWnWn + ...
                    f_coefWnsWns(dom3d.mesh,'id_face',dom3d.bcon(id_bcon).id_face,...
                                            'coef',dom3d.bcon(id_bcon).bc_coef);
        end
    end
end

%--------------------------------------------------------------------------
pWn = sparse(nbNode,1);

if ~isempty(iFa_sFlux)
    if strcmpi(dom3d.Thermic.sfrom,'aphijw')
        pWn = pWn + ...
                 f_coefWns(dom3d.mesh,'id_face',iFa_sFlux,...
                                      'coef',dom3d.APhijw.pS);
    end
end
if ~isempty(iEl_sVolumic)
    if strcmpi(dom3d.Thermic.sfrom,'aphijw')
        pWn = pWn + ...
                 f_coefWn(dom3d.mesh,'id_elem',iEl_sVolumic,...
                                     'coef',dom3d.APhijw.pV);
    end
end

%--------------------------------------------------------------------------

dom3d.Thermic.id_node_temp = iNoTemp;


%---------------------- Matrix system -------------------------------------

S = SWnWn + dom3d.mesh.G.' * SWeWe * dom3d.mesh.G + hWnWn;

dom3d.Thermic.S     = S(iNoTemp,iNoTemp);
dom3d.Thermic.SWnWn = SWnWn(iNoTemp,iNoTemp);
dom3d.Thermic.pWn   = pWn(iNoTemp);










