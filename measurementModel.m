function [ h ] = measurementModel(parameters,UE,AP,TYPE,master)

%% compute the distance between UE and APs
distanceUEAP = sqrt( sum( [UE-AP].^2 , 2 ) ); 
%% build the vector/matrix of observation
h = zeros( 1 , size(AP, 1) );
switch TYPE   
    case 'TDOA'
        for a = 1:size(AP, 1)
              h(a) = - distanceUEAP( size(AP, 1) ) + distanceUEAP( a );
                   
        end
        h(size(AP, 1))=[];
    case 'AOA'
        for a = 1:size(AP, 1)
            h(a) = atan2( ( UE(2)-AP(a,2) ) , ( UE(1)-AP(a,1) ) );
        end
    
end
