
model prey

import "generic.gaml"
import "predator.gaml"

species prey parent: generic_species {
    rgb color <- #blue;
    float max_energy <- prey_max_energy;
    float max_transfert <- prey_max_transfert;
    float energy_consum <- prey_energy_consum;
    float proba_reproduce <- prey_proba_reproduce;
    int nb_max_offsprings <- prey_nb_max_offsprings;
    float energy_reproduce <- prey_energy_reproduce;
    image_file my_icon <- image_file("../includes/data/sheep.png");    

    float energy_from_eat {
        float energy_transfert <- 0.0;
        if(my_cell.food > 0) {
            energy_transfert <- min([max_transfert, my_cell.food]);
            my_cell.food <- my_cell.food - energy_transfert;
        }
        return energy_transfert;
    }
    
    bool spot_predators{
    	vegetation_cell my_cell_tmp <- shuffle(my_cell.neighbors3) first_with (!(empty(predator inside (each))));
    	return my_cell_tmp != nil;
    }
    
    reflex fight_or_flight when: (spot_predators()) {
    	int y_before <- my_cell.grid_y;
    	int x_before <- my_cell.grid_x;
    	my_cell <- one_of (my_cell.neighbors3);
    	int change_y <- abs(my_cell.grid_y-y_before);
    	int change_x <- abs(my_cell.grid_x-x_before);
    	int biggest_change <- max([change_y, change_x]);
		energy <- energy - biggest_change * 0.2;
    	location <- my_cell.location;
    }

    vegetation_cell choose_cell {    	
    	vegetation_cell juiciest_neighbor <- (my_cell.neighbors1) with_max_of (each.food);
    	if(my_cell.food < 0.1) {
    		energy <- energy - 0.2;
    		return juiciest_neighbor;
    	}    	
    	
    	return my_cell;
    }
}