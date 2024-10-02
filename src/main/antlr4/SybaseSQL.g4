grammar SybaseSQL;

/* Parser rules */

parse
    : (statement | procedureDefinition | GO)+ EOF
    ;

/* Rule for handling stored procedure definitions */
procedureDefinition
    : (CREATE PROC | CREATE PROCEDURE) procedureName parameterList? AS procedureBody
    ;

procedureName
    : IDENTIFIER
    ;

/* Parameters for procedures */
parameterList
    : '(' parameter (',' parameter)* ')'
    ;

/* Parameters can have default values */
parameter
    : variable dataType ('=' defaultValue)?
    ;

defaultValue
    : STRING_LITERAL
    | NUMBER_LITERAL
    ;

/* Procedure body */
procedureBody
    : (BEGIN statementList END | statementList)
    ;

statementList
    : statement+
    ;

statement
    : selectStatement
    | insertStatement
    | updateStatement
    | deleteStatement
    | declareStatement
    | setStatement
    | setRowCountStatement
    | ifStatement
    | elseStatement
    | whileStatement
    | breakStatement
    | continueStatement
    | gotoStatement
    | labelDefinition
    | printStatement
    | createTableStatement
    | dropTableStatement
    | createProcedureStatement
    | createTriggerStatement
    | createFunctionStatement
    | rollbackStatement
    | returnStatement
    ;

/* Variable declarations */
declareStatement
    : DECLARE variableDeclaration (',' variableDeclaration)* (';' | )
    ;

variableDeclaration
    : variable dataType ( '=' expression )? commentPart?
    ;

/* SET statements */
setStatement
    : SET variable '=' expression (';' | )
    ;

/* SET ROWCOUNT n */
setRowCountStatement
    : SET ROWCOUNT NUMBER_LITERAL (';' | )
    ;

createTableStatement
    : CREATE TABLE tableName '(' columnDefinitionList ')' (';' | )
    ;

columnDefinitionList
    : columnDefinition (',' columnDefinition)*
    ;

columnDefinition
    : columnName dataType (columnConstraint)* commentPart?
    ;

columnConstraint
    : PRIMARY KEY
    | NOT NULL
    | NULL
    ;

/* DROP TABLE statement */
dropTableStatement
    : DROP TABLE tableName (';' | )
    ;

/* SELECT statements */
selectStatement
    : SELECT selectElements (INTO tableName)? (FROM tableJoinList)? whereClause? groupByClause? havingClause? orderByClause? (';' | )
    | SELECT assignmentList (';' | )
    ;

assignmentList
    : assignment (',' assignment)*
    ;

assignment
    : variable '=' expression
    ;

selectElements
    : '*'                                  # SelectAllColumns
    | selectElement (',' selectElement)*   # SelectSpecificColumns
    ;

selectElement
    : expression (AS IDENTIFIER)?
    ;

/* Column list for INSERT statements */
columnList
    : columnName (',' columnName)*
    ;

/* INSERT statements */
insertStatement
    : INSERT INTO tableName ('(' columnList ')')? (VALUES '(' valueList ')' | selectStatement) (';' | )
    ;

/* UPDATE statements */
updateStatement
    : UPDATE tableName SET updateList whereClause? (';' | )
    ;

/* DELETE statements */
deleteStatement
    : DELETE (FROM)? tableName whereClause? (';' | )
    ;

/* IF statements */
ifStatement
    : IF expression (BEGIN statementList END | statement)
    ;

/* ELSE statements */
elseStatement
    : ELSE (BEGIN statementList END | statement)
    ;

/* WHILE loops */
whileStatement
    : WHILE expression (BEGIN statementList END | statement)
    ;

/* BREAK statement */
breakStatement
    : BREAK (';' | )
    ;

/* CONTINUE statement */
continueStatement
    : CONTINUE (';' | )
    ;

/* GOTO statements and labels */
gotoStatement
    : GOTO labelName (';' | )
    ;

labelDefinition
    : labelName ':'
    ;

labelName
    : IDENTIFIER
    ;

/* PRINT statement */
printStatement
    : PRINT expression (';' | )
    ;

/* RETURN statement */
returnStatement
    : RETURN expression? (';' | )
    ;

valueList
    : expression (',' expression)*
    ;

