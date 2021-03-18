model prey_predator

global {
    int nb_preys_init <- 1000;
    int nb_predators_init <- 50;
    float prey_max_energy <- 1.0;
    float prey_max_transfert <- 0.2;
    float prey_energy_consum <- 0.05;
    float predator_max_energy <- 5.0;
    float predator_energy_transfert <- 1.0;
    float predator_energy_consum <- 0.02;
    float prey_proba_reproduce <- 0.5;
    int prey_nb_max_offsprings <- 3;
    float prey_energy_reproduce <- 0.2;
    float predator_proba_reproduce <- 0.05;
    int predator_nb_max_offsprings <- 3;
    float predator_energy_reproduce <- 0.5;
    int nb_preys -> {length(prey)};
    int nb_predators -> {length(predator)};

    init {
        create prey number: nb_preys_init;
        create predator number: nb_predators_init;
    }
    
    reflex stop_simulation when: (nb_preys = 0) or (nb_predators = 0) {
        do pause;
    } 
}

species generic_species {
    float size <- 1.0;
    rgb color;
    float max_energy;
    float max_transfert;
    float energy_consum;
    float proba_reproduce;
    int nb_max_offsprings;
    float energy_reproduce;
    image_file my_icon;
    vegetation_cell my_cell <- one_of(vegetation_cell);
    float energy <- rnd(max_energy) update: energy - energy_consum max: max_energy;

    init {
        location <- my_cell.location;
    }

    reflex basic_move {
        my_cell <- choose_cell();
        location <- my_cell.location;
    }

    reflex eat {
        energy <- energy + energy_from_eat() - 0.1;
    }

    reflex die when: energy <= 0 {
        do die;
    }

    reflex reproduce when: (energy >= energy_reproduce) and (flip(proba_reproduce)) {
        if(has_potentional_partners()) {
        	int nb_offsprings <- rnd(1, nb_max_offsprings);
        	create species(self) number: nb_offsprings {
	            my_cell <- myself.my_cell;
	            location <- my_cell.location;
	            energy <- myself.energy / nb_offsprings;
        	}
        	energy <- energy / nb_offsprings;
        }        
    }
    
    bool has_potentional_partners {
    	list potential_partners <- (self neighbors_at 1) of_species (species (self));
    	return ! empty(potential_partners);
    }

    float energy_from_eat {
        return 0.0;
    }

    vegetation_cell choose_cell {
        return nil;
    }

    aspect base {
        draw circle(size) color: color;
    }

    aspect icon {
        draw my_icon size: 2 * size;
    }

    aspect info {
        draw square(size) color: color;
        draw string(energy with_precision 2) size: 3 color: #black;
    }
}

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

species predator parent: generic_species {
    rgb color <- #red;
    float max_energy <- predator_max_energy;
    float energy_transfert <- predator_energy_transfert;
    float energy_consum <- predator_energy_consum;
    float proba_reproduce <- predator_proba_reproduce;
    int nb_max_offsprings <- predator_nb_max_offsprings;
    float energy_reproduce <- predator_energy_reproduce;
    image_file my_icon <- image_file("../includes/data/wolff.png");

    float energy_from_eat {
        list<prey> reachable_preys <- prey inside (my_cell);
        if(! empty(reachable_preys)) {
            ask one_of (reachable_preys) {
                do die;
            }
            return energy_transfert;
        }
        return 0.0;
    }

    vegetation_cell choose_cell {
        vegetation_cell my_cell_tmp <- shuffle(my_cell.neighbors2) first_with (!(empty(prey inside (each))));
        if my_cell_tmp != nil {
        	
        	int y_before <- my_cell_tmp.grid_y;
	    	int x_before <- my_cell_tmp.grid_x;
	    	int change_y <- abs(my_cell.grid_y-y_before);
	    	int change_x <- abs(my_cell.grid_x-x_before);
	    	int biggest_change <- max([change_y, change_x]);
			energy <- energy - biggest_change * 0.25;
        	
            return my_cell_tmp;
        } else {
        	energy <- energy - 0.2;
            return one_of(my_cell.neighbors1);
        }
    }
    
    // TODO: Implementer lugt 6 celler væk
}

grid vegetation_cell width: 50 height: 50 neighbors: 8 {
    float max_food <- 1.0;
    float food_prod <- rnd(0.01);
    float food <- rnd(1.0) max: max_food update: food + food_prod;
    rgb color <- rgb(int(255 * (1 - food)), 255, int(255 * (1 - food))) update: rgb(int(255 * (1 - food)), 255, int(255 * (1 - food)));
    list<vegetation_cell> neighbors1 <- (self neighbors_at 1);
    list<vegetation_cell> neighbors2 <- (self neighbors_at 2);
    list<vegetation_cell> neighbors3 <- (self neighbors_at 3);
}

experiment prey_predator type: gui {
    parameter "Initial number of preys: " var: nb_preys_init min: 0 max: 1000 category: "Prey";
    parameter "Prey max energy: " var: prey_max_energy category: "Prey";
    parameter "Prey max transfert: " var: prey_max_transfert category: "Prey";
    parameter "Prey energy consumption: " var: prey_energy_consum category: "Prey";
    parameter "Initial number of predators: " var: nb_predators_init min: 0 max: 200 category: "Predator";
    parameter "Predator max energy: " var: predator_max_energy category: "Predator";
    parameter "Predator energy transfert: " var: predator_energy_transfert category: "Predator";
    parameter "Predator energy consumption: " var: predator_energy_consum category: "Predator";
    parameter 'Prey probability reproduce: ' var: prey_proba_reproduce category: 'Prey';
    parameter 'Prey nb max offsprings: ' var: prey_nb_max_offsprings category: 'Prey';
    parameter 'Prey energy reproduce: ' var: prey_energy_reproduce category: 'Prey';
    parameter 'Predator probability reproduce: ' var: predator_proba_reproduce category: 'Predator';
    parameter 'Predator nb max offsprings: ' var: predator_nb_max_offsprings category: 'Predator';
    parameter 'Predator energy reproduce: ' var: predator_energy_reproduce category: 'Predator';

    output {
        display main_display {
            grid vegetation_cell lines: #black;
            species prey aspect: icon;
            species predator aspect: icon;
        }

        display info_display {
            grid vegetation_cell lines: #black;
            species prey aspect: info;
            species predator aspect: info;
        }

        monitor "Number of preys" value: nb_preys;
        monitor "Number of predators" value: nb_predators;
    }
}