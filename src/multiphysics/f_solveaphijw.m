function dom3d = f_solveaphijw(dom3d,varargin)
%--------------------------------------------------------------------------
% Questions and inquiries can be addressed to the author:
% Dr. H-K. Bui
% Lab. IREENA (Institut de recherche en Energie Electrique de Nantes Atlantique)
% Dep. Mesures Physiques, IUT of Saint Nazaire, University of Nantes
% 37, boulevard de l Universite, 44600 Saint Nazaire, France
% Email : huu-kien.bui@univ-nantes.fr
% Copyright (c) 2019 Huu-Kien Bui. All Rights Reserved.
%--------------------------------------------------------------------------
fprintf('Solving A-Phi-jw system ... \n');

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
    [solution,flag,relres,iter,resvec] = f_qmr(dom3d.APhijw.S,dom3d.APhijw.RHS,sol_option);
end
fprintf('Time to inverse system : %.4f s \n',toc);

dom3d.APhijw.flag = flag;
dom3d.APhijw.relres = relres;
dom3d.APhijw.iter = iter;
dom3d.APhijw.resvec = resvec;
dom3d.APhijw.residual = resvec/norm(dom3d.APhijw.RHS);

tic
%----------------------------------------------------------------------
mu0 = 4*pi*1e-7;


if isfield(dom3d,'APhijw')
    %----------------------------------------------------------------------
    A = zeros(dom3d.mesh.nbEdge,1);
    A(dom3d.APhijw.id_edge_a) = solution(1:length(dom3d.APhijw.id_edge_a));
