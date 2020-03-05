function cross_sec=CalculatePartialCrossSection(T,BV,k,InitState,FinalState)
% CalculatePartialCrossSection Calculates partial cross sections 
%   cross_sec=CalculatePartialCrossSection(T,BV,k,InitState,FinalState) with T the
%   full T-matrix, BV the basis vectors of T, k the wavenumber, and
%   InitState and FinalState are denoted by the [Int1,Int2] state labels

InitIdx=FindState(BV(:,3:4),InitState);
FinalIdx=FindState(BV(:,3:4),FinalState);

InLRange=unique(BV(InitIdx,1));
OutLRange=unique(BV(FinalIdx,1));
OutMLRange=unique(BV(FinalIdx,2));

cross_sec=zeros(size(T,3),1);
for n1=1:numel(InLRange)
    for n2=1:numel(InLRange)
        for n3=1:numel(OutLRange)
            for n4=1:numel(OutMLRange)
                L1=InLRange(n1);
                L2=InLRange(n2);
                L=OutLRange(n3);
                mL=OutMLRange(n4);
                idx1=FindState(BV,[L1,0,InitState]);
                idx2=FindState(BV,[L2,0,InitState]);
                idx3=FindState(BV,[L,mL,FinalState]);
                cross_sec=cross_sec+squeeze(1i^(L2-L1).*sqrt((2*L1+1).*(2*L2+1)).*conj(T(idx3,idx1,:)).*T(idx3,idx2,:));
            end
        end
    end
end

cross_sec=pi./k.^2.*real(cross_sec);


