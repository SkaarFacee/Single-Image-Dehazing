clc;
clear;
tic
for image_number=1:30
    imageName=strcat(num2str(image_number),'.jpg');
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The first step is to read the image and simply process it
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    I = imread(imageName);
    figure;
    %imshow(I);
    title(['First',num2str(image_number),'Original image']);

    % Normalized to [0,1]
    I = double(I)/255.0;  

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
    % Step 2: Find the minimum matrix M of the three channels of I
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    M = min(I,[],3);  

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 3: Perform mean filtering on M to get Mave(x)  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    [height,width] = size(I);  
    mask = ceil(max(height, width) / 50);  
    if mod(mask, 2) == 0  
        mask = mask + 1;  
    end  
    f = fspecial('average', mask);  
    M_average = imfilter(M, f, 'symmetric');     

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 4: Find the mean value of all elements in M(x) Mav
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    [height, width] = size(M_average);  
    M_average_value = sum(sum(M_average)) / (height * width);  

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 5: Use M_average to find the ambient luminosity L 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    % The larger the delta value, the darker the image after defogging, the better the defogging effect
    % The smaller the delta value, the whiter the image after dehazing and the worse the dehazing effect
    delta = 2.0;    
    L = min ( min( delta*M_average_value,0.9)*M_average, M);  

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 6: Use M_average and I to find the global atmospheric light A
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    Matrix = [1;...
              1;...
              1];
    A = 0.5 * ( max( max( max(I, [], 3) ) ) + max( max(M_average) ) )*Matrix;  


    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 7: Use A, L and I to find the fog map
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [height, width, dimention] = size(I);  
    I_defog = zeros(height,width,dimention);  
    for i = 1:dimention  
        I_defog(:,:,i) = (I(:,:,i) - L) ./ (1 - L./A(i));  
    end  
    toc 
    figure;
    %imshow(I_defog);
    str1='new'
    str2=strcat(num2str(image_number),'.jpg')
    str=append(str1,str2)
    imwrite(I_defog,str)
    title(['First',num2str(image_number),'Dehazing image']);
    clc;
    clear;
end
    