%     if any(strcmpi(out_field,'A'))
%         dom3d.APhijw.A = A;
%     end
    dom3d.APhijw.A = f_postpro3d(dom3d.mesh,A,'W1');
    %----------------------------------------------------------------------
    Flux = dom3d.mesh.R * A;
    if any(strcmpi(out_field,'Flux'))
        dom3d.APhijw.Flux = Flux;
    end
    %----------------------------------------------------------------------
    Phi = zeros(dom3d.mesh.nbNode,1);
    if length(solution) > length(dom3d.APhijw.id_edge_a)
        Phi(dom3d.APhijw.id_node_phi) = solution(length(dom3d.APhijw.id_edge_a)+1:...
                                               length(dom3d.APhijw.id_edge_a)+length(dom3d.APhijw.id_node_phi));
    end
    if any(strcmpi(out_field,'coil'))
        if isfield(dom3d,'coil')
            nb_dom = length(dom3d.coil);
            dom3d.APhijw.ICoil = zeros(1,nb_dom);
            for i = 1:nb_dom
                switch [dom3d.coil(i).coil_model dom3d.coil(i).coil_mode]
                    case 't3transmitter'
                        if length(solution) > length(dom3d.APhijw.id_edge_a)+length(dom3d.APhijw.id_node_phi)
                            dPhi = solution(length(dom3d.APhijw.id_edge_a)+length(dom3d.APhijw.id_node_phi)+1:end);
                            Voltage(i) = 1j*2*pi*dom3d.APhijw.fr * dPhi;
                            Phi = Phi + 1/(1j*2*pi*dom3d.APhijw.fr).*(dom3d.APhijw.Alpha{i} .* Voltage(i));
                        end
                    case 't4transmitter'
                        Voltage(i) = dom3d.coil(i).v_petrode - dom3d.coil(i).v_netrode;
                        Phi = Phi + 1/(1j*2*pi*dom3d.APhijw.fr).*(dom3d.APhijw.Alpha{i} .* Voltage(i));
                end
            end
        end
    end
    %----------------------------------------------------------------------
    if any(strcmpi(out_field,'Phi'))
        dom3d.APhijw.Phi = Phi;
    end
    %----------------------------------------------------------------------
    EMF = -(1j*2*pi*dom3d.APhijw.fr).*(A + dom3d.mesh.G * Phi);
    if any(strcmpi(out_field,'EMF'))
        dom3d.APhijw.EMF = EMF;
    end
    %----------------------------------------------------------------------
    dom3d.APhijw.B = f_postpro3d(dom3d.mesh,Flux,'W2');
    dom3d.APhijw.H = dom3d.APhijw.B ./ mu0;
    %----------------------------------------------------------------------
    if any(strcmpi(out_field,'coil'))
        if isfield(dom3d,'coil')
            nb_dom = length(dom3d.coil);
            dom3d.APhijw.ICoil = zeros(1,nb_dom);
            for i = 1:nb_dom
                switch [dom3d.coil(i).coil_model dom3d.coil(i).coil_mode]
                    case {'t1transmitter','t2transmitter','t1receiver','t2receiver'}
                        if dom3d.APhijw.fr
                            dom3d.APhijw.ZCoil(i) = 1j * 2*pi*dom3d.APhijw.fr / dom3d.coil(i).i_coil.* ...
                                 sum(f_postpro3d(dom3d.mesh,A,'VInt_W1.vector_field',...
                                     'id_elem',dom3d.coil(i).id_elem,...
                                     'vector_field',dom3d.coil(i).N(:,dom3d.coil(i).id_elem)));
                        else
                            dom3d.APhijw.L0Coil(i) = 1 / dom3d.coil(i).i_coil.* ...
                                 sum(f_postpro3d(dom3d.mesh,A,'VInt_W1.vector_field',...
                                     'id_elem',dom3d.coil(i).id_elem,...
                                     'vector_field',dom3d.coil(i).N(:,dom3d.coil(i).id_elem)));
                        end
                    case 't3transmitter'
                        dom3d.APhijw.ICoil(i) = -((dom3d.APhijw.SWeWe * EMF).')*(dom3d.mesh.G * dom3d.APhijw.Alpha{i});
                        dom3d.APhijw.VCoil(i) = Voltage(i);
                        dom3d.APhijw.ZCoil(i) = dom3d.APhijw.VCoil(i)/dom3d.APhijw.ICoil(i);
                    case 't4transmitter'
                        dom3d.APhijw.ICoil(i) = -((dom3d.APhijw.SWeWe * EMF).')*(dom3d.mesh.G * dom3d.APhijw.Alpha{i});
                        dom3d.APhijw.VCoil(i) = dom3d.coil(i).v_petrode - dom3d.coil(i).v_netrode;
                        dom3d.APhijw.ZCoil(i) = dom3d.APhijw.VCoil(i)/dom3d.APhijw.ICoil(i);
                    case 't3receiver'
                        dom3d.APhijw.ICoil(i) = -((dom3d.APhijw.SWeWe * EMF).')*(dom3d.mesh.G * dom3d.APhijw.Alpha{i});
                    case 't4receiver'
                        dom3d.APhijw.ICoil(i) = -((dom3d.APhijw.SWeWe * EMF).')*(dom3d.mesh.G * dom3d.APhijw.Alpha{i});
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
%                 dom3d.APhijw.H(1,dom3d.mconductor(i).id_elem) = ...
%                      gtinv(1,1) .* dom3d.APhijw.B(1,:) + ...
%                      gtinv(1,2) .* dom3d.APhijw.B(2,:) + ...
%                      gtinv(1,3) .* dom3d.APhijw.B(3,:);
%                 dom3d.APhijw.H(2,dom3d.mconductor(i).id_elem) = ...
%                      gtinv(2,1) .* dom3d.APhijw.B(1,:) + ...
%                      gtinv(2,2) .* dom3d.APhijw.B(2,:) + ...
%                      gtinv(2,3) .* dom3d.APhijw.B(3,:);
%                 dom3d.APhijw.H(3,dom3d.mconductor(i).id_elem) = ...
%                      gtinv(3,1) .* dom3d.APhijw.B(1,:) + ...
%                      gtinv(3,2) .* dom3d.APhijw.B(2,:) + ...
%                      gtinv(3,3) .* dom3d.APhijw.B(3,:);
%             end
%         end
%     end
    %----------------------------------------------------------------------
    if any(strcmpi(out_field,'Energy'))
        %dom3d.APhijw.Wm = 1/2 .* dom3d.mesh.v_elem .* ...
        %    (dom3d.APhijw.B(1,:) .* dom3d.APhijw.H(1,:) + ...
        %     dom3d.APhijw.B(2,:) .* dom3d.APhijw.H(2,:) + ...
        %     dom3d.APhijw.B(3,:) .* dom3d.APhijw.H(3,:));
        dom3d.APhijw.Wm = 1/2 .* dom3d.mesh.v_elem .* ...
            f_norm(dom3d.APhijw.B) .* f_norm(dom3d.APhijw.H);
        dom3d.APhijw.WmT = sum(dom3d.APhijw.Wm);
    end
    %----------------------------------------------------------------------
    if any(strcmpi(out_field,'E'))
        dom3d.APhijw.E = f_postpro3d(dom3d.mesh,EMF,'W1');
    end
    %----------------------------------------------------------------------
    if any(strcmpi(out_field,'J')) || any(strcmpi(out_field,'Pe')) ...
            || any(strcmpi(out_field,'pV')) || any(strcmpi(out_field,'pS'))
        if isfield(dom3d,'econductor')
            dom3d.APhijw.J  = zeros(3,dom3d.mesh.nbElem);
            dom3d.APhijw.pV = zeros(1,dom3d.mesh.nbElem);
            dom3d.APhijw.PVT = 0;
            nb_dom = length(dom3d.econductor);
            for i = 1:nb_dom
                J = f_postpro3d(dom3d.mesh,EMF,'W1',...
                        'id_elem',dom3d.econductor(i).id_elem,...
                        'coef',dom3d.econductor(i).gtensor);
                leng  = size(dom3d.econductor(i).gtensor,3);

                gtinv = zeros(3,3,leng);
                for iten = 1:leng
                    gtinv(:,:,iten) = inv(dom3d.econductor(i).gtensor(:,:,iten));
                end
                
                pV = squeeze(gtinv(1,1,:)).' .* conj(J(1,:)) .* J(1,:) + ...
                     squeeze(gtinv(1,2,:)).' .* conj(J(1,:)) .* J(2,:) + ...
                     squeeze(gtinv(1,3,:)).' .* conj(J(1,:)) .* J(3,:) + ...
                     squeeze(gtinv(2,1,:)).' .* conj(J(2,:)) .* J(1,:) + ...
                     squeeze(gtinv(2,2,:)).' .* conj(J(2,:)) .* J(2,:) + ...
                     squeeze(gtinv(2,3,:)).' .* conj(J(2,:)) .* J(3,:) + ...
                     squeeze(gtinv(3,1,:)).' .* conj(J(3,:)) .* J(1,:) + ...
                     squeeze(gtinv(3,2,:)).' .* conj(J(3,:)) .* J(2,:) + ...
                     squeeze(gtinv(3,3,:)).' .* conj(J(3,:)) .* J(3,:);
                dom3d.APhijw.J(1:3,dom3d.econductor(i).id_elem) = J;
                dom3d.APhijw.pV(1,dom3d.econductor(i).id_elem)  = real(pV);
            end
            dom3d.APhijw.PVT = sum(dom3d.APhijw.pV .* dom3d.mesh.v_elem);
        end
        if isfield(dom3d,'bcon')
            dom3d.APhijw.Js = zeros(2,dom3d.mesh.nbFace);
            dom3d.APhijw.pS = zeros(1,dom3d.mesh.nbFace);
            nb_bcon = length(dom3d.bcon);
            for i = 1:nb_bcon
                if strcmpi(dom3d.bcon(i).bc_type,'sibc')
                    Js = f_postpro3d(dom3d.mesh,EMF,'W1_onFace',...
                            'id_face',dom3d.bcon(i).id_face,...
                            'coef',dom3d.bcon(i).gtsigma);
                    mu0 = 4*pi*1e-7;
                    sig = det(dom3d.bcon(i).gtsigma)^(1/3);
                    mu  = mu0 *  det(dom3d.bcon(i).gtmur)^(1/3);
                    skindepth = sqrt(2/(2*pi*dom3d.APhijw.fr*mu*sig));
                    gtinv = inv(dom3d.bcon(i).gtsigma);
                    pS = gtinv(1,1) .* conj(Js(1,:)) .* Js(1,:) + ...
                         gtinv(1,2) .* conj(Js(1,:)) .* Js(2,:) + ...
                         gtinv(2,1) .* conj(Js(2,:)) .* Js(1,:) + ...
                         gtinv(2,2) .* conj(Js(2,:)) .* Js(2,:);
                    dom3d.APhijw.pS(:,dom3d.bcon(i).id_face) = real(pS).*skindepth/2;
                    dom3d.APhijw.Js(:,dom3d.bcon(i).id_face) = Js;
                end
            end
            dom3d.APhijw.PST = sum(dom3d.APhijw.pS .* dom3d.mesh.a_face);
        end
    end
    
end

fprintf('Time to perform post-processing : %.4f s \n',toc);


