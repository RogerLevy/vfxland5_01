# Nested Module System Enhancement

## Problem and Solution

Oversight must load before other Engineer components but depends on `array.vfx`, `oop.vfx`, and `dictionaries.vfx`. When these files are included privately, their `public` statements still pollute the global namespace, causing redefinition conflicts when Engineer later loads them publicly.

We need to enhance VFX Forth's public/private system so that `public` statements can be redirected to a specified wordlist instead of always going to the global FORTH vocabulary.

## Critical Rationale

Beyond avoiding redefinitions, this enables **validations within core systems themselves**:
- Array system can validate bounds and sizes using contracts
- OOP system can validate object integrity and method dispatch  
- Dictionary system can validate keys and detect collisions

This allows core systems to be self-validating without circular dependencies or namespace conflicts, creating a layered validation architecture from the ground up.

## Target Implementation

Enhancement to `scope.vfx` that allows controlled redirection of `public` statements to private wordlists during file inclusion.
