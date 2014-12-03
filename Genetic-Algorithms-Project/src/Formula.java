import java.util.*;

public class Formula
{
  public Formula ()
  {}

  public boolean parse(String formula)
  {
    // A formula is of the form Ax+Bx+Cx+Dx+ .... +c= NUMBER (NO SPACES)
    // Where A B C D and c are constants in R
    String terms[] = formula.split("\\+");
    Boolean complete = false;
    for ( String term : terms )
    {
      if (term.equals(""))
      {
        return false;
      }

      String equals[] = term.split("=");

      if (equals.length == 2)
      {
        complete = true;
        try
        {
          m_answer = Integer.parseInt(equals[1]);
          terms[Arrays.asList(terms).indexOf(term)] = equals[0];
        }
        catch (Exception e)
        {
          return false;
        }
      }
    }

    if (!complete)
      return complete;

    m_formula = formula;
    m_terminals = terms;

    return splitTerminals(terms);
  }

  public static void improperFormulaErrorMsg(String error)
  {
    System.out.println("Improper Input Formula : " + error
    + " is not of the form Ax+By+Cz+Dw+ ... +a+b+c+ ... =<some-number>");
  }

  public String getFormula()
  { return m_formula; }

  public String[] getTerminals()
  { return m_terminals; }

  public int getAnswer()
  { return m_answer; }

  public int[] getOrderedCoefficents()
  { return m_coefficents; }

  public char[] getOrderedVariables()
  { return m_variables; }

  public int getNoncoefficents()
  { return m_noncoefficents; }

  private boolean splitTerminals(String terminals[])
  {
    // pairs of the form NUMBERletter and NUMBER and ?=?
    int terminalLength = 0;
    for (String term : terminals)
    {
      String splitTerm[] = term.split("(?<=(\\D+))|(?=(\\D+))");
      if ( splitTerm.length > 1 )
        ++terminalLength;
    }
    int terminalCount = 0;
    m_variables = new char[terminalLength];
    m_coefficents = new int[terminalLength];
    for (String term : terminals)
    {
      int num;
      String var = "";

      String splitTerm[] = term.split("(?<=(\\D+))|(?=(\\D+))");

      switch (splitTerm.length)
      {
        case 1:
          //NUMBER
          try
          {
            m_noncoefficents += Integer.parseInt(splitTerm[0]);
          }
          catch (Exception e)
          {
            return false;
          }
          break;

        case 2:
          //NUMBER<VAR>
          try
          {
            m_coefficents[terminalCount] = Integer.parseInt(splitTerm[0]);
            m_variables[terminalCount] = splitTerm[1].charAt(0);
          }
          catch (Exception e)
          {
            return false;
          }
          break;

        default:
          return false;
      }
      ++terminalCount;
    }
    return true;
  }

  private String m_formula;
  private String m_terminals[]; // numberletter pairs

  private int m_coefficents[]; // number
  private char m_variables[]; // letter
  private int m_noncoefficents;
  private int m_answer;

  public static void main(String[] args)
  {
    if (args.length >= 1)
    {
      String formula = args[0];
      Formula parser = new Formula();
      if ( formula instanceof String )
      {
        if ( !parser.parse(formula) )
          improperFormulaErrorMsg(formula);

        for ( int i : parser.getOrderedCoefficents() )
          System.out.println(i);
        for ( char c : parser.getOrderedVariables() )
          System.out.println(c);
        System.out.println(parser.getNoncoefficents());
      }
      else
        improperFormulaErrorMsg(formula);
    }
    else
      System.out.println("Error : No Input Given.");
  }
}
