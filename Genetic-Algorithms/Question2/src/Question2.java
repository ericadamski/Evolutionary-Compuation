import org.jgap.*;
import org.jgap.impl.BestChromosomesSelector;
import org.jgap.impl.DefaultConfiguration;
import org.jgap.impl.DoubleGene;
import org.jgap.impl.MutationOperator;

public class Question2 {
	
	public static final int numEvolutions = 500;
	public static final int popSize = 5;
	
	public static double getAccuracy(IChromosome c) {
		 return ((c.getFitnessValue() / 150) * 100);
	}
	
	public static void getRule(IChromosome c, int run) {
		String type;
		Gene[] genes = c.getGenes();
		
		double setosaUB = ((DoubleGene) genes[0]).doubleValue();
		double versicolourUB = ((DoubleGene) genes[1]).doubleValue();
		double virginicaUB = ((DoubleGene) genes[2]).doubleValue();
		
		switch (run) {
		case 0: type = "Sepal Length (cm) ";
				break;
		case 1: type = "Sepal Width (cm) ";
				break;
		case 2: type = "Petal Length (cm) ";
				break;
		case 3: type = "Petal Width (cm) ";
				break;
		default: type = "Error Computing Rule";
				break;
		}
		
		System.out.println(type + "0 to " + setosaUB + " = Iris-setosa");
		System.out.println(type + setosaUB + " to " + versicolourUB + " = Iris-versicolour");
		System.out.println(type + versicolourUB + " to " + virginicaUB + " = Iris-virginica");
	}
	
	public static double getAverageAccuracy(Genotype population) {
		double accuracy = 0;
		
		Population pop = population.getPopulation();
		
		for (int i=0; i < pop.size(); i++) {
			accuracy += getAccuracy(pop.getChromosome(i));
		}
		
		return (accuracy / pop.size());
	}
	
	public static IChromosome runGA(int testVar) throws Exception {
		Configuration conf = new DefaultConfiguration();
		BestChromosomesSelector bestChromsSelector =
		          new BestChromosomesSelector(conf, 0.01d);
		bestChromsSelector.setDoubletteChromosomesAllowed(false);
	    conf.addNaturalSelector(bestChromsSelector, true);
		conf.addGeneticOperator(new MutationOperator(conf, 5));
		
		Gene[] sampleGenes = new Gene[3];
		sampleGenes[0] = new DoubleGene(conf, 0.0, 8.0);
		sampleGenes[1] = new DoubleGene(conf, 0.0, 8.0);
		sampleGenes[2] = new DoubleGene(conf, 0.0, 8.0);
		
		Chromosome sampleChromosome = new Chromosome(conf, sampleGenes);
		conf.setSampleChromosome(sampleChromosome);
		conf.setPopulationSize(popSize);
		
		FitnessFunction myFunc = new IrisClassificationFitnessFunction(testVar);
		conf.setFitnessFunction(myFunc);
		
		Genotype population = Genotype.randomInitialGenotype(conf);
		IChromosome best = null;
		
		for (int i=0; i < numEvolutions; i++)
		{
			population.evolve();
			best = population.getFittestChromosome();
			
			System.out.println("Generation Number: " + i);
			System.out.println("Best Classification Accuracy: " + getAccuracy(best) + "%");
			getRule(best, testVar);
			System.out.println("Average Classification Accuracy: " + getAverageAccuracy(population) + "%");
			System.out.println("");
		}
		Configuration.reset();
		
		return best;
	}
	
	/* Classification Accuracy of each attribute (ex. Petal Width) match the Correlation Statistics 
	 * provided by the Iris Plants Database. 
	*/
	public static void main(String[] args) throws Exception 
	{
		IChromosome run0 = runGA(0);
		IChromosome run1 = runGA(1);
		IChromosome run2 = runGA(2);
		IChromosome run3 = runGA(3);
		
		double bestRun = Math.max(Math.max(getAccuracy(run0), getAccuracy(run1)),
					              Math.max(getAccuracy(run2), getAccuracy(run3)));
		
		double avgRun = (getAccuracy(run0) + getAccuracy(run1) + getAccuracy(run2) + getAccuracy(run3)) / 4;
		
		System.out.println("Total Generations: " + (numEvolutions * 4));
		System.out.println("Best Classification Accuracy: " + bestRun);
		System.out.println("Rules Found:");
		getRule(run0, 0);
		getRule(run1, 1);
		getRule(run2, 2);
		getRule(run3, 3);
		System.out.println("Average Classification Accuracy: " + avgRun);
	}
	
}
