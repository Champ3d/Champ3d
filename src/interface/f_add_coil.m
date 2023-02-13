function design3d = f_add_coil(design3d,varargin)
% F_ADD_COIL ...
%--------------------------------------------------------------------------
% FIXED INPUT
% design3d : actual design
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'id_dom3d' : ids of 3D domains
% 'id_bcon'  : ids of the applied boundary condition
% 'id_elem'  : elements' ids (used if id_dom3d is not available)
% 'coil_mode' = 'transmitter' or 'receiver'
%     + use 'transmitter' for source coil
% 'etrode_type' : electrode type : 'close' or 'open'
%     + for 'close'-type coil
%         o 'cs_equation' : cross section equation
%     + for 'open'-type coil
%         o 'petrode_equation' : equation to define positive electrode nodes
%         o 'netrode_equation' : equation to define negative electrode nodes
% 'v_petrode' : positive electrode potential
% 'v_netrode' : negative electrode potential
% 'stype' : source type
%     + 'j' : impressed j
%         o 'jcoil' : given j
%         o 'cs_area' : cross section area
%     + 'i' : impressed i
%     + 'v' : impressed v
% 'field_vector_o' : coordinates of the origine of the field vector
% 'field_vector_v' : the field vector that indicates approximatively
%                    the orientation of the source field
%--------------------------------------------------------------------------
% OUTPUT
% design3d with added coil
%--------------------------------------------------------------------------
% EXAMPLE
% design3d = f_add_coil(design3d,'id_dom3d','coil',...
%                          'coil_type','stranded',...
%                          'coil_mode','transmitter',...
%                          'etrode_type','open',...
%                          'petrode_equation',{'z == max(z) & x < 0'},...
%                          'netrode_equation',{'z == max(z) & x > 0'},...
%                          'v_petrode',1,...
%                          'v_netrode',0,...
%                          'stype','j','j_coil',Icoil/coilSection,...
%                          'cs_area',coilSection,...
%                          'id_bcon',1);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'design3d','id_dom3d','id_elem','etrode_type',...
           'coil_mode','coil_type',...
           'cs_equation','petrode_equation','netrode_equation',...
           'field_vector_o','field_vector_v','nb_turn', ...
           'v_petrode','v_netrode','stype','cs_area','j_coil','i_coil','id_bcon'};
% --- default input value
if isempty(design3d)
    design3d.coil = [];
end
%--------------------------------------------------------------------------
if ~isfield(design3d,'coil')
    iec = 0;
else
    iec = length(design3d.coil);
end

%design3d.coil(iec+1).id_coil
design3d.coil(iec+1).id_dom3d = [];
design3d.coil(iec+1).id_elem  = [];
design3d.coil(iec+1).id_node  = [];
design3d.coil(iec+1).coil_mode = [];
design3d.coil(iec+1).coil_type = [];
design3d.coil(iec+1).etrode_type  = [];
design3d.coil(iec+1).cs_equation  = [];
design3d.coil(iec+1).petrode_equation = [];
design3d.coil(iec+1).netrode_equation = [];
design3d.coil(iec+1).v_petrode = 1;
design3d.coil(iec+1).v_netrode = 0;
design3d.coil(iec+1).stype = [];
design3d.coil(iec+1).cs_area = [];
design3d.coil(iec+1).j_coil = [];
design3d.coil(iec+1).i_coil = [];
design3d.coil(iec+1).nb_turn = [];
design3d.coil(iec+1).id_bcon = [];
design3d.coil(iec+1).field_vector_o = [];
design3d.coil(iec+1).field_vector_v = [];
%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename 'No coil to add!']);
end
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
    if strcmpi(varargin{2*i-1},'coil_option')
        coil_option = varargin{2*i};
        design3d.coil(iec+1) = f_addtostruct(coil_option,design3d.coil(iec+1));
    else
        if any(strcmpi(arglist,varargin{2*i-1}))
            design3d.coil(iec+1).(lower(varargin{2*i-1})) = varargin{2*i};
        else
            error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
        end
    end
end
%--------------------------------------------------------------------------

if ~isfield(design3d,'dom3d')
    error([mfilename ' : dom3d is not defined !']);
end

if isempty(design3d.coil(iec+1).id_dom3d)
    error([mfilename ' : id_dom3d must be defined !'])
end

if ~isfield(design3d.dom3d,design3d.coil(iec+1).id_dom3d)
    error([mfilename ' : ' id_dom3d ' is not defined !']);
end

%--------------------------------------------------------------------------
if isempty(design3d.coil(iec+1).coil_mode)
    design3d.coil(iec+1).coil_mode = 'transmitter';
end
if ~strcmpi(design3d.coil(iec+1).coil_mode,'transmitter') & ~strcmpi(design3d.coil(iec+1).coil_mode,'receiver')
    design3d.coil(iec+1).coil_mode = 'receiver';
end
%--------------------------------------------------------------------------
if isempty(design3d.coil(iec+1).i_coil)
    if isempty(design3d.coil(iec+1).cs_area) | isempty(design3d.coil(iec+1).j_coil)
        design3d.coil(iec+1).i_coil = 1;
    else
        design3d.coil(iec+1).i_coil = design3d.coil(iec+1).j_coil .* ...
                                      design3d.coil(iec+1).cs_area;
    end
end
%--------------------------------------------------------------------------
if isempty(design3d.coil(iec+1).nb_turn)
    design3d.coil(iec+1).nb_turn  = 1;
end
if isempty(design3d.coil(iec+1).cs_area)
    design3d.coil(iec+1).cs_area  = 1;
