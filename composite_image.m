%%
% input a target picture and enter the target size and number of tiles.
clear;
clc;
input_picture = input("Input picture (str): ");
px = input('Length: ');
py = input('Width: ');
tx = input('Tile number length: ');
ty = input('Tile number width: ');
%%
% get RGB values of source images
S = [];
RGB = [];
file_path = 'source_images';
path_list = dir(strcat(file_path,'*.jpg'));
num = length(path_list);
if num>0
    for k = 1:num
        image_name = path_list(k).name;
        S = im2double(imread(strcat(file_path,image_name)));
        r1 = S(:,:,1);
        g1 = S(:,:,2);
        b1 = S(:,:,3);
        
        M = fspecial('gaussian',7,7/6);
        r1 = conv2(S(:,:,1),M,'same');
        g1 = conv2(S(:,:,2),M,'same');
        b1 = conv2(S(:,:,3),M,'same');

        [row,col] = size(r1);
        
        ru = mean2(r1(1:round(row/2),:));
        rd = mean2(r1(round(row/2):row,:));
        rl = mean2(r1(:,1:round(col/2)));
        rr = mean2(r1(:,round(col/2):col));
        
        gu = mean2(g1(1:round(row/2),:));
        gd = mean2(g1(round(row/2):row,:));
        gl = mean2(g1(:,1:round(col/2)));
        gr = mean2(g1(:,round(col/2):col));
        
        bu = mean2(b1(1:round(row/2),:));
        bd = mean2(b1(round(row/2):row,:));
        bl = mean2(b1(:,1:round(col/2)));
        br = mean2(b1(:,round(col/2):col));
        
        RGB = [RGB;ru,rd,rl,rr,gu,gd,gl,gr,bu,bd,bl,br,k];
    end
end
%%
% divide the target image
pixel_x = px;
pixel_y = py;
tile_x = tx;
tile_y = ty;

C = im2double(imread(input_picture));
M = fspecial('gaussian',7,7/6);
Cr = conv2(C(:,:,1),M,'same');
Cg = conv2(C(:,:,2),M,'same');
Cb = conv2(C(:,:,3),M,'same');
C = [];
C(:,:,1) = Cr;
C(:,:,2) = Cg;
C(:,:,3) = Cb;

[a,b] = size(C(:,:,1));

x = a/tile_x;
y = b/tile_y;

sample = [];
t = 1;
for i = 1:tile_x
    for j = 1:tile_y
        start_x = round((i-1)*x+1);
        end_x = round(i*x);
        start_y = round((j-1)*y+1);
        end_y = round(j*y);
        C1 = imresize(C(start_x:end_x,start_y:end_y,:),[round(x),round(y)]);
        sample(:,:,:,t) = C1;
        t = t+1;
    end
end
%%
% comparison
% here "similarity" actually means distance
% and larger values indicate less similarity
for t = 1:tile_x*tile_y
    sample1 = sample(:,:,:,t);
    r2 = sample1(:,:,1);
    g2 = sample1(:,:,2);
    b2 = sample1(:,:,3);
    [row2,col2] = size(r2);
    
    ru2 = mean2(r2(1:round(row2/2),:));
	rd2 = mean2(r2(round(row2/2):row2,:));
	rl2 = mean2(r2(:,1:round(col2/2)));
	rr2 = mean2(r2(:,round(col2/2):col2));
        
	gu2 = mean2(g2(1:round(row2/2),:));
	gd2 = mean2(g2(round(row2/2):row2,:));
	gl2 = mean2(g2(:,1:round(col2/2)));
	gr2 = mean2(g2(:,round(col2/2):col2));
        
	bu2 = mean2(b2(1:round(row2/2),:));
	bd2 = mean2(b2(round(row2/2):row2,:));
	bl2 = mean2(b2(:,1:round(col2/2)));
	br2 = mean2(b2(:,round(col2/2):col2));

    [row,col] = size(RGB);
    min_path = 0;
    minV = 1000;
    if row>0
        for k = 1:row
            ru1 = RGB(k,1);
            rd1 = RGB(k,2);
            rl1 = RGB(k,3);
            rr1 = RGB(k,4);
            gu1 = RGB(k,5);
            gd1 = RGB(k,6);
            gl1 = RGB(k,7);
            gr1 = RGB(k,8);
            bu1 = RGB(k,9);
            bd1 = RGB(k,10);
            bl1 = RGB(k,11);
            br1 = RGB(k,12);
            
            similarity1 = sqrt((ru1-ru2)^2+(gu1-gu2)^2+(bu1-bu2)^2);
            similarity2 = sqrt((rd1-rd2)^2+(gd1-gd2)^2+(bd1-bd2)^2);
            similarity3 = sqrt((rl1-rl2)^2+(gl1-gl2)^2+(bl1-bl2)^2);
            similarity4 = sqrt((rr1-rr2)^2+(gr1-gr2)^2+(br1-br2)^2);
            
            similarity = similarity1 + similarity2 + similarity3 + similarity4;
            if similarity < minV
                minV = similarity;
                min_path = RGB(k,13);
            end
        end
    end
    result(t) = min_path;
end
%%
% generate the composite image
x1 = pixel_x/tile_x;
y1 = pixel_y/tile_y;
C2 = [];
t = 1;
for i = 1:tile_x
    for j = 1:tile_y
        start_x = round((i-1)*x1+1);
        end_x = round(i*x1);
        start_y = round((j-1)*y1+1);
        end_y = round(j*y1);
        
        r = round(result(t));
        image_name = path_list(r).name;
        R0 = imread(strcat(file_path,image_name));
        M = fspecial('gaussian',15,15/6);
        R0r = conv2(R0(:,:,1),M,'same');
        R0g = conv2(R0(:,:,2),M,'same');
        R0b = conv2(R0(:,:,3),M,'same');
        R0 = [];
        R0(:,:,1) = R0r;
        R0(:,:,2) = R0g;
        R0(:,:,3) = R0b;
        
        C2(start_x:end_x,start_y:end_y,:) = imresize(R0,[(end_x-start_x+1),(end_y-start_y+1)]);
        
        t = t+1;
    end
end
imshow(uint8(C2))