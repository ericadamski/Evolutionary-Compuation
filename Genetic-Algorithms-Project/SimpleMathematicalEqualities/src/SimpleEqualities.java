import java.util.ArrayList;

import org.jgap.*;
import org.jgap.impl.BestChromosomesSelector;
import org.jgap.impl.DefaultConfiguration;
import org.jgap.impl.IntegerGene;
import org.jgap.impl.MutationOperator;

public class SimpleEqualities {
	
	public static final int m_numEvolutions = 5000;
	public static final int m_popSize = 1000;
	private static Formula m_formula;
	
	public static void runGA() throws Exception
	{
		Configuration conf = new DefaultConfiguration();
		BestChromosomesSelector bestChromsSelector = new BestChromosomesSelector(conf, 0.05d);
		bestChromsSelector.setDoubletteChromosomesAllowed(false);
	    conf.addNaturalSelector(bestChromsSelector, true);
		conf.addGeneticOperator(new MutationOperator(conf, 20));
		
		
		ArrayList<Character> vars = m_formula.getOrderedVariables();
		int size = vars.size();
		Gene[] sampleGenes = new Gene[size];
		
		for (int i=0; i < size; i++)
			sampleGenes[i] = new IntegerGene(conf, 0, 30); //get max/min funcs
		
		Chromosome sampleChromosome = new Chromosome(conf, sampleGenes);
		conf.setSampleChromosome(sampleChromosome);
		conf.setPopulationSize(m_popSize);
		
		FitnessFunction myFunc = new EqualitiesFitnessFunction(m_formula);
		conf.setFitnessFunction(myFunc);
		
		Genotype population = Genotype.randomInitialGenotype(conf);
		
		IChromosome best = null;
		
		for (int i=0; i < m_numEvolutions; i++)
		{
			population.evolve();
			best = population.getFittestChromosome();
		}
		
		for (int i=0; i < vars.size(); i++)
		{
			int value = ((IntegerGene) best.getGenes()[i]).intValue();
			m_formula.addResult(vars.get(i), value);
		}
		
		System.out.println(m_formula.getResultAsString());
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