end
if isempty(design3d.coil(iec+1).j_coil)
    if ~isempty(design3d.coil(iec+1).i_coil) & ~isempty(design3d.coil(iec+1).nb_turn) & ~isempty(design3d.coil(iec+1).cs_area)
        design3d.coil(iec+1).j_coil = ...
            design3d.coil(iec+1).i_coil*design3d.coil(iec+1).nb_turn/design3d.coil(iec+1).cs_area;
    else
        design3d.coil(iec+1).j_coil = 0;
    end
end
%--------------------------------------------------------------------------

coilModel = [lower(design3d.coil(iec+1).coil_type), ...
             lower(design3d.coil(iec+1).stype)];

switch coilModel
    case {['stranded','j'],['massive','j']}
        %--------------------------
        if ~isempty(design3d.coil(iec+1).field_vector_v) & ~isempty(design3d.coil(iec+1).field_vector_o)
            design3d.coil(iec+1).coil_model = 't1';
        end
        %--------------------------
        if ~isempty(design3d.coil(iec+1).cs_equation)
            design3d.coil(iec+1).coil_model = 't2';
        end
        %--------------------------
        if ~isempty(design3d.coil(iec+1).petrode_equation) & ~isempty(design3d.coil(iec+1).netrode_equation)
            design3d.coil(iec+1).coil_model = 't2';
        end
    case ['massive','i']
        %--------------------------
%         if ~isempty(design3d.coil(iec+1).cs_equation)
%             design3d.coil(iec+1).coil_model = 't3';
%         end
        design3d.coil(iec+1).coil_model = 't3';
    case ['massive','v']
        %--------------------------
%         if ~isempty(design3d.coil(iec+1).cs_equation)
%             design3d.coil(iec+1).coil_model = 't4';
%         end
        design3d.coil(iec+1).coil_model = 't4';
end
%--------------------------------------------------------------------------
if isempty(design3d.coil(iec+1).id_elem)
    design3d.coil(iec+1).id_elem  = design3d.dom3d.(design3d.coil(iec+1).id_dom3d).id_elem;
else
    design3d.coil(iec+1).id_elem  = id_elem;
end
% ---
con = f_connexion(design3d.mesh.elem_type);
design3d.coil(iec+1).id_node = unique(design3d.mesh.elem(1:con.nbNo_inEl,design3d.coil(iec+1).id_elem));

%--------------------------------------------------------------------------
% coil_type = dom3d.coil(iec+1).coil_type;
etrode_type = design3d.coil(iec+1).etrode_type;
switch etrode_type
    case 'close'
        if ~isempty(design3d.coil(iec+1).cs_equation)
            if ~iscell(design3d.coil(iec+1).cs_equation)
                cs_equation{1} = design3d.coil(iec+1).cs_equation;
            else
                cs_equation = design3d.coil(iec+1).cs_equation;
            end
            geo = f_cutdom(design3d.mesh.node,design3d.mesh.elem(:,design3d.coil(iec+1).id_elem),...
                    'elem_type',design3d.mesh.elem_type,...
                    'cut_equation',cs_equation{1});
            geo.id_elem = design3d.coil(iec+1).id_elem(geo.id_elem); % !!!
            %------
            design3d.coil(iec+1).etrode = geo;
            design3d.coil(iec+1).petrode.id_elem = geo.id_elem;
            design3d.coil(iec+1).petrode.id_node = geo.node_positive;
            design3d.coil(iec+1).netrode.id_elem = geo.id_elem;
            design3d.coil(iec+1).netrode.id_node = geo.node_negative;
            design3d.coil(iec+1).id_elem = ...
                setdiff(design3d.coil(iec+1).id_elem,geo.id_elem);
            cutnode = f_uniquenode(design3d.mesh.elem(:,geo.id_elem),...
                          'nb_vertices',6);
            design3d.coil(iec+1).id_node = ...
                setdiff(design3d.coil(iec+1).id_node,cutnode);
            %------
        end
    case 'open'
        if ~isempty(design3d.coil(iec+1).petrode_equation)
            if ~iscell(design3d.coil(iec+1).petrode_equation)
                petrode_equation{1} = design3d.coil(iec+1).petrode_equation;
            else
                petrode_equation = design3d.coil(iec+1).petrode_equation;
            end
            for itrod = 1:length(design3d.coil(iec+1).petrode_equation)
                geo = f_findnode(design3d.mesh.node,design3d.mesh.elem(:,design3d.coil(iec+1).id_elem),...
                        'elem_type',design3d.mesh.elem_type,...
                        'cut_equation',petrode_equation{itrod});
                geo.id_elem = design3d.coil(iec+1).id_elem(geo.id_elem); % !!!
                %------
                design3d.coil(iec+1).petrode(itrod) = geo;
                %------
            end
        end
        if ~isempty(design3d.coil(iec+1).netrode_equation)
            if ~iscell(design3d.coil(iec+1).netrode_equation)
                netrode_equation{1} = design3d.coil(iec+1).netrode_equation;
            else
                netrode_equation = design3d.coil(iec+1).netrode_equation;
            end
            for itrod = 1:length(design3d.coil(iec+1).netrode_equation)
                geo = f_findnode(design3d.mesh.node,design3d.mesh.elem(:,design3d.coil(iec+1).id_elem),...
                        'elem_type',design3d.mesh.elem_type,...
                        'cut_equation',netrode_equation{itrod});
                geo.id_elem = design3d.coil(iec+1).id_elem(geo.id_elem); % !!!
                %------
                design3d.coil(iec+1).netrode(itrod) = geo;
                %------
            end
        end
end

