# Nix flake templates for easy dev environments

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

To initialize (where `${ENV}` is listed in the table below):

```shell
nix flake init --template github:chessl/flake-templates#${ENV}
```

Here's an example (for the [`rust`](./rust) template):

```shell
# Initialize in the current project
nix flake init --template github:chessl/flake-templates#rust

# Create a new project
nix flake new --template github:chessl/flake-templates#rust ${NEW_PROJECT_DIRECTORY}
```

## How to use the templates

Once your preferred template has been initialized, you can use the provided shell in two ways:

1. If you have \[`nix-direnv`\]\[nix-direnv\] installed, you can initialize the environment by running `direnv allow`.
1. If you don't have `nix-direnv` installed, you can run `nix develop` to open up the Nix-defined shell.

## Available templates

| Language/framework/tool | Template                  |
| :---------------------- | :------------------------ |
| \[C\]/\[C++\]           | [`c-cpp`](./c-cpp/)       |
| Empty (change at will)  | [`empty`](./empty)        |
| \[Go\]                  | [`go`](./go/)             |
| \[Haskell\]             | [`haskell`](./haskell/)   |
| \[Node.js\]\[node\]     | [`node`](./node/)         |
| \[Ruby\]                | [`ruby`](./ruby/)         |
| \[Rust\]                | [`rust`](./rust/)         |
| \[RISC-V\]              | [`riscv`](./riscv/)       |
| \[BlueSpec\]            | [`bluespec`](./bluespec/) |
| \[Clash\]               | [`clash`](./clash/)       |
| \[Zig\]                 | [`zig`](./zig/)           |
| \[Markdown\]            | [`markdown`](./markdown/) |

## Template contents

The sections below list what each template includes. In all cases, you're free to add and remove packages as you see fit; the templates are just boilerplate.

### [`c-cpp`](./c-cpp/)

- \[clang-tools\] 17.0.6
- \[cmake\] 3.28.3
- \[codespell\] 2.2.6
- \[conan\] 2.0.17
- \[cppcheck\] 2.13.4
- \[doxygen\] 1.10.0
- \[gdb\] 14.1
- \[gtest\] 1.12.1
- \[lcov\] 1.0
- \[vcpkg\]
- \[vcpkg-tool\]

### [`go`](./go/)

- \[Go\] 1.20.5
- Standard Go tools (\[goimports\], \[godoc\], and others)
- \[golangci-lint\]

### [`haskell`](./haskell/)

- \[GHC\]\[haskell\] 9.2.8
- \[cabal\] 3.10.1.0

### [`node`](./node/)

- \[Node.js\]\[node\] 22.2.0
- \[npm\] 9.5.1
- \[pnpm\] 8.6.6
- \[node2nix\] 1.11.0
- \[typescript\] 5.4.5
- \[typescript-language-server\] 4.3.3

### [`ruby`](./ruby/)

- \[Ruby\] 3.2.2, plus the standard Ruby tools (`bundle`, `gem`, etc.)

### [`rust`](./rust/)

- \[Rust\], including \[cargo\], \[Clippy\], and the other standard tools. The Rust version is determined as follows, in order:

  - From the `rust-toolchain.toml` file if present
  - From the `rust-toolchain` file if present
  - Version 1.78.0 if neither is present

- \[rust-analyzer\] 2024-04-29

- \[cargo-edit\] 0.12.2

- \[cargo-deny\] 0.14.23

### [`zig`](./zig/)

- \[Zig\] 0.10.1

### [`markdown`](./markdown/)

- \[mdformat\] 0.7.17, with:
  - \[mdformat-tables\] 0.4.1
