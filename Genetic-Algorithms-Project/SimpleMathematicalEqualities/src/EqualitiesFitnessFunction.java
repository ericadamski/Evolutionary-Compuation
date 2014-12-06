import java.util.ArrayList;

import org.jgap.FitnessFunction;
import org.jgap.Gene;
import org.jgap.IChromosome;
import org.jgap.impl.IntegerGene;


public class EqualitiesFitnessFunction extends FitnessFunction{

	private static final long serialVersionUID = 1L;
	private Formula m_formula;
	
	public EqualitiesFitnessFunction(Formula a_formula)
	{
		m_formula = a_formula;
	}

	protected double evaluate(IChromosome a_subject) 
	{
		double fitness = 0;
		int answer = 0;
		ArrayList<Integer> coefficients = m_formula.getOrderedcoefficients();
		Gene[] genes = a_subject.getGenes();
	
		for (int i=0; i < coefficients.size(); i++)
		{
			answer += coefficients.get(i) * ((IntegerGene) genes[i]).intValue();
		}
		
		answer += m_formula.getNoncoefficients();
		fitness = 1 / (Math.abs(m_formula.getAnswer() - answer) + 1);
		
		return fitness;
	}

}
