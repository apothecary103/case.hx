# case.hx

A [Helix](https://github.com/helix-editor/helix) plugin for changing keyword
case, written for the [Steel](https://github.com/mattwparas/steel) plugin
system.

![Demo of case switching in Helix](demo.gif)

## Install

### With forge

[forge](https://github.com/mattwparas/steel) is the Steel package manager:

```sh
forge pkg install --git https://github.com/apothecary103/case.hx
```

### With Nix

The plugin is packaged in
[helix-plugins-nix](https://codeberg.org/maxschipper/helix-plugins-nix) as
`case`. Plugins need the `steel-event-system` branch of Helix, which is already packaged in Nix so you can just use `pkgs.steelix` instead of `pkgs.helix`.

Add the flake to your inputs:

```nix
inputs.helix-plugins.url = "github:maxschipper/helix-plugins-nix";
```

Then, with [Hjem](https://github.com/feel-co/hjem):

```nix
{ pkgs, inputs, ... }:
{
  nixpkgs.overlays = [ inputs.helix-plugins.overlays.default ];
  hjem.extraModules = [ inputs.helix-plugins.hjemModules.default ];

  hjem.users.<username>.programs.helix = {
    enable = true;
    plugins = with pkgs.helixPlugins; [ case ];
  };
}
```

The same `plugins` option exists on the home-manager module
(`inputs.helix-plugins.homeManagerModules.default`). Without either module,
build and copy the cog by hand:

```sh
nix build "github:maxschipper/helix-plugins-nix#helixPlugins.case"
cp -rL result ~/.local/share/steel/cogs/case.hx
```

### Configure

However you installed it, require it from `~/.config/helix/init.scm` and bind
the commands:

```scheme
(require "case.hx/case.scm")
(require (only-in "helix/keymaps.scm" add-global-keybinding))

;; ` enters case mode. l, u and a are helix builtins, the rest come from case.scm.
(define case-mode
  (hash "l" "switch_to_lowercase"
        "u" "switch_to_uppercase"
        "a" "switch_case"
        "c" ":switch-to-camel-case"
        "p" ":switch-to-pascal-case"
        "s" ":switch-to-snake-case"
        "k" ":switch-to-kebab-case"
        "C" ":switch-to-constant-case"
        "t" ":switch-to-title-case"
        "S" ":switch-to-sentence-case"))

(add-global-keybinding (hash "normal" (hash "`" case-mode)
                             "select" (hash "`" case-mode)))
```

Every command also works from the command line, for example
`:switch-to-snake-case`.

## Commands

| Key | Command | `hello_world` becomes |
| --- | --- | --- |
| `` `c `` | `switch-to-camel-case` | `helloWorld` |
| `` `p `` | `switch-to-pascal-case` | `HelloWorld` |
| `` `s `` | `switch-to-snake-case` | `hello_world` |
| `` `k `` | `switch-to-kebab-case` | `hello-world` |
| `` `C `` | `switch-to-constant-case` | `HELLO_WORLD` |
| `` `t `` | `switch-to-title-case` | `Hello World` |
| `` `S `` | `switch-to-sentence-case` | `Hello world` |
| `` `l `` | `switch_to_lowercase` (builtin) | `hello_world` |
| `` `u `` | `switch_to_uppercase` (builtin) | `HELLO_WORLD` |
| `` `a `` | `switch_case` (builtin) | `HELLO_WORLD` |

## Behaviour

Words are split on whitespace, `_` and `-`, and at camel boundaries, so
`fooBar` and `HTTPServer` split into `foo Bar` and `HTTP Server`. Everything
else, including `.`, `,` and digits, stays inside a word, so prose and paths
come through unharmed.

Conversion runs a line at a time and leaves each line's indentation and
trailing padding alone, so a multi-line selection keeps its shape.

All selections are converted at once, cursors end up on the rewritten text, and
the whole thing is a single undo step.

## Development

This flake is for developing the plugin, not installing it. For installation, see [helix-plugins-nix](https://codeberg.org/maxschipper/helix-plugins-nix).

Run `nix develop` to get a shell with `steel` on `PATH`, and `nix flake check` to run the tests. Without Nix, you can run the same tests with `steel test.scm`.

## Acknowledgements

Inspired by [helix#12043](https://github.com/helix-editor/helix/pull/12043) and
[coerce.nvim](https://github.com/gregorias/coerce.nvim).
