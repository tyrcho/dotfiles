# Visualization & Plotly

When making iterative changes to Python visualization code (Plotly treemaps, Mermaid diagrams), test the output after each change before moving to the next.

For Plotly specifically:
- `branchvalues` must be set correctly
- `marker.opacity` is silently ignored
- Per-node styling requires `marker.colors` (not opacity)