/* Expressions */
expression
    : expression binaryOperator expression   # BinaryOperation
    | '(' expression ')'                     # ParenthesizedExpression
    | functionCall                           # FunctionCallExpression
    | caseExpression                         # CaseExpressionAlt
    | value                                  # ValueExpression
    | variable                               # VariableExpression
    | columnName                             # ColumnExpression
    ;

binaryOperator
    : '+'
    | '-'
    | '*'
    | '/'
    | '%'
    | '&'
    | '|'
    | '^'
    ;

functionCall
    : functionName '(' functionArgs? ')'
    ;

functionName
    : CONVERT
    | DATEDIFF
    | SUBSTRING
    | GETDATE
    | ABS
    | RTRIM
    | LTRIM
    | LEN
    | CHARINDEX
    | ISNULL
    | INDEX_COL
    | COL_NAME
    | OBJECT_ID
    | OBJECT_NAME
    | USER_NAME
    | DB_NAME
    | DB_ID
    | PATINDEX
    | LOWER
    | UPPER
    | IDENTIFIER
    ;

functionArgs
    : expression (',' expression)*
    ;

caseExpression
    : CASE (WHEN expression THEN expression)+ (ELSE expression)? END
    ;

/* WHERE clause */
whereClause
    : WHERE condition (logicalOp condition)*
    ;

/* Conditions */
condition
    : expression comparisonOp expression
    | expression (IN | NOT IN) '(' subquery ')'
    | expression
    ;

/* Subquery */
subquery
    : selectStatement
    ;

/* Comparison operators */
comparisonOp
    : '='
    | '!='
    | '<>'
    | '>'
    | '<'
    | '>='
    | '<='
    ;

/* Logical operators */
logicalOp
    : AND
    | OR
    ;

/* GROUP BY clause */
groupByClause
    : GROUP BY groupByList
    ;

groupByList
    : expression (',' expression)*
    ;

/* HAVING clause */
havingClause
    : HAVING condition
    ;

/* ORDER BY clause */
orderByClause
    : ORDER BY orderByExpression (',' orderByExpression)*
    ;

orderByExpression
    : expression (ASC | DESC)?
    ;

/* UPDATE list */
updateList
    : columnName '=' expression (',' columnName '=' expression)*
    ;

/* Table joins */
tableJoinList
    : tableExpression (joinClause tableExpression)*
    ;

tableExpression
    : tableName (AS? IDENTIFIER)?
    | '(' selectStatement ')' (AS? IDENTIFIER)?
    ;

/* Join clauses */
joinClause
    : joinType JOIN tableExpression ON condition
    | ',' tableExpression
    ;

joinType
    : INNER
    | LEFT OUTER?
    | RIGHT OUTER?
    | FULL OUTER?
    | CROSS
    ;

/* Data types */
dataType
    : INT
    | SMALLINT
    | TINYINT
    | MONEY
    | NUMERIC '(' NUMBER_LITERAL (',' NUMBER_LITERAL)? ')'
    | DECIMAL '(' NUMBER_LITERAL (',' NUMBER_LITERAL)? ')'
    | VARCHAR '(' NUMBER_LITERAL? ')'
    | NVARCHAR '(' NUMBER_LITERAL? ')'
    | CHAR '(' NUMBER_LITERAL? ')'
    | DATE
    | DATETIME
    | BIT
    | TEXT
    ;

/* Column names */
columnName
    : (IDENTIFIER DOT)? IDENTIFIER
    ;

/* Table names */
tableName
    : HASH? IDENTIFIER
    ;

/* Values */
value
    : STRING_LITERAL
    | NUMBER_LITERAL
    | NULL
    ;

/* Variables */
variable
    : AT_SIGN IDENTIFIER
    ;

/* ROLLBACK statement */
rollbackStatement
    : ROLLBACK (TRANSACTION | TRAN)? (';' | )
    ;

/* CREATE TRIGGER statement */
createTriggerStatement
    : CREATE TRIGGER triggerName ON tableName triggerTime triggerEvent AS triggerBody
    ;

triggerName
    : IDENTIFIER
    ;

triggerTime
    : AFTER
    | BEFORE
    | INSTEAD OF
    ;

