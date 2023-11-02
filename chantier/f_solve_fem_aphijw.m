% function c3dobj = f_solve_fem_aphijw(c3dobj,varargin)
% %--------------------------------------------------------------------------
% % CHAMP3D PROJECT
% % Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% % Huu-Kien.Bui@univ-nantes.fr
% % Copyright (c) 2022 H-K. Bui, All Rights Reserved.
% %--------------------------------------------------------------------------
% 
% % --- valid argument list (to be updated each time modifying function)
% arglist = {'id_emdesign3d','options'};
% 
% % --- default input value
% id_emdesign3d = [];
% 
% % --- check and update input
% for i = 1:length(varargin)/2
%     if any(strcmpi(arglist,varargin{2*i-1}))
%         eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
%     else
%         error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
%     end
% end
% %--------------------------------------------------------------------------
% if isempty(id_emdesign3d)
%     error([mfilename ': #id_emdesign3d must be given']); 
% end
% %--------------------------------------------------------------------------
% if iscell(id_emdesign3d)
%     id_emdesign3d = id_emdesign3d{1};
% end





id_emdesign3d = 'em_multicubes';







%--------------------------------------------------------------------------
if isempty(id_emdesign3d)
    if isfield(c3dobj,'emdesign3d')
        id_emdesign3d__ = fieldnames(c3dobj.emdesign3d);
        if ~isempty(id_emdesign3d__)
            id_emdesign3d = id_emdesign3d__{1};
        end
    end
else
    if isfield(c3dobj,'emdesign3d')
        id_emdesign3d__ = fieldnames(c3dobj.emdesign3d);
        if ~any(strcmpi(id_emdesign3d,id_emdesign3d__))
            f_fprintf(0,'id_emdesign3d',1,id_emdesign3d,1,'invalid',0,'\n')
            return
        end
    end
end
%--------------------------------------------------------------------------
em_model = c3dobj.emdesign3d.(id_emdesign3d).em_model;
id_mesh3d = c3dobj.emdesign3d.(id_emdesign3d).id_mesh3d;
%--------------------------------------------------------------------------
if c3dobj.mesh3d.(id_mesh3d).to_be_rebuilt
    % --- mds
    c3dobj.mesh3d.(id_mesh3d) = ...
        f_meshds(c3dobj.mesh3d.(id_mesh3d));
    % --- intkit
    c3dobj.mesh3d.(id_mesh3d) = ...
        f_intkit3d(c3dobj.mesh3d.(id_mesh3d));
    % --- update
    c3dobj.mesh3d.(id_mesh3d).to_be_rebuilt = 0;
end
%--------------------------------------------------------------------------
if ~f_hasfields(c3dobj.mesh3d.(id_mesh3d),...
         {'intkit'})
    %----------------------------------------------------------------------
    c3dobj.mesh3d.(id_mesh3d) = ...
            f_intkit3d(c3dobj.mesh3d.(id_mesh3d));
    %----------------------------------------------------------------------
    if ~f_hasfields(c3dobj.mesh3d.(id_mesh3d).intkit,...
         {'cdetJ','cJinv','cWn','cgradWn','cWe','cWf',...
          'detJ','Jinv','Wn','gradWn','We','Wf'})
        c3dobj.mesh3d.(id_mesh3d) = ...
            f_intkit3d(c3dobj.mesh3d.(id_mesh3d));
    end
    %----------------------------------------------------------------------
end
%--------------------------------------------------------------------------
if ~f_hasfields(c3dobj.mesh3d.(id_mesh3d),...
         {'id_edge_in_elem','id_face_in_elem',...
          'div','rot','grad'})
    c3dobj.mesh3d.(id_mesh3d) = ...
        f_meshds(c3dobj.mesh3d.(id_mesh3d));
end
%--------------------------------------------------------------------------
nb_elem = size(c3dobj.mesh3d.(id_mesh3d).elem,2);
nb_face = size(c3dobj.mesh3d.(id_mesh3d).face,2);
nb_edge = size(c3dobj.mesh3d.(id_mesh3d).edge,2);
nb_node = size(c3dobj.mesh3d.(id_mesh3d).node,2);
%--------------------------------------------------------------------------
% Do this first
c3dobj.emdesign3d.(id_emdesign3d).matrix.id_edge_a = 1:nb_edge;
%--------------------------------------------------------------------------
% Then build nomesh
c3dobj = f_build_nomesh(c3dobj,'id_emdesign3d',id_emdesign3d);
%--------------------------------------------------------------------------
% Then build airbox
c3dobj = f_build_airbox(c3dobj,'id_emdesign3d',id_emdesign3d);
%--------------------------------------------------------------------------
% Then whatever order
c3dobj = f_build_econductor(c3dobj,'id_emdesign3d',id_emdesign3d);
c3dobj = f_build_mconductor(c3dobj,'id_emdesign3d',id_emdesign3d);
c3dobj = f_build_bsfield(c3dobj,'id_emdesign3d',id_emdesign3d);
%c3dobj = f_build_coil(c3dobj,'id_emdesign3d',id_emdesign3d);
%--------------------------------------------------------------------------
id_econductor__ = {};
id_mconductor__ = {};
id_airbox__     = {};
id_bc__         = {};
id_bsfield__    = {};
id_coil__       = {};
id_nomesh__     = {};
id_pmagnet__    = {};
% ---
if isfield(c3dobj.emdesign3d.(id_emdesign3d),'econductor')
    id_econductor__ = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).econductor);
