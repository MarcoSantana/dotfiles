# 💎 Ruby on Rails Development in LazyVim

This guide explains how to use the Ruby and Rails features in your new Neovim setup.

## 🚀 Starting a New Project

The standard way to start a Rails project:

1. **Install Rails**: `gem install rails` (if not already installed)
2. **Create project**: `rails new my-app --database=postgresql` (or your preferred DB)
3. **Setup DB**: `cd my-app && bin/rails db:create`
4. **Run Server**: `bin/rails server`

## 🔌 How to use Rails Features

### 1. vim-rails (The Powerhouse)
This plugin turns Neovim into a Rails IDE by understanding your project structure.

* **Smart Navigation**:
  * While in a controller, type **`:A`** to jump to its corresponding view.
  * While in a model, type **`:A`** to jump to its unit test/spec.
  * Use **`:Rmodel User`** to jump to the `User` model from anywhere.
* **View Extraction**: Highlight a block of HTML in a view and run **`:'<,'>Rextract shared/form`**. It will move that code to a partial and replace it with a `render` call.
* **Console & Server**: You can run **`:Rconsole`** or **`:Rgenerate`** directly from within Neovim.

### 2. Ruby LSP (Solargraph / Ruby-LSP)
* **Autocomplete**: Standard `Ctrl-n` or `nvim-cmp` completions for Ruby methods and classes.
* **Jump to Definition**: Press **`gd`** on any method or class to jump to its source (even inside gems).
* **Hover Docs**: Press **`K`** (Shift+k) on a method to see its YARD documentation.

### 3. Testing (vim-test / snacks.test)
LazyVim comes with testing support built-in.
* **`<leader>tr`**: Run the test nearest to your cursor.
* **`<leader>tf`**: Run the current test file.
* **`<leader>ts`**: Run the whole test suite.

## 🛠️ Recommended Setup
Ensure you have the following gems in your `Gemfile` (in the `:development` group) for the best experience:
```ruby
group :development do
  gem 'solargraph' # For LSP
  gem 'rubocop'    # For linting/formatting
end
```
Then run `bundle install`.
