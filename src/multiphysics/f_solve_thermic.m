function dom3d = f_solve_thermic(dom3d,varargin)
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

% dom3d.Thermic.sflux_onbof = datin.sflux_onbof;
dom3d.Thermic.svolumic_in = datin.svolumic_in;
dom3d.Thermic.sfrom   = datin.sfrom;
dom3d.Thermic.id_bcon_temp = datin.id_bcon_temp;
dom3d.Thermic.delta_t = [dom3d.Thermic.delta_t datin.delta_t];


nbElem = dom3d.mesh.nbElem;
nbEdge = dom3d.mesh.nbEdge;
nbFace = dom3d.mesh.nbFace;
nbNode = dom3d.mesh.nbNode;
con = f_connexion(dom3d.mesh.elem_type);

coefrelax = 0.9; % faut adaptive


for istep = 1:datin.nb_heat_step
    dom3d.Thermic.time = dom3d.Thermic.time + dom3d.Thermic.delta_t;
    dom3d.Thermic.step = dom3d.Thermic.step + 1;
    prev_temp = dom3d.Thermic.Temp(dom3d.Thermic.step-1,dom3d.Thermic.id_node_temp).';
    epsilon = 1;
    iintern = 0;
    while epsilon > 1e-7
        iintern = iintern + 1;
        %--------------------------------------------------------------------------
        SWnWn = sparse(nbNode,nbNode);
        iFa_sFlux = [];
        iEl_sVolumic = [];
        if isfield(dom3d,'tconductor')
            nb_dom = length(dom3d.tconductor);
            for i = 1:nb_dom
                %------------------------------------------------------------------
                if isfield(dom3d.Thermic,'sflux_onbof')     % il faut laisser ?? au cas o? ??
                    if ismember(i,dom3d.Thermic.sflux_onbof)
                        iFa_sFlux = [iFa_sFlux reshape(dom3d.mesh.face_in_elem(1:con.nbFa_inEl,dom3d.tconductor(i).id_elem),...
                            1,con.nbFa_inEl*length(dom3d.tconductor(i).id_elem))];
                    end
                end
                %------------------------------------------------------------------
                if isfield(dom3d.Thermic,'svolumic_in')     % il faut laisser ?? au cas o? ??
                    if ismember(i,dom3d.Thermic.svolumic_in)
                        iEl_sVolumic = [iEl_sVolumic dom3d.tconductor(i).id_elem];
                    end
                end
                %------------------------------------------------------------------
                % update_rho
                if iintern > 1
                    if isfield(dom3d.tconductor(i).frho,'depend_on')
                        dom3d.tconductor(i).rho = dom3d.tconductor(i).frho.f(dom3d.(dom3d.tconductor(i).frho.from).(dom3d.tconductor(i).frho.depend_on)...
                                                  (dom3d.Thermic.step,dom3d.tconductor(i).id_elem)); % faut accepter n arg
                    elseif isfield(dom3d.tconductor(i).frho,'value')
                        dom3d.tconductor(i).rho = dom3d.tconductor(1).frho.value;
                    end
                else
                    if isfield(dom3d.tconductor(i).frho,'depend_on')
                        dom3d.tconductor(i).rho = dom3d.tconductor(i).frho.f(dom3d.(dom3d.tconductor(i).frho.from).(dom3d.tconductor(i).frho.depend_on)...
                                                  (dom3d.Thermic.step-1,dom3d.tconductor(i).id_elem)); % faut accepter n arg
                    elseif isfield(dom3d.tconductor(i).frho,'value')
                        dom3d.tconductor(i).rho = dom3d.tconductor(1).frho.value;
                    end
                end
                
                %------------------------------------------------------------------
                % update_cp
                if iintern > 1
                    if isfield(dom3d.tconductor(i).fcp,'depend_on')
                        dom3d.tconductor(i).cp = dom3d.tconductor(i).fcp.f(dom3d.(dom3d.tconductor(i).fcp.from).(dom3d.tconductor(i).fcp.depend_on)...
                                                  (dom3d.Thermic.step,dom3d.tconductor(i).id_elem)); % faut accepter n arg
                    elseif isfield(dom3d.tconductor(i).fcp,'value')
                        dom3d.tconductor(i).cp = dom3d.tconductor(i).fcp.value;
                    end
                else
                    if isfield(dom3d.tconductor(i).fcp,'depend_on')
                        dom3d.tconductor(i).cp = dom3d.tconductor(i).fcp.f(dom3d.(dom3d.tconductor(i).fcp.from).(dom3d.tconductor(i).fcp.depend_on)...
                                                  (dom3d.Thermic.step-1,dom3d.tconductor(i).id_elem)); % faut accepter n arg
                    elseif isfield(dom3d.tconductor(i).fcp,'value')
                        dom3d.tconductor(i).cp = dom3d.tconductor(i).fcp.value;
                    end
                end
                
                SWnWn = SWnWn + ...
                    f_coefWnWn(dom3d.mesh,'coef',dom3d.tconductor(i).rho .* dom3d.tconductor(i).cp ./ dom3d.Thermic.delta_t,...
                    'id_elem',dom3d.tconductor(i).id_elem,'elem_type',dom3d.mesh.elem_type);
                
            end
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
                if isfield(dom3d.tconductor(i).flambda.main_value,'depend_on')
                    if iintern > 1
                        ltensor.main_value = dom3d.tconductor(i).flambda.main_value.f(dom3d.(dom3d.tconductor(i).flambda.main_value.from).(dom3d.tconductor(i).flambda.main_value.depend_on)...
                                             (dom3d.Thermic.step,dom3d.tconductor(i).id_elem)); % faut accepter n arg
                        ltensor.ort1_value = dom3d.tconductor(i).flambda.ort1_value.f(dom3d.(dom3d.tconductor(i).flambda.ort1_value.from).(dom3d.tconductor(i).flambda.ort1_value.depend_on)...
                                             (dom3d.Thermic.step,dom3d.tconductor(i).id_elem));
                        ltensor.ort2_value = dom3d.tconductor(i).flambda.ort2_value.f(dom3d.(dom3d.tconductor(i).flambda.ort2_value.from).(dom3d.tconductor(i).flambda.ort2_value.depend_on)...
                                             (dom3d.Thermic.step,dom3d.tconductor(i).id_elem));
                    else
                        ltensor.main_value = dom3d.tconductor(i).flambda.main_value.f(dom3d.(dom3d.tconductor(i).flambda.main_value.from).(dom3d.tconductor(i).flambda.main_value.depend_on)...
                                             (dom3d.Thermic.step-1,dom3d.tconductor(i).id_elem)); % faut accepter n arg
                        ltensor.ort1_value = dom3d.tconductor(i).flambda.ort1_value.f(dom3d.(dom3d.tconductor(i).flambda.ort1_value.from).(dom3d.tconductor(i).flambda.ort1_value.depend_on)...
                                             (dom3d.Thermic.step-1,dom3d.tconductor(i).id_elem));
                        ltensor.ort2_value = dom3d.tconductor(i).flambda.ort2_value.f(dom3d.(dom3d.tconductor(i).flambda.ort2_value.from).(dom3d.tconductor(i).flambda.ort2_value.depend_on)...
                                             (dom3d.Thermic.step-1,dom3d.tconductor(i).id_elem));
                    end
                    ltensor.main_dir = dom3d.tconductor(i).flambda.main_dir;
                    ltensor.ort1_dir = dom3d.tconductor(i).flambda.ort1_dir;
                    ltensor.ort2_dir = dom3d.tconductor(i).flambda.ort2_dir;
                    gtensor = f_gtensor(ltensor); % accepter coef par morceau
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
        
        %---------------------- Matrix system -------------------------------------
        
        S = SWnWn + dom3d.mesh.G.' * SWeWe * dom3d.mesh.G + hWnWn;
        S = S(dom3d.Thermic.id_node_temp,dom3d.Thermic.id_node_temp);
        
        RHS = pWn(dom3d.Thermic.id_node_temp) + SWnWn(dom3d.Thermic.id_node_temp,dom3d.Thermic.id_node_temp) * ...
                                                dom3d.Thermic.Temp(dom3d.Thermic.step-1,dom3d.Thermic.id_node_temp).';
        
        actual_temp = gmres(S,RHS,5,1e-7,100,[],[],dom3d.Thermic.Temp(dom3d.Thermic.step-1,dom3d.Thermic.id_node_temp).');
        if iintern > 1
            epsilon = norm(actual_temp - prev_temp) / norm(prev_temp);
            fprintf('\n epsilon = %.2f E-7 \n', epsilon*1e7);
            actual_temp = actual_temp + (1-coefrelax) .* prev_temp;
        end
        dom3d.Thermic.Temp(dom3d.Thermic.step,dom3d.Thermic.id_node_temp) = actual_temp;
        prev_temp = actual_temp;
        dom3d.Thermic.elem_temp(dom3d.Thermic.step,:) = ...
            f_postpro3d(dom3d.mesh,dom3d.Thermic.Temp(dom3d.Thermic.step,:),'W0');
    end
    
end








