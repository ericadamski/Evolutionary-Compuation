import java.util.ArrayList;

import org.jgap.*;
import org.jgap.impl.CrossoverOperator;
import org.jgap.impl.DefaultConfiguration;
import org.jgap.impl.IntegerGene;
import org.jgap.impl.MutationOperator;

public class SimpleEqualities {
	
	public static final int m_maxEvolutions = 10;
	public static final int m_popSize = 100;
	public static int iterations = 0;
	private static Formula m_formula;
	
	public static void runGA() throws Exception
	{
		Configuration conf = new DefaultConfiguration();
		
		/* MANUALLY CHANGE CROSSOVER/MUTATION VALUES */
	    //conf.addGeneticOperator(new CrossoverOperator(conf, 0.02d));
		//conf.addGeneticOperator(new MutationOperator(conf, 5));
		
		ArrayList<Character> vars = m_formula.getOrderedVariables();
		int size = vars.size();
		Gene[] sampleGenes = new Gene[size];
		
		for (int i=0; i < size; i++)
			sampleGenes[i] = new IntegerGene(conf, 0, m_formula.getAnswer()); 
			// variable values cannot be larger than the answer
		
		Chromosome sampleChromosome = new Chromosome(conf, sampleGenes);
		conf.setSampleChromosome(sampleChromosome);
		conf.setPopulationSize(m_popSize);
		
		FitnessFunction myFunc = new EqualitiesFitnessFunction(m_formula);
		conf.setFitnessFunction(myFunc);
		
		Genotype population = Genotype.randomInitialGenotype(conf);
		
		IChromosome best = population.getFittestChromosome();
		
		while (best.getFitnessValue() != 1)
		{
			population.evolve();
			best = population.getFittestChromosome();
			iterations++;
		}
		
		for (int i=0; i < vars.size(); i++)
		{
			int value = ((IntegerGene) best.getGenes()[i]).intValue();
			m_formula.addResult(vars.get(i), value);
		}
		
		System.out.println(m_formula.getResultAsString());
		System.out.println("");
		System.out.println("Answer found in " + iterations + " iterations");
	}
	
	public static boolean getFormula(String[] args)
	{
		if (args.length > 0)
		{
			String formula = args[0]; 
			m_formula = new Formula();
			System.out.println(formula);
			
			if (!m_formula.parse(formula))
				return false;
		}
		else
			return false;
		
		return true;
	}
	
	public static void main(String[] args) throws Exception
	{
		if (getFormula(args))
			runGA();
		else
			Formula.improperFormulaErrorMsg(args[0]);
	}
}


