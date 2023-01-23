function dom3d = f_solveaphi(dom3d,varargin)
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA (Institut de recherche en Energie Electrique de Nantes Atlantique)
% Dep. Mesures Physiques, IUT of Saint Nazaire, University of Nantes
% 37, boulevard de l Universite, 44600 Saint Nazaire, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------
fprintf('Solving system ... \n');

% dom3d = f_solve_system(dom3d,'sol_option',sol_option);
% dom3d = f_solve_system(dom3d,'out_field',{'Flux','EMF','B','E','J'});

for i = 1:(nargin-1)/2
    eval([(lower(varargin{2*i-1})) '= varargin{2*i};']);
end

if ~exist('sol_option','var')
    sol_option.solver = 'qmr';
    sol_option.tolerance = 1e-7;
    sol_option.nb_iter = 1e4;
else
    if ~isfield(sol_option,'solver')
        sol_option.solver = 'qmr';
    end
    if ~isfield(sol_option,'tolerance')
        sol_option.tolerance = 1e-7;
    end
    if ~isfield(sol_option,'nb_iter')
        sol_option.nb_iter = 1e4;
    end
end

if ~exist('out_field','var')
    out_field = {'A','Phi','Flux','EMF','B','E','J','PVT','PST','pV','pS','coil','Energy','Voltage'};
end

tic
if strcmpi(sol_option.solver, 'qmr')
    [solution,flag,relres,iter,resvec] = f_qmr(dom3d.APhi.S,dom3d.APhi.RHS,sol_option);
end
fprintf('Time to inverse system : %.4f s \n',toc);

dom3d.APhi.flag = flag;
dom3d.APhi.relres = relres;
dom3d.APhi.iter = iter;
dom3d.APhi.resvec = resvec;
dom3d.APhi.residual = resvec/norm(dom3d.APhi.RHS);

tic
%----------------------------------------------------------------------
mu0 = 4*pi*1e-7;


if isfield(dom3d,'APhi')
    %----------------------------------------------------------------------
    A = zeros(dom3d.mesh.nbEdge,1);
    A(dom3d.APhi.id_edge_a) = solution(1:length(dom3d.APhi.id_edge_a));
