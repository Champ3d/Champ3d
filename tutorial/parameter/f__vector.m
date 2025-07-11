function vector_parameter = f__vector(x,varargin)

nb_elem = size(x,2);
vector_parameter = zeros(3,nb_elem);

vector_parameter(1,:) = 0;
vector_parameter(2,:) = 0;
vector_parameter(3,:) = 1 + 0 .* x(3,:);




    