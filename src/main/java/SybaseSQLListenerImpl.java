import org.antlr.v4.runtime.tree.TerminalNode;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class SybaseSQLListenerImpl extends SybaseSQLBaseListener {

    private Set<String> sourceTables = new HashSet<>();
    private Set<String> tempTables = new HashSet<>();
    private List<String> fields = new ArrayList<>();
    private List<String> criteria = new ArrayList<>();
    private List<String> operations = new ArrayList<>();
    private List<String> inputParameters = new ArrayList<>();

    @Override
    public void enterSelectStatement(SybaseSQLParser.SelectStatementContext ctx) {
        // Extract fields from SELECT statements
        if (ctx.selectElements() != null) {
            fields.add(ctx.selectElements().getText());
        }

        // Extract tables from FROM clause
        if (ctx.tableJoinList() != null) {
            processTableJoinList(ctx.tableJoinList());
        }

        // Extract criteria from WHERE clause
        if (ctx.whereClause() != null) {
            criteria.add(ctx.whereClause().getText());
        }
    }

    @Override
    public void enterInsertStatement(SybaseSQLParser.InsertStatementContext ctx) {
        String tableName = extractTableName(ctx.tableName());
        operations.add("INSERT INTO " + tableName);

        addTableName(tableName, ctx.tableName());
    }

    @Override
    public void enterUpdateStatement(SybaseSQLParser.UpdateStatementContext ctx) {
        String tableName = extractTableName(ctx.tableName());
        operations.add("UPDATE " + tableName);

        addTableName(tableName, ctx.tableName());

        if (ctx.whereClause() != null) {
            criteria.add(ctx.whereClause().getText());
        }
    }

    @Override
    public void enterDeleteStatement(SybaseSQLParser.DeleteStatementContext ctx) {
        String tableName = extractTableName(ctx.tableName());
        operations.add("DELETE FROM " + tableName);

        addTableName(tableName, ctx.tableName());

        if (ctx.whereClause() != null) {
            criteria.add(ctx.whereClause().getText());
        }
    }

    @Override
    public void enterCreateTableStatement(SybaseSQLParser.CreateTableStatementContext ctx) {
        String tableName = extractTableName(ctx.tableName());
        operations.add("CREATE TABLE " + tableName);

        addTableName(tableName, ctx.tableName());
    }

    @Override
    public void enterProcedureDefinition(SybaseSQLParser.ProcedureDefinitionContext ctx) {
        // Extract the input parameters
        if (ctx.parameterList() != null) {
            for (SybaseSQLParser.ParameterContext param : ctx.parameterList().parameter()) {
                inputParameters.add(param.variable().getText() + " " + param.dataType().getText());
            }
        }
    }

    // Helper method to process table join list in SELECT statements
    private void processTableJoinList(SybaseSQLParser.TableJoinListContext ctx) {
        for (SybaseSQLParser.TableExpressionContext tableExprCtx : ctx.tableExpression()) {
            processTableExpression(tableExprCtx);
        }
    }

    // Helper method to process table expressions
    private void processTableExpression(SybaseSQLParser.TableExpressionContext ctx) {
        if (ctx.tableName() != null) {
            String tableName = extractTableName(ctx.tableName());
            addTableName(tableName, ctx.tableName());
        } else if (ctx.selectStatement() != null) {
            // Handle subqueries if necessary
        }
        // Handle aliases if necessary
    }

    // Helper method to extract table name including temporary table prefix
    private String extractTableName(SybaseSQLParser.TableNameContext tableNameCtx) {
        String tableName;
        if (tableNameCtx.HASH() != null) {
            // It's a temporary table
            tableName = "#" + tableNameCtx.IDENTIFIER().getText();
        } else {
            // It's a regular table
            tableName = tableNameCtx.IDENTIFIER().getText();
        }
        return tableName;
    }

    // Helper method to add table names to appropriate sets
    private void addTableName(String tableName, SybaseSQLParser.TableNameContext tableNameCtx) {
        if (isTemporaryTable(tableNameCtx)) {
            tempTables.add(tableName);
        } else {
            sourceTables.add(tableName);
        }
    }

    // Helper method to check if a table is temporary
    private boolean isTemporaryTable(SybaseSQLParser.TableNameContext tableNameCtx) {
        return tableNameCtx.HASH() != null;
    }

    public Set<String> getSourceTables() {
        return sourceTables;
    }

    public Set<String> getTempTables() {
        return tempTables;
    }

    public List<String> getFields() {
        return fields;
    }

    public List<String> getCriteria() {
        return criteria;
    }

    public List<String> getOperations() {
        return operations;
    }

    public List<String> getInputParameters() {
        return inputParameters;
    }
}
