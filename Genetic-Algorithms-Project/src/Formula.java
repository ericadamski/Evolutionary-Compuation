
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
        complete = false;
        break;
      }
      if (term.split("=").length == 2)
        complete = true;
    }
    m_formula = formula;
    m_terminals = terms;
    return complete;
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

  private String m_formula;
  private String m_terminals[];

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
      }
      else
        improperFormulaErrorMsg(formula);
    }
    else
      System.out.println("Error : No Input Given.");
  }
}
