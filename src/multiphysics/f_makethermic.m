function design3d = f_makethermic(design3d,varargin)
% F_MAKETHERMIC returns the matrix system related to thermal formulation. 
%--------------------------------------------------------------------------
% System = F_MAKETHERMIC(dom3D,option);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'stype','sfrom','id_bcon_temp',...
           'delta_t','t_heat','t_end','sflux_onbof','svolumic_in'};

% --- default input value
stype = [];
sfrom = [];
id_bcon_temp = [];
delta_t = [];
t_heat = [];
t_end = [];
sflux_onbof = [];
svolumic_in = [];
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end


for i = 1:(nargin-1)/2
    datin.(lower(varargin{2*i-1})) = varargin{2*i};
end

design3d.Thermic.formulation = 'thermic';
design3d.Thermic.stype       = stype;
design3d.Thermic.sfrom       = sfrom;
design3d.Thermic.delta_t     = delta_t;
design3d.Thermic.t_heat      = t_heat;
design3d.Thermic.sflux_onbof = sflux_onbof;
design3d.Thermic.svolumic_in = svolumic_in;
design3d.Thermic.id_bcon_temp = id_bcon_temp;

if ~isfield(datin,'t_end')
    design3d.Thermic.t_end = t_heat;
else
    design3d.Thermic.t_end = t_end;
end


nbElem = design3d.mesh.nbElem;
nbEdge = design3d.mesh.nbEdge;
nbFace = design3d.mesh.nbFace;
nbNode = design3d.mesh.nbNode;
con = f_connexion(design3d.mesh.elem_type);

%--------------------------------------------------------------------------
SWnWn = sparse(nbNode,nbNode);
iNoTemp = [];
iFa_sFlux = [];
iEl_sVolumic = [];
if isfield(design3d,'tconductor')
    nb_dom = length(design3d.tconductor);
    for i = 1:nb_dom
        %------------------------------------------------------------------
        iNoTemp = [iNoTemp reshape(design3d.mesh.elem(1:con.nbNo_inEl,design3d.tconductor(i).id_elem),...
                                   1,con.nbNo_inEl*length(design3d.tconductor(i).id_elem))];
        %------------------------------------------------------------------
        if ~isempty(design3d.Thermic.sflux_onbof)
            if ismember(i,design3d.Thermic.sflux_onbof)
                iFa_sFlux = [iFa_sFlux reshape(design3d.mesh.face_in_elem(1:con.nbFa_inEl,design3d.tconductor(i).id_elem),...
                                       1,con.nbFa_inEl*length(design3d.tconductor(i).id_elem))];
            end
        end
        %------------------------------------------------------------------
        if ~isempty(design3d.Thermic.svolumic_in)
            if ismember(i,design3d.Thermic.svolumic_in)
                iEl_sVolumic = [iEl_sVolumic design3d.tconductor(i).id_elem];
            end
        end
        %------------------------------------------------------------------
        if isfield(datin,'update_rho')
            if isfield(datin.update_rho,'depend_on')
                design3d.tconductor(i).rho = design3d.tconductor(i).frho(design3d.(datin.update_rho.from).(datin.update_rho.depend_on)(design3d.tconductor(i).id_elem)); % faut accepter n arg
            elseif isfield(datin.update_rho,'value')
                design3d.tconductor(i).rho = datin.update_rho.value;
            end
        end
        
        if isfield(datin,'update_cp')
            if isfield(datin.update_cp,'depend_on')
                design3d.tconductor(i).cp = design3d.tconductor(i).fcp(design3d.(datin.update_cp.from).(datin.update_cp.depend_on)(design3d.tconductor(i).id_elem)); % faut accepter n arg
            elseif isfield(datin.update_cp,'value')
                design3d.tconductor(i).cp = datin.update_cp.value;
            end
        end
        
        SWnWn = SWnWn + ...
                f_cwnwn(design3d.mesh,'coef',design3d.tconductor(i).rho .* design3d.tconductor(i).cp ./ design3d.Thermic.delta_t,...
                  'id_elem',design3d.tconductor(i).id_elem);
        
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
if isfield(design3d,'tconductor')
    nb_dom = length(design3d.tconductor);
    for i = 1:nb_dom
        if isfield(datin,'update_lambda')
            if any(datin.update_lambda.id_tconductor == i)
                ltensor.main_value = design3d.tconductor(i).flambda.main_value(design3d.(datin.update_lambda.from).(datin.update_lambda.depend_on)(design3d.tconductor(i).id_elem)); % faut accepter n arg
                ltensor.ort1_value = design3d.tconductor(i).flambda.ort1_value(design3d.(datin.update_lambda.from).(datin.update_lambda.depend_on)(design3d.tconductor(i).id_elem));
                ltensor.ort2_value = design3d.tconductor(i).flambda.ort2_value(design3d.(datin.update_lambda.from).(datin.update_lambda.depend_on)(design3d.tconductor(i).id_elem));
                ltensor.main_dir = design3d.tconductor(i).flambda.main_dir;
                ltensor.ort1_dir = design3d.tconductor(i).flambda.ort1_dir;
                ltensor.ort2_dir = design3d.tconductor(i).flambda.ort2_dir;
                gtensor  = f_gtensor(ltensor); % accepter coef par mor?eau
            end
        else
            gtensor = f_gtensor(design3d.tconductor(i).lambda);
        end
        design3d.tconductor(i).gtensor = gtensor;
        SWeWe = SWeWe + ...
                f_cwewe(design3d.mesh,'coef',design3d.tconductor(i).gtensor,...
                  'id_elem',design3d.tconductor(i).id_elem);
    end
end

%--------------------------------------------------------------------------
hWnWn = sparse(nbNode,nbNode);

if isfield(design3d.Thermic,'id_bcon_temp')
    nb_bcon_temp = length(design3d.Thermic.id_bcon_temp);
    for i = 1:nb_bcon_temp
        id_bcon = design3d.Thermic.id_bcon_temp(i);
        switch lower(design3d.bcon(id_bcon).bc_type)
            case 'fixed'
            case 'neumann'
                %----- face
                hWnWn = hWnWn + ...
                    f_cwnswns(design3d.mesh,'id_face',design3d.bcon(id_bcon).id_face,...
                                            'coef',design3d.bcon(id_bcon).bc_coef);
        end
    end
end

%--------------------------------------------------------------------------
pWn = sparse(nbNode,1);

if ~isempty(iFa_sFlux)
    if strcmpi(design3d.Thermic.sfrom,'aphi')
        pWn = pWn + ...
                 f_cwns(design3d.mesh,'id_face',iFa_sFlux,...
                                      'coef',design3d.aphi.pS);
    end
end
if ~isempty(iEl_sVolumic)
    if strcmpi(design3d.Thermic.sfrom,'aphi')
        pWn = pWn + ...
                 f_cwn(design3d.mesh,'id_elem',iEl_sVolumic,...
                                     'coef',design3d.aphi.pV);
    end
end

%--------------------------------------------------------------------------

design3d.Thermic.id_node_temp = iNoTemp;


%---------------------- Matrix system -------------------------------------

S = SWnWn + design3d.mesh.G.' * SWeWe * design3d.mesh.G + hWnWn;

design3d.Thermic.S     = S(iNoTemp,iNoTemp);
design3d.Thermic.SWnWn = SWnWn(iNoTemp,iNoTemp);
design3d.Thermic.pWn   = pWn(iNoTemp);










