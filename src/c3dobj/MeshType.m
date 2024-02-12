


classdef MeshType
    enumeration
        QuadMeshFrom1d, TriMeshFromFemm, TetraMeshFromGmsh, TriMeshFromShape2d, ...
        QuadMeshFromChQuad, TetraMeshFromShape3d, PrismMeshFromTriMesh, ...
        HexaMeshFromQuadMesh, HexaMeshFromGmsh
    end
end