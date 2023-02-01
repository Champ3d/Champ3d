function design3d = f_postprocessing_aphi(design3d,varargin)
% F_POSTPROCESSING_APHI returns the matrix system related to A-phi formulation. 
%--------------------------------------------------------------------------
% design3d = F_POSTPROCESSING_APHI(design3d,option);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- Electric Scalar Potential (V) ---------------------------------------
if isfield(design3d.aphi,'Phi')
    design3d.aphi.V = 1j*2*pi*design3d.aphi.fr .* design3d.aphi.Phi;
end
% --- Magnetic Vector Potential (A) ---------------------------------------
design3d.aphi.A = f_postpro3d(design3d.mesh,design3d.aphi.MVP,'W1');
% --- Flux ----------------------------------------------------------------
design3d.aphi.Flux = design3d.mesh.R * design3d.aphi.MVP;
% --- Electromotive Force (EMF) -------------------------------------------
design3d.aphi.EMF = -(1j*2*pi*design3d.aphi.fr).* ...
    (design3d.aphi.MVP + design3d.mesh.G * design3d.aphi.Phi);
%--------------------------------------------------------------------------
design3d.aphi.E = f_postpro3d(design3d.mesh,design3d.aphi.EMF,'W1');
%--------------------------------------------------------------------------
design3d.aphi.B = f_postpro3d(design3d.mesh,design3d.aphi.Flux,'W2');
%--------------------------------------------------------------------------
mu0 = 4*pi*1e-7;
design3d.aphi.H = (1/mu0) .* design3d.aphi.B;
if isfield(design3d,'mconductor')
    nb_dom = length(design3d.mconductor);
    for idom = 1:nb_dom
        nu = f_invtensor(mu0 .* design3d.mconductor(idom).gtensor);
        id_elem = design3d.mconductor(idom).id_elem;
        design3d.aphi.H(1,id_elem) = ...
                    squeeze(nu(1,1,:)).' .*design3d.aphi.B(1,id_elem) +...
                    squeeze(nu(1,2,:)).' .*design3d.aphi.B(2,id_elem) +...
                    squeeze(nu(1,3,:)).' .*design3d.aphi.B(3,id_elem);
        design3d.aphi.H(2,id_elem) = ...
                    squeeze(nu(2,1,:)).' .*design3d.aphi.B(1,id_elem) +...
                    squeeze(nu(2,2,:)).' .*design3d.aphi.B(2,id_elem) +...
                    squeeze(nu(2,3,:)).' .*design3d.aphi.B(3,id_elem);
        design3d.aphi.H(3,id_elem) = ...
                    squeeze(nu(3,1,:)).' .*design3d.aphi.B(1,id_elem) +...
                    squeeze(nu(3,2,:)).' .*design3d.aphi.B(2,id_elem) +...
                    squeeze(nu(3,3,:)).' .*design3d.aphi.B(3,id_elem);
    end
end
%--------------------------------------------------------------------------
% --- Energy
%dom3d.aphi.Wm = 1/2 .* dom3d.mesh.v_elem .* ...
%    (dom3d.aphi.B(1,:) .* dom3d.aphi.H(1,:) + ...
%     dom3d.aphi.B(2,:) .* dom3d.aphi.H(2,:) + ...
%     dom3d.aphi.B(3,:) .* dom3d.aphi.H(3,:));
design3d.aphi.Wm = 1/2 .* design3d.mesh.v_elem .* ...
    f_norm(design3d.aphi.B) .* f_norm(design3d.aphi.H);
design3d.aphi.WmT = sum(design3d.aphi.Wm);
%--------------------------------------------------------------------------
if isfield(design3d,'econductor')
    design3d.aphi.J  = zeros(3,design3d.mesh.nbElem);
    design3d.aphi.pV = zeros(1,design3d.mesh.nbElem);
    design3d.aphi.PVT = 0;
    nb_dom = length(design3d.econductor);
    for i = 1:nb_dom
        J = f_postpro3d(design3d.mesh,design3d.aphi.EMF,'W1',...
            'id_elem',design3d.econductor(i).id_elem,...
            'coef',design3d.econductor(i).gtensor);
        gtinv = f_invtensor(design3d.econductor(i).gtensor);
        pV = f_torowv(gtinv(1,1,:)) .* conj(J(1,:)) .* J(1,:) + ...
             f_torowv(gtinv(1,2,:)) .* conj(J(1,:)) .* J(2,:) + ...
             f_torowv(gtinv(1,3,:)) .* conj(J(1,:)) .* J(3,:) + ...
             f_torowv(gtinv(2,1,:)) .* conj(J(2,:)) .* J(1,:) + ...
             f_torowv(gtinv(2,2,:)) .* conj(J(2,:)) .* J(2,:) + ...
             f_torowv(gtinv(2,3,:)) .* conj(J(2,:)) .* J(3,:) + ...
             f_torowv(gtinv(3,1,:)) .* conj(J(3,:)) .* J(1,:) + ...
             f_torowv(gtinv(3,2,:)) .* conj(J(3,:)) .* J(2,:) + ...
             f_torowv(gtinv(3,3,:)) .* conj(J(3,:)) .* J(3,:);
        design3d.aphi.J(1:3,design3d.econductor(i).id_elem) = J;
        design3d.aphi.pV(1,design3d.econductor(i).id_elem)  = 1/2.*real(pV);
    end
    design3d.aphi.PVT = sum(design3d.aphi.pV .* design3d.mesh.v_elem);
