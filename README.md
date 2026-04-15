# PayComb

This repo provides a domain-specific language (DSL) for calculating and visualizing financial payoffs. 
The interpreter is built in OCaml using `menhir` for parsing and `ocamllex` for lexing. 
A Java-based GUI is also available for a more interactive experience.

## Prerequisites

### OCaml Interpreter
- [OCaml](https://ocaml.org/docs/install.ocaml.html)
- [Opam](https://opam.ocaml.org/doc/Install.html)
- [Dune](https://dune.build/install)

### Java GUI
- Java Development Kit (JDK) 11 or higher.

## Building the Interpreter
To run the OCaml interpreter, use the following command:
```powershell
opam exec -- dune build src/main.exe
```

## Running the Interpreter (CLI)
To execute a `.payoff` script, run the built executable followed by the path to your script:
```powershell
./payoff_interpreter.exe <filename>.payoff
```

### Example Usage
Create a file named `example.payoff` with the following content:
```ocaml
let strike = 5;
let strad = Call(strike) + Put(strike);
ST = 1, 2, 3, 4, 5;
print(strad);

let mybool = Straddle(5) == Call(5) + Put(5);
print(mybool);

let s = 10;
print(strad(s));
```
Run the script:
```powershell
./payoff_interpreter.exe example.payoff
```

## Running the Graphical User Interface (GUI)
The GUI allows you to write Payoff DSL code in the editor and click "Run Code" to see the output from the interpreter.

To run the GUI, you can use the provided JAR file in the project root:
```powershell
java -jar PayoffGUI.jar
```
Alternatively, you can run it using the class files from the `UserInterface/bin` directory:
```powershell
java -cp UserInterface/bin main.App
```
*(Ensure `payoff_interpreter.exe` is in the project root directory.)*