end
% ---
if isfield(c3dobj.emdesign3d.(id_emdesign3d),'mconductor')
    id_mconductor__ = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).mconductor);
end
% ---
if isfield(c3dobj.emdesign3d.(id_emdesign3d),'airbox')
    id_airbox__ = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).airbox);
end
% ---
if isfield(c3dobj.emdesign3d.(id_emdesign3d),'bc')
    id_bc__ = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).bc);
end
% ---
if isfield(c3dobj.emdesign3d.(id_emdesign3d),'bsfield')
    id_bsfield__ = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).bsfield);
end
% ---
if isfield(c3dobj.emdesign3d.(id_emdesign3d),'coil')
    id_coil__ = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).coil);
end
% ---
if isfield(c3dobj.emdesign3d.(id_emdesign3d),'nomesh')
    id_nomesh__ = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).nomesh);
end
% ---
if isfield(c3dobj.emdesign3d.(id_emdesign3d),'pmagnet')
    id_pmagnet__ = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).pmagnet);
end
%--------------------------------------------------------------------------
tic;
f_fprintf(0,'Assembly',1,em_model,0,'\n');
%--------------------------------------------------------------------------
con = f_connexion(c3dobj.mesh3d.(id_mesh3d).elem_type);
nbEd_inEl = con.nbEd_inEl;
nbFa_inEl = con.nbFa_inEl;
id_edge_in_elem = c3dobj.mesh3d.(id_mesh3d).id_edge_in_elem;
id_face_in_elem = c3dobj.mesh3d.(id_mesh3d).id_face_in_elem;
%--------------------------------------------------------------------------
% --- wfwf
%--------------------------------------------------------------------------
no_wfwf = 0;
if ~isfield(c3dobj.emdesign3d.(id_emdesign3d),'matrix')
    no_wfwf = 1;
elseif ~isfield(c3dobj.emdesign3d.(id_emdesign3d).matrix,'wfwf')
    no_wfwf = 1;
elseif isempty(c3dobj.emdesign3d.(id_emdesign3d).matrix.wfwf)
    no_wfwf = 1;
end
% ---
if no_wfwf
    phydomobj.id_dom3d = 'all_domain';
    phydomobj.id_emdesign3d = id_emdesign3d;
    lmatrix = f_cwfwf(c3dobj,'phydomobj',phydomobj,'coefficient',1);
    % ---
    wfwf = sparse(nb_face,nb_face);
    for i = 1:nbFa_inEl
        for j = i+1 : nbFa_inEl
            wfwf = wfwf + ...
                sparse(id_face_in_elem(i,:),id_face_in_elem(j,:),...
                       lmatrix(:,i,j),nb_face,nb_face);
        end
    end
    % ---
    wfwf = wfwf + wfwf.';
    % ---
    for i = 1:nbFa_inEl
        wfwf = wfwf + ...
            sparse(id_face_in_elem(i,:),id_face_in_elem(i,:),...
                   lmatrix(:,i,i),nb_face,nb_face);
    end
end
% ---
c3dobj.emdesign3d.(id_emdesign3d).matrix.wfwf = wfwf;
%--------------------------------------------------------------------------
% --- econductor
sigwewe = sparse(nb_edge,nb_edge);
% ---
for iec = 1:length(id_econductor__)
    %--------------------------------------------------------------------------
    id_phydom = id_econductor__{iec};
    %--------------------------------------------------------------------------
    f_fprintf(0,'--- #econ',1,id_phydom,0,'\n');
    %--------------------------------------------------------------------------
    id_dom3d  = c3dobj.emdesign3d.(id_emdesign3d).econductor.(id_phydom).id_dom3d;
    id_elem   = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
    lmatrix   = c3dobj.emdesign3d.(id_emdesign3d).econductor.(id_phydom).sigwewe;
    for i = 1:nbEd_inEl
        for j = i+1 : nbEd_inEl
            sigwewe = sigwewe + ...
                sparse(id_edge_in_elem(i,id_elem),id_edge_in_elem(j,id_elem),...
                       lmatrix(:,i,j),nb_edge,nb_edge);
        end
    end
end
% ---
sigwewe = sigwewe + sigwewe.';
% ---
for iec = 1:length(id_econductor__)
    %--------------------------------------------------------------------------
    id_phydom = id_econductor__{iec};
    %--------------------------------------------------------------------------
    id_dom3d  = c3dobj.emdesign3d.(id_emdesign3d).econductor.(id_phydom).id_dom3d;
    id_elem   = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
    lmatrix   = c3dobj.emdesign3d.(id_emdesign3d).econductor.(id_phydom).sigwewe;
    for i = 1:nbEd_inEl
        sigwewe = sigwewe + ...
            sparse(id_edge_in_elem(i,id_elem),id_edge_in_elem(i,id_elem),...
                   lmatrix(:,i,i),nb_edge,nb_edge);
    end
