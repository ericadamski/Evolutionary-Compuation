import org.jgap.*;
import org.jgap.event.EventManager;
import org.jgap.impl.*;
import org.jgap.impl.salesman.*;

public class Question1 extends Salesman{
	
	private static final long serialVersionUID = 1L;
	
	public static final int CITIES = 51;
	private Configuration m_config;
	
	public static final int[][] CITYARRAY = new int[][] { { 37, 52 },
		   { 49, 49 }, { 52, 64 }, { 20, 26 }, { 40, 30 }, { 21, 47 },
		   { 17, 63 }, { 31, 62 }, { 52, 33 }, { 51, 21 }, { 42, 41 },
		   { 31, 32 }, { 5, 25 }, { 12, 42 }, { 36, 16 }, { 52, 41 },
		   { 27, 23 }, { 17, 33 }, { 13, 13 }, { 57, 58 }, { 62, 42 },
		   { 42, 57 }, { 16, 57 }, { 8, 52 }, { 7, 38 }, { 27, 68 },
		   { 30, 48 }, { 43, 67 }, { 58, 48 }, { 58, 27 }, { 37, 69 },
		   { 38, 46 }, { 46, 10 }, { 61, 33 }, { 62, 63 }, { 63, 69 },
		   { 32, 22 }, { 45, 35 }, { 59, 15 }, { 5, 6 }, { 10, 17 },
		   { 21, 10 }, { 5, 64 }, { 30, 15 }, { 39, 10 }, { 32, 39 },
		   { 25, 32 }, { 25, 55 }, { 48, 28 }, { 56, 37 }, { 30, 40 } };
	
	public double distance(Gene a_from, Gene a_to){
		IntegerGene a = (IntegerGene) a_from;
		IntegerGene b = (IntegerGene) a_to;
		
		int cityIndexA = a.intValue();
		int cityIndexB = b.intValue();
		
		int x1 = CITYARRAY[cityIndexA][0];
		int x2 = CITYARRAY[cityIndexB][0];
		int y1 = CITYARRAY[cityIndexA][1];
		int y2 = CITYARRAY[cityIndexB][1];
		
		return Math.sqrt( (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
	}
	
	public IChromosome createSampleChromosome(Object initial_data) {
		try {
		      Gene[] genes = new Gene[CITIES];
		      
		      for (int i = 0; i < genes.length; i++) {
		        genes[i] = new IntegerGene(m_config, 0, CITIES - 1);
		        genes[i].setAllele(new Integer(i));
		      }
		      IChromosome sample = new Chromosome(m_config, genes);
		      
		      return sample;
		    }
		    catch (InvalidConfigurationException iex) {
		      throw new IllegalStateException(iex.getMessage());
		    }
	}
	
	public Configuration createConfiguration(final Object a_initial_data)
		      throws InvalidConfigurationException {
		    
		      Configuration config = new Configuration();
		      BestChromosomesSelector bestChromsSelector =
		          new BestChromosomesSelector(config, 0.05d);
		      bestChromsSelector.setDoubletteChromosomesAllowed(false);
		      config.addNaturalSelector(bestChromsSelector, true);
		      config.setRandomGenerator(new StockRandomGenerator());
		      config.setMinimumPopSizePercent(0);
		      config.setEventManager(new EventManager());
		      config.setFitnessEvaluator(new DefaultFitnessEvaluator());
		      config.setChromosomePool(new ChromosomePool());
		      
		      config.addGeneticOperator(new GreedyCrossover(config));
		      config.addGeneticOperator(new SwappingMutationOperator(config, 20));
		      return config;
		  }
	
	public IChromosome findOptimalPath(final Object a_initial_data)
		      throws Exception {
		    m_config = createConfiguration(a_initial_data);
		    FitnessFunction myFunc = createFitnessFunction(a_initial_data);
		    m_config.setFitnessFunction(myFunc);
		    
		    IChromosome sampleChromosome = createSampleChromosome(a_initial_data);
		    m_config.setSampleChromosome(sampleChromosome);
		    
		    m_config.setPopulationSize(getPopulationSize());
		    
		    IChromosome[] chromosomes =
		        new IChromosome[m_config.getPopulationSize()];
		    Gene[] samplegenes = sampleChromosome.getGenes();
		    for (int i = 0; i < chromosomes.length; i++) {
		      Gene[] genes = new Gene[samplegenes.length];
		      for (int k = 0; k < genes.length; k++) {
		        genes[k] = samplegenes[k].newGene();
		        genes[k].setAllele(samplegenes[k].getAllele());
		      }
		      chromosomes[i] = new Chromosome(m_config, genes);
		    }
		    
		    Genotype population = new Genotype(m_config,
		                                       new Population(m_config, chromosomes));
		    IChromosome best = null;
		    
		    for (int i = 0; i < 10000; i++) {
		      population.evolve();
		      best = population.getFittestChromosome();
		      System.out.println("Generation Number: " + i);
		      System.out.println("Best Tour Length: " + getTourLength(best));
		      System.out.println("Best City Order: " + printOrderedTour(best));
		      System.out.println("Average Tour Length: " + getAverageLength(population));
		      System.out.println("");
		    }
		    
		    return best;
		  }
	
	public double getTourLength(IChromosome c) {
		  double s = 0;
		  Gene[] genes = c.getGenes();
		  for (int i = 0; i < genes.length - 1; i++) {
		   s += distance(genes[i], genes[i + 1]);
		  }
		  // add cost of coming back:
		  s += distance(genes[genes.length - 1], genes[0]);
		  return s;
		 }
	
	public String printOrderedTour(IChromosome c) {
		String s = "";
		Gene[] genes = c.getGenes();
		for (int i = 0; i < genes.length - 1; i++) {
			IntegerGene g = (IntegerGene) genes[i];
			s += g.intValue();
			s += " ";
		  }
		  return s;
		 }
	
	public double getAverageLength(Genotype population) {
		double s = 0;
		
		Population pop = population.getPopulation();
		
		for (int i=0; i < pop.size(); i++) {
			s += getTourLength(pop.getChromosome(i));
		}
		
		s = (s / pop.size());
		
		return s;
	}
	
	public static void main(String[] args) throws Exception {
		try {
		      Question1 t = new Question1();
		      IChromosome optimal = t.findOptimalPath(null);
		    }
		    catch (Exception ex) {
		      ex.printStackTrace();
		    }
	}
}
