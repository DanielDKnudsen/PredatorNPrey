model generic

global {
    int nb_preys_init <- 400;
    int nb_predators_init <- 60;
    float prey_max_energy <- 1.0;
    float prey_max_transfert <- 0.2;
    float prey_energy_consum <- 0.05;
    float predator_max_energy <- 5.0;
    float predator_energy_transfert <- 1.0;
    float predator_energy_consum <- 0.02;
    float prey_proba_reproduce <- 0.05;
    int prey_nb_max_offsprings <- 3;
    float prey_energy_reproduce <- 0.2;
    float predator_proba_reproduce <- 0.05;
    int predator_nb_max_offsprings <- 3;
    float predator_energy_reproduce <- 0.5;
    int grid_size <- 100;

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
        energy <- energy + energy_from_eat() - 0.01;
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

grid vegetation_cell width: grid_size height: grid_size neighbors: 8 {
    float max_food <- 1.0;
    float food_prod <- rnd(0.01);
    float food <- rnd(1.0) max: max_food update: food + food_prod;
    rgb color <- rgb(int(255 * (1 - food)), 255, int(255 * (1 - food))) update: rgb(int(255 * (1 - food)), 255, int(255 * (1 - food)));
    list<vegetation_cell> neighbors1 <- (self neighbors_at 1);
    list<vegetation_cell> neighbors2 <- (self neighbors_at 2);
    list<vegetation_cell> neighbors3 <- (self neighbors_at 3);
    list<vegetation_cell> neighbors6 <- (self neighbors_at 6);
}

