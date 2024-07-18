function [uHat,numberOfPerformedIterations,count] = iterativeNLS( parameters , AP , TYPE , rho , uHatInit)


% NLS starting point - initial guess
%uHatInit = [ (rand-0.5)*parameters.xmax , (rand-0.5)*parameters.ymax ];
uHat = zeros( parameters.NiterMax , 2 );
delta=[];
H1=[];
delta1=[];
count=0;
switch TYPE
    case 'TDOA'
        ref_rho = [rho(1:rho(1, 10)-1), NaN, rho(rho(1, 10):end)];
        nan_indices = find(isnan(ref_rho(1:10)));
        ref_rho_no_nan = ref_rho(1:10);
        ref_rho_no_nan(nan_indices) = [];
        ref_rho = [ref_rho_no_nan, ref_rho(11:end)];
        AP(nan_indices, :) = [];
        ref_AP = [AP; parameters.positionAP(ref_rho(1, size(ref_rho, 2)), 1:2)];
        for iter = 1:parameters.NiterMax-1
            %% Step 1 - initial guess
            if iter==1
                uHat(iter,:) = uHatInit;
            end
            %% Step 2 - compute Jacobian matrix
            H = buildJacobianMatrixH( parameters , uHat(iter,:) , ref_AP , TYPE,  ref_rho(:, size(ref_rho, 2)), rho);
           
            %% Step 3 - compute the observation matrix and evaluate the difference delta rho
            h_uhat = measurementModel( parameters , uHat(iter,:) , ref_AP , TYPE , ref_rho(:, size(ref_rho, 2)));
            delta_rho = ref_rho(:, 1:size(ref_rho, 2)-1) - h_uhat;
            Ha=((H')*H)+0.001*eye(2);
           
            %% Step 4 - compute the correction
            %% NLS
            
            % if det(Ha)==0
            %  return
            % 
            % end
        
            delta_u = inv(Ha)*(H')*delta_rho';
            
          
            %% Step 5 - update the estimate
            uHat( iter+1 , : ) = uHat( iter , :) + 1 * delta_u';
        
            numberOfPerformedIterations = iter + 1;
            
            %% stopping criterion
            if sum( delta_u.^2 ) < 1e-9
                 return
            end       
        
        end
    case 'AOA'
        cleared_rho = rho;
        cleared_AP = AP;
        nan_indices = find(isnan(cleared_rho));
        cleared_rho(:, nan_indices) = [];
        cleared_AP(nan_indices, :) = [];
        
        for iter = 1:parameters.NiterMax-1
            %% Step 1 - initial guess
            if iter==1
                uHat(iter,:) = uHatInit;
            end
            %% Step 2 - compute Jacobian matrix
            H = buildJacobianMatrixH( parameters , uHat(iter,:) , cleared_AP , TYPE,  NaN, cleared_rho);
           
            %% Step 3 - compute the observation matrix and evaluate the difference delta rho
            h_uhat = measurementModel( parameters , uHat(iter,:) , cleared_AP , TYPE ,NaN);
            delta_rho = cleared_rho - h_uhat;
            Ha=((H')*H)+0.000001*eye(2);
           
            %% Step 4 - compute the correction
            %% NLS
            
            % if det(Ha)==0
            %  return
            % 
            % end
        
            delta_u = inv(Ha)*(H')*delta_rho';
            
          
            %% Step 5 - update the estimate
            uHat( iter+1 , : ) = uHat( iter , :) + 1 * delta_u';
        
            numberOfPerformedIterations = iter + 1;
            
            %% stopping criterion
            if sum( delta_u.^2 ) < 1e-9
                 return
            end       
        
        end
    case 'AOA+TDOA'
        aoa_sub = rho(:, 1:10);
        tdoa_sub = rho(:, 11:20);
        numNaN_aoa = sum(isnan(aoa_sub));
        numNaN_tdoa = sum(isnan(tdoa_sub));
        %%
        cleared_aoa = aoa_sub;
        cleared_AP = AP;
        nan_indices = find(isnan(cleared_aoa));
        cleared_aoa(:, nan_indices) = [];
        cleared_AP(nan_indices, :) = [];
        %%
        ref_rho = [tdoa_sub(1:tdoa_sub(1, 10)-1), NaN, tdoa_sub(tdoa_sub(1, 10):end)];
        nan_indices = find(isnan(ref_rho(1:10)));
        ref_rho_no_nan = ref_rho(1:10);
        ref_rho_no_nan(nan_indices) = [];
        ref_rho = [ref_rho_no_nan, ref_rho(11:end)];
        AP(nan_indices, :) = [];
        ref_AP = [AP; parameters.positionAP(ref_rho(1, size(ref_rho, 2)), 1:2)];
        for iter = 1:parameters.NiterMax-1
            H_aoa = [];
            H_tdoa = [];
            h_uhat_aoa = [];
            h_uhat_tdoa = [];
            if iter==1
                uHat(iter,:) = uHatInit;
            end
            if numNaN_aoa < 10
                H_aoa = buildJacobianMatrixH( parameters , uHat(iter,:) , cleared_AP , 'AOA',  NaN, cleared_aoa);
                h_uhat_aoa = measurementModel( parameters , uHat(iter,:) , cleared_AP , 'AOA' ,NaN);
            end
            if numNaN_tdoa < 9
                H_tdoa = buildJacobianMatrixH( parameters , uHat(iter,:) , ref_AP , 'TDOA',  ref_rho(:, size(ref_rho, 2)), tdoa_sub);
                h_uhat_tdoa = measurementModel( parameters , uHat(iter,:) , ref_AP , 'TDOA' , ref_rho(:, size(ref_rho, 2)));
            end
            H = [H_aoa;H_tdoa];
            h_uhat = [h_uhat_aoa,h_uhat_tdoa];
            delta_rho = [cleared_aoa, ref_rho(:, 1:size(ref_rho, 2)-1)] - h_uhat;
            Ha=((H')*H)+0.000001*eye(2);
           
            %% Step 4 - compute the correction
            %% NLS
            
            % if det(Ha)==0
            %  return
            % 
            % end
        
            delta_u = inv(Ha)*(H')*delta_rho';
            
          
            %% Step 5 - update the estimate
            uHat( iter+1 , : ) = uHat( iter , :) + 1 * delta_u';
        
            numberOfPerformedIterations = iter + 1;
            
            %% stopping criterion
            if sum( delta_u.^2 ) < 1e-9
                 return
            end 

        end
end

end