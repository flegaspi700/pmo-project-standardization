# Architecture

How the system is put together. Rules for this file and its diagrams: the
standard's `decisions.md` → Architecture docs and diagrams. Diagrams must
match the code: update them in the same change.

## Overview

<One paragraph: how the system runs (a loop, a server, a batch job, an
app) and what persists between runs.>

### System context

```mermaid
flowchart LR
    user(["User"])
    sys["This system"]
    ext[("Outside system or data")]

    user -- "uses" --> sys
    sys -- "reads" --> ext
```

### Components

```mermaid
flowchart LR
    in["Input"] -- "raw data" --> c1["Component 1"]
    c1 -- "structured data" --> c2["Component 2"]
    c2 -- "result" --> out["Output"]
```

## Components

### <Component 1>

<What it does, what it takes in, what it returns.>

## Interfaces

- **<Component 1> → <Component 2>:** <data shape, exact once it settles>

## Key decisions

| Area | Chosen | Main alternative rejected | Trade-off accepted | Decision |
|---|---|---|---|---|
| <e.g. Storage> | <e.g. JSON files> | <e.g. SQLite> | <e.g. no queries across runs> | <entry in `docs/decisions.md`> |
