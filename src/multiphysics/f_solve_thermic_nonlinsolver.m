function design3d = f_solve_thermic_nonlinsolver(design3d,varargin)
%---24/01/2023
% just updated in each time step not iterated
% based on f_solve_thermic
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------


for i = 1:(nargin-1)/2
    datin.(lower(varargin{2*i-1})) = varargin{2*i};
end

% dom3d.Thermic.sflux_onbof = datin.sflux_onbof;
design3d.Thermic.svolumic_in = datin.svolumic_in;
design3d.Thermic.sfrom   = datin.sfrom;
design3d.Thermic.id_bcon_temp = datin.id_bcon_temp;
%design3d.Thermic.delta_t = [design3d.Thermic.delta_t datin.delta_t];
design3d.Thermic.delta_t = datin.delta_t;
design3d.Thermic.time = 0;
design3d.Thermic.step = 0;

nbElem = design3d.mesh.nbElem;
nbEdge = design3d.mesh.nbEdge;
nbFace = design3d.mesh.nbFace;
nbNode = design3d.mesh.nbNode;
con = f_connexion(design3d.mesh.elem_type);

coefrelax = 0.9; % faut adaptive


for istep = 1:datin.nb_heat_step
    design3d.Thermic.time = design3d.Thermic.time + design3d.Thermic.delta_t;
    design3d.Thermic.step = design3d.Thermic.step + 1;
    prev_temp = design3d.Thermic.Temp(design3d.Thermic.step-1,design3d.Thermic.id_node_temp).';
    epsilon = 1;
    iintern = 0;
    while epsilon > 1e-7
        iintern = iintern + 1;
        %--------------------------------------------------------------------------
        SWnWn = sparse(nbNode,nbNode);
        iFa_sFlux = [];
        iEl_sVolumic = [];
        if isfield(design3d,'tconductor')
            nb_dom = length(design3d.tconductor);
            for i = 1:nb_dom
                %------------------------------------------------------------------
                if isfield(design3d.Thermic,'sflux_onbof')     % il faut laisser ?? au cas o? ??
                    if ismember(i,design3d.Thermic.sflux_onbof)
                        iFa_sFlux = [iFa_sFlux reshape(design3d.mesh.face_in_elem(1:con.nbFa_inEl,design3d.tconductor(i).id_elem),...
                            1,con.nbFa_inEl*length(design3d.tconductor(i).id_elem))];
                    end
                end
                %------------------------------------------------------------------
                if isfield(design3d.Thermic,'svolumic_in')     % il faut laisser ?? au cas o? ??
                    if ismember(i,design3d.Thermic.svolumic_in)
                        iEl_sVolumic = [iEl_sVolumic design3d.tconductor(i).id_elem];
                    end
                end
                %------------------------------------------------------------------
                % update_rho
                if iintern > 1
                    if isfield(design3d.tconductor(i).frho,'depend_on')
                        design3d.tconductor(i).rho = design3d.tconductor(i).frho.f(design3d.(design3d.tconductor(i).frho.from).(design3d.tconductor(i).frho.depend_on)...
                                                  (design3d.Thermic.step,design3d.tconductor(i).id_elem)); % faut accepter n arg
                    elseif isfield(design3d.tconductor(i).frho,'value')
                        design3d.tconductor(i).rho = design3d.tconductor(1).frho.value;
                    end
                else
                    if isfield(design3d.tconductor(i).frho,'depend_on')
                        design3d.tconductor(i).rho = design3d.tconductor(i).frho.f(design3d.(design3d.tconductor(i).frho.from).(design3d.tconductor(i).frho.depend_on)...
                                                  (design3d.Thermic.step-1,design3d.tconductor(i).id_elem)); % faut accepter n arg
                    elseif isfield(design3d.tconductor(i).frho,'value')
                        design3d.tconductor(i).rho = design3d.tconductor(1).frho.value;
                    end
                end
                
                %------------------------------------------------------------------
                % update_cp
                if iintern > 1
                    if isfield(design3d.tconductor(i).fcp,'depend_on')
                        design3d.tconductor(i).cp = design3d.tconductor(i).fcp.f(design3d.(design3d.tconductor(i).fcp.from).(design3d.tconductor(i).fcp.depend_on)...
                                                  (design3d.Thermic.step,design3d.tconductor(i).id_elem)); % faut accepter n arg
                    elseif isfield(design3d.tconductor(i).fcp,'value')
                        design3d.tconductor(i).cp = design3d.tconductor(i).fcp.value;
                    end
                else
                    if isfield(design3d.tconductor(i).fcp,'depend_on')
                        design3d.tconductor(i).cp = design3d.tconductor(i).fcp.f(design3d.(design3d.tconductor(i).fcp.from).(design3d.tconductor(i).fcp.depend_on)...
                                                  (design3d.Thermic.step-1,design3d.tconductor(i).id_elem)); % faut accepter n arg
                    elseif isfield(design3d.tconductor(i).fcp,'value')
                        design3d.tconductor(i).cp = design3d.tconductor(i).fcp.value;
                    end
                end
                
                SWnWn = SWnWn + ...
                    f_cWnWn(design3d.mesh,'coef',design3d.tconductor(i).rho .* design3d.tconductor(i).cp ./ design3d.Thermic.delta_t,...
                    'id_elem',design3d.tconductor(i).id_elem,'elem_type',design3d.mesh.elem_type);
                
            end
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
                if isfield(design3d.tconductor(i).flambda.main_value,'depend_on')
                    if iintern > 1
                        ltensor.main_value = design3d.tconductor(i).flambda.main_value.f(design3d.(design3d.tconductor(i).flambda.main_value.from).(design3d.tconductor(i).flambda.main_value.depend_on)...
                                             (design3d.Thermic.step,design3d.tconductor(i).id_elem)); % faut accepter n arg
                        ltensor.ort1_value = design3d.tconductor(i).flambda.ort1_value.f(design3d.(design3d.tconductor(i).flambda.ort1_value.from).(design3d.tconductor(i).flambda.ort1_value.depend_on)...
                                             (design3d.Thermic.step,design3d.tconductor(i).id_elem));
                        ltensor.ort2_value = design3d.tconductor(i).flambda.ort2_value.f(design3d.(design3d.tconductor(i).flambda.ort2_value.from).(design3d.tconductor(i).flambda.ort2_value.depend_on)...
                                             (design3d.Thermic.step,design3d.tconductor(i).id_elem));
                    else
                        ltensor.main_value = design3d.tconductor(i).flambda.main_value.f(design3d.(design3d.tconductor(i).flambda.main_value.from).(design3d.tconductor(i).flambda.main_value.depend_on)...
                                             (design3d.Thermic.step-1,design3d.tconductor(i).id_elem)); % faut accepter n arg
                        ltensor.ort1_value = design3d.tconductor(i).flambda.ort1_value.f(design3d.(design3d.tconductor(i).flambda.ort1_value.from).(design3d.tconductor(i).flambda.ort1_value.depend_on)...
                                             (design3d.Thermic.step-1,design3d.tconductor(i).id_elem));
                        ltensor.ort2_value = design3d.tconductor(i).flambda.ort2_value.f(design3d.(design3d.tconductor(i).flambda.ort2_value.from).(design3d.tconductor(i).flambda.ort2_value.depend_on)...
                                             (design3d.Thermic.step-1,design3d.tconductor(i).id_elem));
                    end
                    ltensor.main_dir = design3d.tconductor(i).flambda.main_dir;
                    ltensor.ort1_dir = design3d.tconductor(i).flambda.ort1_dir;
                    ltensor.ort2_dir = design3d.tconductor(i).flambda.ort2_dir;
                    gtensor = f_gtensor(ltensor); % accepter coef par morceau
                else
                    gtensor = f_gtensor(design3d.tconductor(i).lambda);
                end
                design3d.tconductor(i).gtensor = gtensor;
                SWeWe = SWeWe + ...
                    f_cWeWe(design3d.mesh,'coef',design3d.tconductor(i).gtensor,...
                    'id_elem',design3d.tconductor(i).id_elem,'elem_type',design3d.mesh.elem_type);
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
                            f_cWnsWns(design3d.mesh,'id_face',design3d.bcon(id_bcon).id_face,...
                            'coef',design3d.bcon(id_bcon).bc_coef);
                end
            end
        end
        
        %--------------------------------------------------------------------------
        pWn = sparse(nbNode,1);
        
        if ~isempty(iFa_sFlux)
            if strcmpi(design3d.Thermic.sfrom,'aphi')
                pWn = pWn + ...
                    f_cWns(design3d.mesh,'id_face',iFa_sFlux,...
                    'coef',design3d.aphi.pS);
            end
        end
        if ~isempty(iEl_sVolumic)
            if strcmpi(design3d.Thermic.sfrom,'aphi')
                pWn = pWn + ...
                    f_cWn(design3d.mesh,'id_elem',iEl_sVolumic,...
                    'coef',design3d.aphi.pV);
            end
        end
        
        %---------------------- Matrix system -------------------------------------
        
        S = SWnWn + design3d.mesh.G.' * SWeWe * design3d.mesh.G + hWnWn;
        S = S(design3d.Thermic.id_node_temp,design3d.Thermic.id_node_temp);
        
        RHS = pWn(design3d.Thermic.id_node_temp) + SWnWn(design3d.Thermic.id_node_temp,design3d.Thermic.id_node_temp) * ...
                                                design3d.Thermic.Temp(design3d.Thermic.step-1,design3d.Thermic.id_node_temp).';
        
        actual_temp = gmres(S,RHS,5,1e-7,100,[],[],design3d.Thermic.Temp(design3d.Thermic.step-1,design3d.Thermic.id_node_temp).');
        if iintern > 1
            epsilon = norm(actual_temp - prev_temp) / norm(prev_temp);
            fprintf('\n epsilon = %.2f E-7 \n', epsilon*1e7);
            actual_temp = actual_temp + (1-coefrelax) .* prev_temp;
        end
        design3d.Thermic.Temp(design3d.Thermic.step,design3d.Thermic.id_node_temp) = actual_temp;
        prev_temp = actual_temp;
        design3d.Thermic.elem_temp(design3d.Thermic.step,:) = ...
            f_postpro3d(design3d.mesh,design3d.Thermic.Temp(design3d.Thermic.step,:),'W0');
    end
    
end








