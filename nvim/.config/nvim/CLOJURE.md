# ☯️ Clojure Development in LazyVim

This guide explains how to use the Clojure/ClojureScript features in your new Neovim setup.

## 🚀 Starting a New Project

The modern way to start a Clojure project is using **Clojure CLI tools** (Deps.edn):

1. **Create directory**: `mkdir my-cool-project && cd my-cool-project`
2. **Create deps.edn**:
   ```clojure
   {:paths ["src"]
    :deps {org.clojure/clojure {:mvn/version "1.12.0"}}}
   ```
3. **Create a source file**: `mkdir -p src/my_app && touch src/my_app/core.clj`
4. **Start the REPL**:
   * For Conjure to work, you MUST start a REPL that supports **nREPL**.
   * Run: `clojure -Sdeps '{:deps {nrepl/nrepl {:mvn/version "1.3.0"}}}' -M -m nrepl.cmdline`
   * Or use a tool like **Leiningen** (`lein repl`) or **Shadow-cljs**.

## 🔌 How to use Clojure Features

### 1. Conjure (The REPL)
Once your REPL is running, open any `.clj` file in Neovim. Conjure will **automatically connect** to the `.nrepl-port` file in your project root.

* **Evaluate Code**: Use `,ee` (current form) or `,er` (root form). Results appear in a HUD (Heads-up Display).
* **View Logs**: If you want a persistent log of evaluations, use `,ls` (Log Split).
* **Documentation**: Press `K` (Shift+k) on any function to see its docstring and source.

### 2. Parinfer (Structural Editing)
You don't need to count parentheses anymore!
* **Paren Management**: Just indent your code properly using `Tab` or spaces. Parinfer will automatically adjust the closing parentheses to match your indentation.
* **Movement**: Use standard Vim keys. As you move blocks of code (e.g., with `V` and `j/k`), Parinfer keeps the structure valid.

### 3. Clojure-LSP
* **Diagnostics**: Errors and warnings will appear automatically in the gutter.
* **Refactoring**: Use `<leader>cr` (Rename) or `<leader>ca` (Code Action) to see Clojure-specific refactorings like "thread first/last", "add missing libspec", etc.
* **Go to Definition**: Use `gd` to jump to any function definition, even inside JAR files.

## 🛠️ Recommended Setup for ClojureScript
If you are working with ClojureScript (e.g., with Reagent or Shadow-cljs):
1. Start your shadow-cljs watch: `npx shadow-cljs watch app`
2. Conjure will detect the nREPL port.
3. To evaluate in the browser, ensure your app is loaded in a tab!
