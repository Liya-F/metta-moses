"""
CSV -> MeTTa input-table loader for Boolean, numeric, and enum columns.

Called from MeTTa via:
    (py-call (csv_helper.load_table <path> <target_feature>))

Returns a STRING containing a valid MeTTa S-expression of the form
    (mkITable <columns-expression-list> <labels-expression-list>)
which the caller `parse`s back into a MeTTa term.

Every cell is checked against its column's Boolean, numeric, or enum type; any
unparseable cell raises a ValueError with row and column context so
failures are loud and locatable.
"""

import csv
import json

BOOLEAN_LITERALS = {
    "true":  "True",
    "false": "False",
    "1":     "True",
    "0":     "False",
    "yes":   "True",
    "no":    "False",
    "t":     "True",
    "f":     "False",
}


def _to_bool_literal(cell, row_num, col_name):
    s = cell.strip().lower()
    if s in BOOLEAN_LITERALS:
        return BOOLEAN_LITERALS[s]
    raise ValueError(
        "row {row}, column {col!r}: cannot parse {cell!r} as boolean. "
        "Accepted (case-insensitive): True, False, 1, 0, yes, no, t, f."
        .format(row=row_num, col=col_name, cell=cell)
    )


def _expr_list(items):
    """Render items as the expression-list shape MeTTa code consumes."""
    items = list(items)
    if not items:
        return "()"
    return "({})".format(" ".join(items))


def _cell_type(cell, row_num, col_name):
    """Infer one CSV cell as Boolean, continuous, or enum data."""
    value = cell.strip()
    if not value:
        raise ValueError(
            "row {row}, column {col!r}: empty values are not supported".format(
                row=row_num, col=col_name
            )
        )
    if value.lower() in BOOLEAN_LITERALS:
        return "boolean"
    try:
        float(value)
        return "continuous"
    except ValueError:
        if value[0].isalpha():
            return "enum"
        raise ValueError(
            "row {row}, column {col!r}: cannot infer the type of {cell!r}".format(
                row=row_num, col=col_name, cell=cell
            )
        )


def _column_type(cells, row_numbers, col_name):
    """Infer one type for a complete column, including 0/1 numeric promotion."""
    inferred = None
    for cell, row_num in zip(cells, row_numbers):
        cell_type = _cell_type(cell, row_num, col_name)
        if inferred is None:
            inferred = cell_type
        elif inferred == cell_type:
            continue
        elif {inferred, cell_type} == {"boolean", "continuous"}:
            inferred = "continuous"
        else:
            raise ValueError(
                "column {col!r}: inconsistent {left} and {right} values".format(
                    col=col_name, left=inferred, right=cell_type
                )
            )
    return inferred


def _render_cell(cell, cell_type, row_num, col_name):
    """Render one validated cell as a MeTTa value."""
    value = cell.strip()
    if cell_type == "boolean":
        return _to_bool_literal(cell, row_num, col_name)
    if cell_type == "continuous":
        try:
            float(value)
        except ValueError:
            raise ValueError(
                "row {row}, column {col!r}: cannot parse {cell!r} as a number".format(
                    row=row_num, col=col_name, cell=cell
                )
            )
        return value
    return "(mkEnum {})".format(json.dumps(value))


def load_table(path, target_feature=""):
    """Read `path` as CSV, validate every cell against its column type, move the target
    column to the end (MeTTa convention), and return an `(mkITable ...)`
    S-expression string.

    Args:
        path: filesystem path to the CSV (relative paths resolved against the
              current process working directory).
        target_feature: header name of the output column. Empty/None means
              "use the last column as-is".

    Raises:
        FileNotFoundError: if the path doesn't exist.
        ValueError: on empty file, mis-shaped row, unknown target column, or
                    any cell that doesn't match its column type.
    """
    with open(path) as f:
        rows = list(csv.reader(f))

    if not rows:
        raise ValueError("{!r}: empty CSV".format(path))

    labels = [h.strip() for h in rows[0]]
    body = rows[1:]
    if not body:
        raise ValueError("{!r}: header only, no data rows".format(path))

    if target_feature in ("", None):
        target_idx = len(labels) - 1
        target_name = labels[target_idx]
    else:
        if target_feature not in labels:
            raise ValueError(
                "target feature {tf!r} not found in columns {labels}".format(
                    tf=target_feature, labels=labels
                )
            )
        target_idx = labels.index(target_feature)
        target_name = target_feature

    new_labels = [l for i, l in enumerate(labels) if i != target_idx]
    new_labels.append(target_name)

    # Type-check every cell upfront and build a column-major table.
    num_columns = len(labels)
    validated_columns = [[] for _ in range(num_columns)]

    for r_num, row in enumerate(body, start=2):  # +1 for header, 1-indexed
        if len(row) != len(labels):
            raise ValueError(
                "row {r}: {got} columns, expected {want}".format(
                    r=r_num, got=len(row), want=len(labels)
                )
            )

    column_types = [
        _column_type([row[i] for row in body], range(2, len(body) + 2), labels[i])
        for i in range(num_columns)
    ]

    for r_num, row in enumerate(body, start=2):
        values = [
            _render_cell(row[i], column_types[i], r_num, labels[i])
            for i in range(num_columns)
        ]

        reordered = [b for i, b in enumerate(values) if i != target_idx]
        reordered.append(values[target_idx])

        for col_idx, value in enumerate(reordered):
            validated_columns[col_idx].append(value)

    columns_sexpr = _expr_list(_expr_list(col) for col in validated_columns)
    labels_sexpr = _expr_list(new_labels)
    return "(mkITable {columns} {labels})".format(
        columns=columns_sexpr, labels=labels_sexpr
    )
