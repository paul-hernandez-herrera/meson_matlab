function display_images_steps_MESON(image_3d_stack, model, output_model, segmentation)
        %just to show the outputs outputs
        %getting screen size
        h = figure('units','normalized','outerposition',[0 0 1 1]);
        
        tiledlayout(2,2, 'TileSpacing', 'normal', 'Padding', 'normal');
        
        %plot first figure
        %subplot(2,2,1)
        ax1 = nexttile;
        imshow(max(image_3d_stack,[],3)',[],'InitialMagnification','fit'); colorbar;
        title({'3D image stack' 'maximum intensity projection (MIP)'}, 'fontsize',15);
        
        
        %plot second figure
        %subplot(2,2,2)
        ax2 = nexttile;
        clim = [0 max(model{1}.one_class_model(:))];
        imagesc(model{1}.edges{2}, model{1}.edges{1}, model{1}.one_class_model ,clim); colorbar; set(ax2,'YDir','normal'); xlabel('\lambda_3','fontsize',15);ylabel('\lambda_2','fontsize',15); axis(ax2,'normal'); title('Predicted model scale 1','fontsize',15)        
        
        %plot third figure
        %subplot(2,2,3)
        ax3 = nexttile;
        imshow(max(output_model,[],3)',[],'InitialMagnification','fit'); colorbar;
        title('Prediction MIP', 'fontsize',15)    
        
        
        %plot fourth figure
        %subplot(2,2,4)
        ax4 = nexttile;
        imshow(255*max(segmentation,[],3)',[],'InitialMagnification','fit'); colorbar;
        title('Segmentation MIP', 'fontsize',15)
        
        colormap(ax1,gray)
        colormap(ax2,jet)
        colormap(ax3,jet)
        colormap(ax4,gray)
end