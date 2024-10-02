import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class SybaseParserTest {

    public static void main(String[] args) {
        try {
            // Path to the SQL file
            String filePath = "src/main/sql/sp2.sql";

            // Read the file content into a String
            String storedProc = new String(Files.readAllBytes(Paths.get(filePath)));

            // Create a CharStream from the SQL content
            CharStream input = CharStreams.fromString(storedProc);

            // Instantiate the lexer with the input
            SybaseSQLLexer lexer = new SybaseSQLLexer(input);

            // Create a token stream from the lexer
            CommonTokenStream tokens = new CommonTokenStream(lexer);

            // Instantiate the parser with the token stream
            SybaseSQLParser parser = new SybaseSQLParser(tokens);

            // Parse the input as a stored procedure definition
            SybaseSQLParser.ProcedureDefinitionContext context = parser.procedureDefinition();

            // Walk through the parse tree
            ParseTreeWalker walker = new ParseTreeWalker();
            SybaseSQLListenerImpl listener = new SybaseSQLListenerImpl();
            walker.walk(listener, context);

            // After walking, we can print the collected details
            System.out.println("Source Tables: " + listener.getSourceTables());
            System.out.println("Temporary Tables: " + listener.getTempTables());
            System.out.println("Fields/Columns Used: " + listener.getFields());
            System.out.println("Criteria (WHERE conditions): " + listener.getCriteria());
            System.out.println("Operations (INSERT, UPDATE, DELETE): " + listener.getOperations());

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