%     if any(strcmpi(out_field,'A'))
%         dom3d.APhi.A = A;
%     end
    dom3d.APhi.A = f_postpro3d(dom3d.mesh,A,'W1');
    %----------------------------------------------------------------------
    Flux = dom3d.mesh.R * A;
    if any(strcmpi(out_field,'Flux'))
        dom3d.APhi.Flux = Flux;
    end
    %----------------------------------------------------------------------
    Phi = zeros(dom3d.mesh.nbNode,1);
    if length(solution) > length(dom3d.APhi.id_edge_a)
        Phi(dom3d.APhi.id_node_phi) = solution(length(dom3d.APhi.id_edge_a)+1:...
                                               length(dom3d.APhi.id_edge_a)+length(dom3d.APhi.id_node_phi));
    end
    if any(strcmpi(out_field,'coil'))
        if isfield(dom3d,'coil')
            nb_dom = length(dom3d.coil);
            dom3d.APhi.ICoil = zeros(1,nb_dom);
            for i = 1:nb_dom
                switch [dom3d.coil(i).coil_model dom3d.coil(i).coil_mode]
                    case 't3transmitter'
                        if length(solution) > length(dom3d.APhi.id_edge_a)+length(dom3d.APhi.id_node_phi)
                            dPhi = solution(length(dom3d.APhi.id_edge_a)+length(dom3d.APhi.id_node_phi)+1:end);
                            Voltage(i) = 1j*2*pi*dom3d.APhi.fr * dPhi;
                            Phi = Phi + 1/(1j*2*pi*dom3d.APhi.fr).*(dom3d.APhi.Alpha{i} .* Voltage(i));
                        end
                    case 't4transmitter'
                        Voltage(i) = dom3d.coil(i).v_petrode - dom3d.coil(i).v_netrode;
                        Phi = Phi + 1/(1j*2*pi*dom3d.APhi.fr).*(dom3d.APhi.Alpha{i} .* Voltage(i));
                end
            end
        end
    end
    %----------------------------------------------------------------------
    if any(strcmpi(out_field,'Phi'))
        dom3d.APhi.Phi = Phi;
    end
    %----------------------------------------------------------------------
    EMF = -(1j*2*pi*dom3d.APhi.fr).*(A + dom3d.mesh.G * Phi);
    if any(strcmpi(out_field,'EMF'))
        dom3d.APhi.EMF = EMF;
    end
    %----------------------------------------------------------------------
    dom3d.APhi.B = f_postpro3d(dom3d.mesh,Flux,'W2');
    dom3d.APhi.H = dom3d.APhi.B ./ mu0;
    %----------------------------------------------------------------------
    if any(strcmpi(out_field,'coil'))
        if isfield(dom3d,'coil')
            nb_dom = length(dom3d.coil);
            dom3d.APhi.ICoil = zeros(1,nb_dom);
            for i = 1:nb_dom
                switch [dom3d.coil(i).coil_model dom3d.coil(i).coil_mode]
                    case {'t1transmitter','t2transmitter','t1receiver','t2receiver'}
                        if dom3d.APhi.fr
                            dom3d.APhi.ZCoil(i) = 1j * 2*pi*dom3d.APhi.fr / dom3d.coil(i).i_coil.* ...
                                 sum(f_postpro3d(dom3d.mesh,A,'VInt_W1.vector_field',...
                                     'id_elem',dom3d.coil(i).id_elem,...
                                     'vector_field',dom3d.coil(i).N(:,dom3d.coil(i).id_elem)));
                        else
                            dom3d.APhi.L0Coil(i) = 1 / dom3d.coil(i).i_coil.* ...
                                 sum(f_postpro3d(dom3d.mesh,A,'VInt_W1.vector_field',...
                                     'id_elem',dom3d.coil(i).id_elem,...
                                     'vector_field',dom3d.coil(i).N(:,dom3d.coil(i).id_elem)));
                        end
                    case 't3transmitter'
                        dom3d.APhi.ICoil(i) = -((dom3d.APhi.SWeWe * EMF).')*(dom3d.mesh.G * dom3d.APhi.Alpha{i});
                        dom3d.APhi.VCoil(i) = Voltage(i);
                        dom3d.APhi.ZCoil(i) = dom3d.APhi.VCoil(i)/dom3d.APhi.ICoil(i);
                    case 't4transmitter'
                        dom3d.APhi.ICoil(i) = -((dom3d.APhi.SWeWe * EMF).')*(dom3d.mesh.G * dom3d.APhi.Alpha{i});
                        dom3d.APhi.VCoil(i) = dom3d.coil(i).v_petrode - dom3d.coil(i).v_netrode;
                        dom3d.APhi.ZCoil(i) = dom3d.APhi.VCoil(i)/dom3d.APhi.ICoil(i);
                    case 't3receiver'
                        dom3d.APhi.ICoil(i) = -((dom3d.APhi.SWeWe * EMF).')*(dom3d.mesh.G * dom3d.APhi.Alpha{i});
                    case 't4receiver'
                        dom3d.APhi.ICoil(i) = -((dom3d.APhi.SWeWe * EMF).')*(dom3d.mesh.G * dom3d.APhi.Alpha{i});
                end
            end
        end
    end
    %----------------------------------------------------------------------
%     if isfield(dom3d,'mconductor')
%         nb_dom = length(dom3d.mconductor);
%         for i = 1:nb_dom
%             if det(dom3d.mconductor(i).gtensor)
%                 gtinv = inv(dom3d.mconductor(i).gtensor);
%                 dom3d.APhi.H(1,dom3d.mconductor(i).id_elem) = ...
%                      gtinv(1,1) .* dom3d.APhi.B(1,:) + ...
%                      gtinv(1,2) .* dom3d.APhi.B(2,:) + ...
%                      gtinv(1,3) .* dom3d.APhi.B(3,:);
%                 dom3d.APhi.H(2,dom3d.mconductor(i).id_elem) = ...
%                      gtinv(2,1) .* dom3d.APhi.B(1,:) + ...
%                      gtinv(2,2) .* dom3d.APhi.B(2,:) + ...
%                      gtinv(2,3) .* dom3d.APhi.B(3,:);
%                 dom3d.APhi.H(3,dom3d.mconductor(i).id_elem) = ...
%                      gtinv(3,1) .* dom3d.APhi.B(1,:) + ...
%                      gtinv(3,2) .* dom3d.APhi.B(2,:) + ...
%                      gtinv(3,3) .* dom3d.APhi.B(3,:);
%             end
%         end
%     end
    %----------------------------------------------------------------------
    if any(strcmpi(out_field,'Energy'))
        %dom3d.APhi.Wm = 1/2 .* dom3d.mesh.v_elem .* ...
        %    (dom3d.APhi.B(1,:) .* dom3d.APhi.H(1,:) + ...
        %     dom3d.APhi.B(2,:) .* dom3d.APhi.H(2,:) + ...
        %     dom3d.APhi.B(3,:) .* dom3d.APhi.H(3,:));
        dom3d.APhi.Wm = 1/2 .* dom3d.mesh.v_elem .* ...
            f_norm(dom3d.APhi.B) .* f_norm(dom3d.APhi.H);
        dom3d.APhi.WmT = sum(dom3d.APhi.Wm);
    end
    %----------------------------------------------------------------------
    if any(strcmpi(out_field,'E'))
        dom3d.APhi.E = f_postpro3d(dom3d.mesh,EMF,'W1');
    end
    %----------------------------------------------------------------------
    if any(strcmpi(out_field,'J')) || any(strcmpi(out_field,'Pe')) ...
            || any(strcmpi(out_field,'pV')) || any(strcmpi(out_field,'pS'))
        if isfield(dom3d,'econductor')
            dom3d.APhi.J  = zeros(3,dom3d.mesh.nbElem);
            dom3d.APhi.pV = zeros(1,dom3d.mesh.nbElem);
            dom3d.APhi.PVT = 0;
            nb_dom = length(dom3d.econductor);
            for i = 1:nb_dom
                if det(dom3d.econductor(i).gtensor)
                    J = f_postpro3d(dom3d.mesh,EMF,'W1',...
                            'id_elem',dom3d.econductor(i).id_elem,...
                            'coef',dom3d.econductor(i).gtensor);
                    gtinv = inv(dom3d.econductor(i).gtensor);
                    pV = gtinv(1,1) .* conj(J(1,:)) .* J(1,:) + ...
                         gtinv(1,2) .* conj(J(1,:)) .* J(2,:) + ...
                         gtinv(1,3) .* conj(J(1,:)) .* J(3,:) + ...
                         gtinv(2,1) .* conj(J(2,:)) .* J(1,:) + ...
                         gtinv(2,2) .* conj(J(2,:)) .* J(2,:) + ...
                         gtinv(2,3) .* conj(J(2,:)) .* J(3,:) + ...
                         gtinv(3,1) .* conj(J(3,:)) .* J(1,:) + ...
                         gtinv(3,2) .* conj(J(3,:)) .* J(2,:) + ...
                         gtinv(3,3) .* conj(J(3,:)) .* J(3,:);
                    dom3d.APhi.J(1:3,dom3d.econductor(i).id_elem) = J;
                    dom3d.APhi.pV(1,dom3d.econductor(i).id_elem)  = real(pV);
                end
            end
            dom3d.APhi.PVT = sum(dom3d.APhi.pV .* dom3d.mesh.v_elem);
        end
        if isfield(dom3d,'bcon')
            dom3d.APhi.Js = zeros(2,dom3d.mesh.nbFace);
            dom3d.APhi.pS = zeros(1,dom3d.mesh.nbFace);
            nb_bcon = length(dom3d.bcon);
            for i = 1:nb_bcon
                if strcmpi(dom3d.bcon(i).bc_type,'sibc')
                    Js = f_postpro3d(dom3d.mesh,EMF,'W1_onFace',...
                            'id_face',dom3d.bcon(i).id_face,...
                            'coef',dom3d.bcon(i).gtsigma);
                    mu0 = 4*pi*1e-7;
                    sig = det(dom3d.bcon(i).gtsigma)^(1/3);
                    mu  = mu0 *  det(dom3d.bcon(i).gtmur)^(1/3);
                    skindepth = sqrt(2/(2*pi*dom3d.APhi.fr*mu*sig));
                    gtinv = inv(dom3d.bcon(i).gtsigma);
                    pS = gtinv(1,1) .* conj(Js(1,:)) .* Js(1,:) + ...
                         gtinv(1,2) .* conj(Js(1,:)) .* Js(2,:) + ...
                         gtinv(2,1) .* conj(Js(2,:)) .* Js(1,:) + ...
                         gtinv(2,2) .* conj(Js(2,:)) .* Js(2,:);
                    dom3d.APhi.pS(:,dom3d.bcon(i).id_face) = real(pS).*skindepth/2;
                    dom3d.APhi.Js(:,dom3d.bcon(i).id_face) = Js;
                end
            end
            dom3d.APhi.PST = sum(dom3d.APhi.pS .* dom3d.mesh.a_face);
        end
    end
    
end

fprintf('Time to perform post-processing : %.4f s \n',toc);


