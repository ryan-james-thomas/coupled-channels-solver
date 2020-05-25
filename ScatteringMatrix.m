classdef ScatteringMatrix < handle
    properties
        mass
        E
        B
        k
        
        bv
        symmetry
        Sfull
        Tfull
        targetIndex
    end
    
    methods
        function self = ScatteringMatrix(Sin,BVin,symIn,targetIndex)
            self.bv = BVin;
            self.symmetry = symIn;
            self.targetIndex = targetIndex;
            self.Sfull = Sin;
            self.Tfull = Sin-repmat(eye(size(Sin(:,:,1))),[1,1,size(Sin,3)]); 
        end
        
        function set.E(self,E)
            tmp = E(:)*const.kb/1e6;
            self.E = E(:);
            self.k = sqrt(2*self.mass/const.hbar^2*tmp(:));  %#ok
        end
        
        function cs = crossSec(self,varargin)
            if nargin==1
                initState = self.bv(self.targetIndex,5:6);
                finalState = initState;
            elseif nargin==2
                initState = self.bv(self.targetIndex,5:6);
                finalState = varargin{1};
            elseif nargin==3
                initState = varargin{1};
                finalState = varargin{2};
            end
            cs = CalculatePartialCrossSection(self.Tfull,self.bv(:,[1,2,5,6]),self.k,initState,finalState,self.symmetry);
        end
        
        function B = subsref(self,S)
            idx1 = self.targetIndex;
            idx2 = idx1;
            for nn=1:numel(S)
                switch S(nn).type
                    case '.'
                        switch S(nn).subs
                            case 'S'
                                B = squeeze(self.Sfull(idx1,idx2,:));
                            case 'T'
                                B = squeeze(self.Tfull(idx1,idx2,:));
                            otherwise
                                B = builtin('subsref',self,S);
                                return;
                        end
                        
                    case '()'
                        if nn==1
                            if numel(S(nn).subs)==1
                                idx2 = S(nn).subs{1};
                            elseif numel(S(nn).subs)==4
                                idx2 = find(all(self.bv(:,[1,2,5,6])==repmat(cell2mat(S(nn).subs),size(self.bv,1),1),2));
                            elseif numel(S(nn).subs)==8
                                v = cell2mat(S(nn).subs);
                                v1 = v(1:4);v2 = v(5:8);
                                idx1 = find(all(self.bv(:,[1,2,5,6])==repmat(v1,size(self.bv,1),1),2));
                                idx2 = find(all(self.bv(:,[1,2,5,6])==repmat(v2,size(self.bv,1),1),2));
                            else
                                error('Index type not supported');
                            end
                        else
                            tmp = B;
                            B = subsref(tmp,S(nn));
                        end
                        
                    otherwise
                        error('Index type not supported');
                end
            end
        end
    end
    
    
end