/* Multiple trigger events */
triggerEvent
    : (INSERT | UPDATE | DELETE) (',' (INSERT | UPDATE | DELETE))*
    ;

triggerBody
    : (BEGIN statementList END | statementList)
    ;

/* CREATE FUNCTION statement */
createFunctionStatement
    : CREATE FUNCTION functionName '(' parameterList? ')' RETURNS dataType AS BEGIN statementList END
    ;

/* CREATE PROCEDURE statement */
createProcedureStatement
    : (CREATE PROC | CREATE PROCEDURE) procedureName parameterList? AS procedureBody
    ;

/* Comments */
commentPart
    : MULTILINE_COMMENT
    ;

/* GO statement */
GO
    : [gG][oO]
    ;

/* Lexer rules */

/* Data Types */
INT       : [iI][nN][tT];
SMALLINT  : [sS][mM][aA][lL][lL][iI][nN][tT];
TINYINT   : [tT][iI][nN][yY][iI][nN][tT];
MONEY     : [mM][oO][nN][eE][yY];
NUMERIC   : [nN][uU][mM][eE][rR][iI][cC];
DECIMAL   : [dD][eE][cC][iI][mM][aA][lL];
VARCHAR   : [vV][aA][rR][cC][hH][aA][rR];
NVARCHAR  : [nN][vV][aA][rR][cC][hH][aA][rR];
CHAR      : [cC][hH][aA][rR];
DATE      : [dD][aA][tT][eE];
DATETIME  : [dD][aA][tT][eE][tT][iI][mM][eE];
BIT       : [bB][iI][tT];
TEXT      : [tT][eE][xX][tT];

