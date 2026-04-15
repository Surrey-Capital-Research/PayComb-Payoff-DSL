package main;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.InputStreamReader;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTextArea;

public class MainWindow extends JFrame {
    private JTextArea editor;
    private JTextArea output;

    public MainWindow() {
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setTitle("Payoff DSL Interpreter");
        this.setLayout(new BorderLayout());

        editor = new JTextArea();
        editor.setFont(new Font("Monospaced", Font.PLAIN, 14));
        editor.setText("// Enter your Payoff DSL code here\n" +
                        "let strike = 5;\n" +
                        "let strad = Call(strike) + Put(strike);\n" +
                        "ST = 1, 2, 3, 4, 5;\n" +
                        "print(strad);\n");
        JScrollPane editorScroll = new JScrollPane(editor);
        editorScroll.setPreferredSize(new Dimension(800, 400));

        output = new JTextArea();
        output.setFont(new Font("Monospaced", Font.PLAIN, 14));
        output.setEditable(false);
        output.setBackground(Color.LIGHT_GRAY);
        JScrollPane outputScroll = new JScrollPane(output);
        outputScroll.setPreferredSize(new Dimension(800, 200));

        JSplitPane splitPane = new JSplitPane(JSplitPane.VERTICAL_SPLIT, editorScroll, outputScroll);
        splitPane.setDividerLocation(400);
        this.add(splitPane, BorderLayout.CENTER);

        JButton runButton = new JButton("Run Code");
        runButton.addActionListener(this::runCode);
        JPanel buttonPanel = new JPanel();
        buttonPanel.add(runButton);
        this.add(buttonPanel, BorderLayout.SOUTH);

        this.pack();
        this.setLocationRelativeTo(null);
        this.setVisible(true);
    }

    private void runCode(ActionEvent event) {
        output.setText("Running...\n");
        try {
            // Save the editor content to a temporary file
            File tempFile = File.createTempFile("temp", ".payoff");
            BufferedWriter writer = new BufferedWriter(new FileWriter(tempFile));
            writer.write(editor.getText());
            writer.close();

            // Run the OCaml interpreter
            // Rename main.exe to payoff_interpreter.exe
            ProcessBuilder pb = new ProcessBuilder("payoff_interpreter.exe", tempFile.getAbsolutePath());
            pb.directory(new File(".")); // Set working directory to the current one.
            pb.redirectErrorStream(true);
            Process process = pb.start();

            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            StringBuilder result = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                result.append(line).append("\n");
            }
            process.waitFor();
            output.setText(result.toString());

            tempFile.delete();
        } catch (Exception e) {
            output.setText("Error: " + e.getMessage());
        }
    }
}
