function [Y,Jc,LC,location] = lcStamp(LIN,NODES,INFO,Y,Jc,location)
parser_init;
LC = zeros(size(LIN,1),1);

    for i=1:size(LIN,1)
       if(LIN(i,TYPE_) == C_)
           N1= LIN(i,C_N1_);
           N2= LIN(i,C_N2_);
           [N1,N2]= checkNode(NODES,N1,N2);
           
           if(N1>0)
               Y(N1,N1)= Y(N1,N1)+ LIN(i,C_VALUE_)/INFO(TSTEP_);
           end
           if(N2>0)
               Y(N2,N2)= Y(N2,N2)+ LIN(i,C_VALUE_)/INFO(TSTEP_);
           end
           if(N1>0 && N2>0)
               Y(N1,N2)= Y(N1,N2) - LIN(i,C_VALUE_)/INFO(TSTEP_);
               Y(N2,N2)= Y(N2,N1) - LIN(i,C_VALUE_)/INFO(TSTEP_);
           end
           
        elseif(LIN(i,TYPE_) == L_)
           N1= LIN(i,L_N1_);
           N2= LIN(i,L_N2_);
           [N1,N2]= checkNode(NODES,N1,N2);
          
           if(N1>0)
               Y(N1,N1)= Y(N1,N1)+ INFO(TSTEP_)/LIN(i,L_VALUE_);
           end
           if(N2>0)
               Y(N2,N2)= Y(N2,N2)+ INFO(TSTEP_)/LIN(i,L_VALUE_);
           end
           if(N1>0 && N2>0)
               Y(N1,N2)= Y(N1,N2) - INFO(TSTEP_)/LIN(i,L_VALUE_);
               Y(N2,N2)= Y(N2,N1) - INFO(TSTEP_)/LIN(i,L_VALUE_);
           end
       end
    end
end