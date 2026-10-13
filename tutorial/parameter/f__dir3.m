function dir = f__dir3(x,varargin)

dir1 = f_dir1(x);
dir2 = f_dir2(x);
dir  = cross(dir1, dir2);