end
if isfield(design3d,'bcon')
    design3d.aphi.Js = zeros(2,design3d.mesh.nbFace);
    design3d.aphi.pS = zeros(1,design3d.mesh.nbFace);
    nb_bcon = length(design3d.bcon);
    for i = 1:nb_bcon
        if strcmpi(design3d.bcon(i).bc_type,'sibc')
            Js = f_postpro3d(design3d.mesh,design3d.aphi.EMF,'W1_onFace',...
                'id_face',design3d.bcon(i).id_face,...
                'coef',design3d.bcon(i).gtsigma);
            mu0 = 4*pi*1e-7;
            sig = det(design3d.bcon(i).gtsigma)^(1/3);
            mu  = mu0 *  det(design3d.bcon(i).gtmur)^(1/3);
            skindepth = sqrt(2/(2*pi*design3d.aphi.fr*mu*sig));
            gtinv = f_invtensor(design3d.bcon(i).gtsigma);
            pS = gtinv(1,1,:) .* conj(Js(1,:)) .* Js(1,:) + ...
                 gtinv(1,2,:) .* conj(Js(1,:)) .* Js(2,:) + ...
                 gtinv(2,1,:) .* conj(Js(2,:)) .* Js(1,:) + ...
                 gtinv(2,2,:) .* conj(Js(2,:)) .* Js(2,:);
            design3d.aphi.pS(:,design3d.bcon(i).id_face) = real(pS).*skindepth/2;
            design3d.aphi.Js(:,design3d.bcon(i).id_face) = Js;
        end
    end
    design3d.aphi.PST = sum(design3d.aphi.pS .* design3d.mesh.a_face);
end


%--------------------------------------------------------------------------
% --- coil : ZCoil, L0Coil, ICoil, VCoil
if isfield(design3d,'coil')
    nb_dom = length(design3d.coil);
    design3d.aphi.ICoil = zeros(1,nb_dom);
    for idom = 1:nb_dom
        switch [design3d.coil(idom).coil_model design3d.coil(idom).coil_mode]
            case {'t1transmitter','t2transmitter','t1receiver','t2receiver'}
                if design3d.aphi.fr
                    design3d.aphi.ZCoil(idom) = 1j * 2*pi*design3d.aphi.fr / design3d.coil(idom).i_coil.* ...
                        sum(f_postpro3d(design3d.mesh,design3d.aphi.MVP,'VInt_W1.vector_field',...
                        'id_elem',design3d.coil(idom).id_elem,...
                        'vector_field',design3d.coil(idom).N(:,design3d.coil(idom).id_elem)));
                    design3d.aphi.LCoil(idom) = design3d.aphi.ZCoil(idom)./(1j*2*pi*design3d.aphi.fr);
                else
                    design3d.aphi.LCoil(idom) = 1 / design3d.coil(idom).i_coil.* ...
                        sum(f_postpro3d(design3d.mesh,design3d.aphi.MVP,'VInt_W1.vector_field',...
                        'id_elem',design3d.coil(idom).id_elem,...
                        'vector_field',design3d.coil(idom).N(:,design3d.coil(idom).id_elem)));
                end
            case 't3transmitter'
                design3d.aphi.ICoil(idom) = -((design3d.aphi.SWeWe * design3d.aphi.EMF).')*(design3d.mesh.G * design3d.aphi.Alpha{idom});
                design3d.aphi.VCoil(idom) = mean(design3d.aphi.V(design3d.coil(idom).petrode(1).id_node)) - ...
                                            mean(design3d.aphi.V(design3d.coil(idom).netrode(1).id_node));
                design3d.aphi.ZCoil(idom) = design3d.aphi.VCoil(idom)/design3d.aphi.ICoil(idom);
            case 't4transmitter'
                design3d.aphi.ICoil(idom) = -((design3d.aphi.SWeWe * design3d.aphi.EMF).')*(design3d.mesh.G * design3d.aphi.Alpha{idom});
                design3d.aphi.VCoil(idom) = design3d.coil(idom).v_petrode - design3d.coil(idom).v_netrode;
                design3d.aphi.ZCoil(idom) = design3d.aphi.VCoil(idom)/design3d.aphi.ICoil(idom);
            case 't3receiver'
                design3d.aphi.ICoil(idom) = -((design3d.aphi.SWeWe * design3d.aphi.EMF).')*(design3d.mesh.G * design3d.aphi.Alpha{idom});
            case 't4receiver'
                design3d.aphi.ICoil(idom) = -((design3d.aphi.SWeWe * design3d.aphi.EMF).')*(design3d.mesh.G * design3d.aphi.Alpha{idom});
        end
    end
end



