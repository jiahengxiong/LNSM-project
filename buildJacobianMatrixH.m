function H=buildJacobianMatrixH( parameters , UE , AP , TYPE , master, rho)
%buildJacobianMatrixH( parameters , uHat(iter,:) , cleared_AP , TYPE,  ref_rho(:, size(ref_rho, 2)), rho);
switch TYPE
    case 'TDOA'
        distanceUEAP=sqrt(sum((UE-AP).^2, 2));
        %direction cosine
        directionCosineX=((UE(1)-AP(:,1))./distanceUEAP);
        directionCosineY=((UE(2)-AP(:,2))./distanceUEAP);
        % directionCosineZ=((UE(3)-AP(:,3))./distanceUEAP);
         % H = zeros( parameters.numberOfAP , 3);
        H = zeros( size(AP, 1) , 2);
        for a=1:1:size(AP, 1)
            
                    % H(a,:) = [ directionCosineX(2) - directionCosineX(a), directionCosineY(2) - directionCosineY(a), directionCosineZ(2) - directionCosineZ(a)];% considering w as refAp
                                H(a,:) = -1 * [ directionCosineX(size(AP, 1)) - directionCosineX(a), directionCosineY(size(AP, 1)) - directionCosineY(a)];
           
        end
        
        H(size(H, 1),:)=[];
    case 'AOA'
        %% compute the distance between UE and APs
        distanceUEAP = sqrt( sum( [UE - AP].^2 , 2 ) ); 

        %% evaluate direction cosine
        directionCosineX = AP(:,1) - UE(1) ;
        directionCosineY = AP(:,2) - UE(2) ;

        %% build H
        H = zeros( size(AP, 1) , 2 );
        for a=1:1:size(AP, 1)
            H(a,:) = [ directionCosineY(a)/(distanceUEAP(a)^2) , -directionCosineX(a)/(distanceUEAP(a)^2) ];
        end
end