end
%--------------------------------------------------------------------------
% --- mconductor
nu0nurwfwf = sparse(nb_face,nb_face);
% ---
for iec = 1:length(id_mconductor__)
    %--------------------------------------------------------------------------
    id_phydom = id_mconductor__{iec};
    %--------------------------------------------------------------------------
    f_fprintf(0,'--- #mcon',1,id_phydom,0,'\n');
    %--------------------------------------------------------------------------
    id_dom3d  = c3dobj.emdesign3d.(id_emdesign3d).mconductor.(id_phydom).id_dom3d;
    id_elem   = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
    lmatrix   = c3dobj.emdesign3d.(id_emdesign3d).mconductor.(id_phydom).nu0nurwfwf;
    for i = 1:nbFa_inEl
        for j = i+1 : nbFa_inEl
            nu0nurwfwf = nu0nurwfwf + ...
                sparse(id_face_in_elem(i,id_elem),id_face_in_elem(j,id_elem),...
                       lmatrix(:,i,j),nb_face,nb_face);
        end
    end
end
% ---
nu0nurwfwf = nu0nurwfwf + nu0nurwfwf.';
% ---
for iec = 1:length(id_mconductor__)
    %--------------------------------------------------------------------------
    id_phydom = id_mconductor__{iec};
    %--------------------------------------------------------------------------
    id_dom3d  = c3dobj.emdesign3d.(id_emdesign3d).mconductor.(id_phydom).id_dom3d;
    id_elem   = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
    lmatrix   = c3dobj.emdesign3d.(id_emdesign3d).mconductor.(id_phydom).nu0nurwfwf;
    for i = 1:nbFa_inEl
        nu0nurwfwf = nu0nurwfwf + ...
            sparse(id_face_in_elem(i,id_elem),id_face_in_elem(i,id_elem),...
                   lmatrix(:,i,i),nb_face,nb_face);
    end
end
%--------------------------------------------------------------------------
% --- bsfield
a_bsfield = zeros(nb_edge,1);
for iec = 1:length(id_bsfield__)
    %----------------------------------------------------------------------
    wfbs = sparse(nb_face,1);
    %----------------------------------------------------------------------
    id_phydom = id_bsfield__{iec};
    %----------------------------------------------------------------------
    f_fprintf(0,'--- #bsfield',1,id_phydom,0,'\n');
    %----------------------------------------------------------------------
    id_dom3d  = c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_phydom).id_dom3d;
    id_elem   = c3dobj.mesh3d.(id_mesh3d).dom3d.(id_dom3d).id_elem;
    lmatrix   = c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_phydom).wfbs;
    for i = 1:nbFa_inEl
        wfbs = wfbs + ...
               sparse(id_face_in_elem(i,id_elem),1,lmatrix(:,i),nb_face,1);
    end
    %----------------------------------------------------------------------
    rotb = c3dobj.mesh3d.(id_mesh3d).rot.' * wfbs;
    rotrot = c3dobj.mesh3d.(id_mesh3d).rot.' * ...
             c3dobj.emdesign3d.(id_emdesign3d).matrix.wfwf * ...
             c3dobj.mesh3d.(id_mesh3d).rot;
    %----------------------------------------------------------------------
    if isempty(c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_phydom).id_airbox)
        id_airbox__ = fieldnames(c3dobj.emdesign3d.(id_emdesign3d).airbox);
        c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_phydom).id_airbox = id_airbox__{1};
    end
    id_airbox = c3dobj.emdesign3d.(id_emdesign3d).bsfield.(id_phydom).id_airbox;
    id_edge_unknown = c3dobj.emdesign3d.(id_emdesign3d).airbox.(id_airbox).id_inner_edge;
    %----------------------------------------------------------------------
    rotb = rotb(id_edge_unknown,1);
    rotrot = rotrot(id_edge_unknown,id_edge_unknown);
    %----------------------------------------------------------------------
    a = zeros(nb_edge,1);
    a(id_edge_unknown) = f_qmr(rotrot,rotb);
    %----------------------------------------------------------------------
    a_bsfield = a_bsfield + a;
end

mflux = c3dobj.mesh3d.(id_mesh3d).rot * a_bsfield;

bs = f_field_wf(mflux,c3dobj.mesh3d.(id_mesh3d));

node = c3dobj.mesh3d.(id_mesh3d).celem;
vf = bs;
figure
f_quiver(node,full(vf));



%--------------------------------------------------------------------------
%--- Test symmetric
if issymmetric(sigwewe)
    f_fprintf(0,'sigwewe is symmetric \n');
end
if issymmetric(nu0nurwfwf)
    f_fprintf(0,'nu0nurwfwf is symmetric \n');
end
%--------------------------------------------------------------------------
%--- Log message
f_fprintf(0,'--- in',...
          1,toc, ...
          0,'s \n');