/* SQL Keywords */
CREATE       : [cC][rR][eE][aA][tT][eE];
PROCEDURE    : [pP][rR][oO][cC][eE][dD][uU][rR][eE];
PROC         : [pP][rR][oO][cC];
AS           : [aA][sS];
SELECT       : [sS][eE][lL][eE][cC][tT];
FROM         : [fF][rR][oO][mM];
WHERE        : [wW][hH][eE][rR][eE];
INSERT       : [iI][nN][sS][eE][rR][tT];
INTO         : [iI][nN][tT][oO];
VALUES       : [vV][aA][lL][uU][eE][sS];
UPDATE       : [uU][pP][dD][aA][tT][eE];
DELETE       : [dD][eE][lL][eE][tT][eE];
DECLARE      : [dD][eE][cC][lL][aA][rR][eE];
SET          : [sS][eE][tT];
IF           : [iI][fF];
ELSE         : [eE][lL][sS][eE];
WHILE        : [wW][hH][iI][lL][eE];
PRINT        : [pP][rR][iI][nN][tT];
RETURN       : [rR][eE][tT][uU][rR][nN];
EXEC         : [eE][xX][eE][cC];
ROLLBACK     : [rR][oO][lL][lL][bB][aA][cC][kK];
TRANSACTION  : [tT][rR][aA][nN][sS][aA][cC][tT][iI][oO][nN];
TRAN         : [tT][rR][aA][nN];
TRIGGER      : [tT][rR][iI][gG][gG][eE][rR];
FUNCTION     : [fF][uU][nN][cC][tT][iI][oO][nN];
RETURNS      : [rR][eE][tT][uU][rR][nN][sS];
TABLE        : [tT][aA][bB][lL][eE];
PRIMARY      : [pP][rR][iI][mM][aA][rR][yY];
KEY          : [kK][eE][yY];
NOT          : [nN][oO][tT];
NULL         : [nN][uU][lL][lL];
IN           : [iI][nN];
AND          : [aA][nN][dD];
OR           : [oO][rR];
JOIN         : [jJ][oO][iI][nN];
ON           : [oO][nN];
INNER        : [iI][nN][nN][eE][rR];
LEFT         : [lL][eE][fF][tT];
RIGHT        : [rR][iI][gG][hH][tT];
FULL         : [fF][uU][lL][lL];
OUTER        : [oO][uU][tT][eE][rR];
CROSS        : [cC][rR][oO][sS][sS];
CASE         : [cC][aA][sS][eE];
WHEN         : [wW][hH][eE][nN];
THEN         : [tT][hH][eE][nN];
GOTO         : [gG][oO][tT][oO];
BREAK        : [bB][rR][eE][aA][kK];
CONTINUE     : [cC][oO][nN][tT][iI][nN][uU][eE];
ISNULL       : [iI][sS][nN][uU][lL][lL];
CONVERT      : [cC][oO][nN][vV][eE][rR][tT];
DATEDIFF     : [dD][aA][tT][eE][dD][iI][fF][fF];
SUBSTRING    : [sS][uU][bB][sS][tT][rR][iI][nN][gG];
GETDATE      : [gG][eE][tT][dD][aA][tT][eE];
ABS          : [aA][bB][sS];
RTRIM        : [rR][tT][rR][iI][mM];
LTRIM        : [lL][tT][rR][iI][mM];
LEN          : [lL][eE][nN];
CHARINDEX    : [cC][hH][aA][rR][iI][nN][dD][eE][xX];
INDEX_COL    : [iI][nN][dD][eE][xX] '_' [cC][oO][lL];
COL_NAME     : [cC][oO][lL] '_' [nN][aA][mM][eE];
OBJECT_ID    : [oO][bB][jJ][eE][cC][tT] '_' [iI][dD];
OBJECT_NAME  : [oO][bB][jJ][eE][cC][tT] '_' [nN][aA][mM][eE];
USER_NAME    : [uU][sS][eE][rR] '_' [nN][aA][mM][eE];
DB_NAME      : [dD][bB] '_' [nN][aA][mM][eE];
DB_ID        : [dD][bB] '_' [iI][dD];
PATINDEX     : [pP][aA][tT][iI][nN][dD][eE][xX];
LOWER        : [lL][oO][wW][eE][rR];
UPPER        : [uU][pP][pP][eE][rR];
COUNT        : [cC][oO][uU][nN][tT];
MAX          : [mM][aA][xX];
MIN          : [mM][iI][nN];
AVG          : [aA][vV][gG];
SUM          : [sS][uU][mM];
DISTINCT     : [dD][iI][sS][tT][iI][nN][cC][tT];
TOP          : [tT][oO][pP];
GROUP        : [gG][rR][oO][uU][pP];
BY           : [bB][yY];
HAVING       : [hH][aA][vV][iI][nN][gG];
ORDER        : [oO][rR][dD][eE][rR];
ASC          : [aA][sS][cC];
DESC         : [dD][eE][sS][cC];
UNION        : [uU][nN][iI][oO][nN];
ALL          : [aA][lL][lL];
USER         : [uU][sS][eE][rR];
AFTER        : [aA][fF][tT][eE][rR];
BEFORE       : [bB][eE][fF][oO][rR][eE];
INSTEAD      : [iI][nN][sS][tT][eE][aA][dD];
OF           : [oO][fF];

ROWCOUNT     : [rR][oO][wW][cC][oO][uU][nN][tT];

NOT_IN       : NOT IN;

/* Operators and Symbols */
EQUAL           : '=';
NOT_EQUAL       : '!=' | '<>';
GREATER_THAN    : '>';
LESS_THAN       : '<';
GREATER_EQUAL   : '>=';
LESS_EQUAL      : '<=';
COMMA           : ',';
SEMICOLON       : ';';
LEFT_PAREN      : '(';
RIGHT_PAREN     : ')';
DOT             : '.';
STAR            : '*';
PLUS            : '+';
MINUS           : '-';
DIVIDE          : '/';
PERCENT         : '%';
AMPERSAND       : '&';
BAR             : '|';
CARET           : '^';
COLON           : ':';
HASH            : '#';
AT_SIGN         : '@';

/* Identifiers (placed after keywords) */
IDENTIFIER
    : [a-zA-Z_][a-zA-Z_0-9]*
    ;

/* Literals */
STRING_LITERAL
    : '\'' ( '\'\'' | ~'\'' )* '\''
    | '"' ( '""' | ~'"' )* '"'
    ;

NUMBER_LITERAL
    : [0-9]+ ('.' [0-9]+)?
    ;

/* Whitespace and comments */
WS
    : [ \t\r\n]+ -> skip
    ;

COMMENT
    : '--' ~[\r\n]* -> skip
    ;

MULTILINE_COMMENT
    : '/*' .*? '*/' -> skip
    ;
