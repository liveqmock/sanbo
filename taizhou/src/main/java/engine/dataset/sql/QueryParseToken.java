package engine.dataset.sql;

//
// Token manager. Simple linked list approach to token management. Tokens have a type, name,
// alias, expression (which is a nested token list), and a link to the next element. The type
// defines the context for the name and alias.
//
// Not public.
//
class QueryParseToken extends SQLElement
{
  QueryParseToken() {
    tokenType  = SQLToken.UNKNOWN;
  }

  // Expression token constructor.
  //
  QueryParseToken(QueryParseToken token) {
    tokenType  = SQLToken.EXPRESSION;
    expression = token;
  }

  // General token constructor.
  //
  QueryParseToken(int type) {
    tokenType  = type;
  }

  QueryParseToken(int type, String name) {
    super(name,null,null,null,null);
    tokenType  = type;
  }

  QueryParseToken(int type, String name, String alias) {
    super(name,alias,null,null,null);
    tokenType  = type;
  }

  QueryParseToken(int type, String name, String prefix1, String prefix2, String prefix3, String alias) {
    super(name,alias,prefix1,prefix2,prefix3);
    tokenType = type;
  }

  QueryParseToken(int type, SQLElement element) {
    super(element);
    tokenType = type;
  }

  // Accessor methods

  void setType(int type) { tokenType = type; }
  int getType() { return tokenType; }

  boolean isSelect() { return tokenType == SQLToken.SELECT; }
  boolean isExpression() { return tokenType == SQLToken.EXPRESSION || tokenType == SQLToken.CONSTANT || tokenType == SQLToken.FUNCTION; }
  boolean isField() { return tokenType == SQLToken.FIELD; }
  boolean isFunction() { return tokenType == SQLToken.FUNCTION; }
  boolean isParameter() { return tokenType == SQLToken.PARAMETER; }
  boolean isTable() { return tokenType == SQLToken.TABLE; }
  boolean isWhere() { return tokenType == SQLToken.WHERE; }


  // Not determined yet whether we need to parse sub-queries. If not,
  // there should be no need to store an expression as a token.
  void setExpression(QueryParseToken token) { expression = token; }
  QueryParseToken getExpression() { return expression; }

  void setExpressionString(String expression) { setName(expression); }
  String getExpressionString() { return getName(); }

  void setNextToken(QueryParseToken token) { nextToken = token; }
  QueryParseToken getNextToken() { return nextToken; }

  // Instance variables

  private int tokenType;
  private QueryParseToken expression;
  private QueryParseToken nextToken;
}
