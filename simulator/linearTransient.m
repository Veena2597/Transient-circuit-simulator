function [vplot] = linearTransient(LIN,NODES,INFO,PLOTNV,Y,J,X,LC,Voltages,location)
parser_init;
vplot=zeros(size(PLOTNV,1),size(0:INFO(TSTEP_):INFO(TSTOP_),1)); %for plotting voltages
k=1;
Il = zeros(size(LIN,1),1);
Ic = zeros(size(LIN,1),1);
v=1;
    for t=INFO(TSTEP_):INFO(TSTEP_):INFO(TSTOP_)
        v=1;
        Jc = J;
        for i=1:size(LIN,1)
            if(LIN(i,TYPE_) == C_)
                N1= LIN(i,C_N1_);
                N2= LIN(i,C_N2_);
                [N1,N2]= checkNode(NODES,N1,N2);
                disp([N1 N2]);
                %Ic is the Ieq value for capcitor BE companion model 
                if(N2<=0)
                    Ic(i) = X(N1)*LIN(i,C_VALUE_)/INFO(TSTEP_);
                    Jc(N1) = Jc(N1) + Ic(i);
                elseif(N1<=0)
                    Jc(N2) = Jc(N2) + X(N2)*LIN(i,C_VALUE_)/INFO(TSTEP_);
                elseif(N1>0 && N2>0)
                    Jc(N1) = Jc(N1) + (X(N1)-X(N2))*LIN(i,C_VALUE_)/INFO(TSTEP_);
                    Jc(N2) = Jc(N2) - (X(N1)-X(N2))*LIN(i,C_VALUE_)/INFO(TSTEP_);
                end
                
            elseif(LIN(i,TYPE_) == L_)
                N1= LIN(i,L_N1_);
                N2= LIN(i,L_N2_);
                [N1,N2]= checkNode(NODES,N1,N2);
                %Il is the Ieq value for inductor BE companion model
                if(N2<=0)
                    Il(i) = X(N1)*INFO(TSTEP_)/LIN(i,L_VALUE_);
                    Jc(N1) = Jc(N1) - Il(i);
                elseif(N1<=0)
                    Il(i) = -1*X(N2)*INFO(TSTEP_)/LIN(i,L_VALUE_);
                    Jc(N2) = Jc(N2)+ Il(i);
                elseif(N1>0 && N2>0)
                    Il(i) = (X(N1)-X(N2))*INFO(TSTEP_)/LIN(i,L_VALUE_);
                    Jc(N1) = Jc(N1) - Il(i);
                    Jc(N2) = Jc(N2) + Il(i);
                end
            
            elseif(LIN(i,TYPE_) == V_)
                if(LIN(i,V_TYPE_) == PWL_)
                    Jc(location(i)) = Voltages(v,ceil(t/INFO(TSTEP_))+1);
                    v=v+1;
                end
            end
        end
        
        %[L,U,P]= lu(Y,'vector');
        %temp = L\Jc(P);
        %X = U\temp;
        X=linsolve(Y,Jc);
        
        for j=1:size(PLOTNV,1)
            vplot(j,k) = X(PLOTNV(j,1));
        end
        k=k+1;
    end
end