# DoubleEnded

`DoubleEnded.jl` provides `MutableList`, a mutable double-ended list.
It stores its elements in the immutable singly linked list of
[ImmutableList.jl](https://github.com/OpenModelica/ImmutableList.jl) and keeps
pointers to the first and the last cell. Pushing and popping at the front
and pushing at the back take O(1). The length is stored, so `length` is O(1).

## Installation

The package is in the OpenModelica registry
(<https://github.com/OpenModelica/OpenModelicaRegistry>). The latest version in
that registry is 0.2.5. The `master` branch is at 0.2.6.

Install the registered version. The General registry must also be present:
ExportAll.jl and ImmutableList.jl are resolved from it. CI adds both registries
if they are missing.

```julia
using Pkg
Pkg.Registry.add(Pkg.RegistrySpec(url="https://github.com/OpenModelica/OpenModelicaRegistry"))
Pkg.add("DoubleEnded")
```

Install the `master` branch (0.2.6):

```julia
using Pkg
Pkg.add(url="https://github.com/OpenModelica/DoubleEnded.jl")
```

Requirements: Julia 1.13 (`julia = "1.13"` in `Project.toml`). The package
depends on ExportAll.jl and ImmutableList.jl (compat `0.4.2, 0.5, 0.6`).

## Usage

```julia
using DoubleEnded
using ImmutableList

dl = DoubleEnded.fromList(list(1, 2, 3))  # MutableList{Int64}
DoubleEnded.push_front(dl, 0)
DoubleEnded.push_back(dl, 4)
println(length(dl))                       # 5
println(DoubleEnded.pop_front(dl))        # 0
println(collect(dl))                      # [1, 2, 3, 4]
lst = DoubleEnded.toListAndClear(dl)      # ImmutableList 1, 2, 3, 4; dl is empty
```

## Functions

`MutableList` and `new`, `fromList`, `clear`, `currentBackCell`,
`mapNoCopy_1`, `mapFoldNoCopy`, `pop_front`, `push_back`, `push_front`,
`push_list_back`, `push_list_front`, `toListAndClear`, `toListNoCopyNoClear`,
`_iter` and `eval` are exported (`@exportAll`). `empty` is not exported: call
it as `DoubleEnded.empty`. `length` and iteration extend Base.

Constructors:

- `new(first)`: a new list with the one element `first`. The element type is `typeof(first)`.
- `fromList(lst)`: a new list with the elements of the ImmutableList `lst`, in order. Runs in O(n). The list does not share cells with `lst`. `fromList(nil)` returns `MutableList{Any}`.
- `empty(dummy)`: an empty list of element type `typeof(dummy)`.
- `empty()`: an empty `MutableList{Any}`.

Queries:

- `length(dl)`: the number of elements, O(1).
- `currentBackCell(dl)`: the last cell, or `nil` if the list is empty.
- `toListNoCopyNoClear(dl)`: the elements as an ImmutableList, without copying or clearing `dl`. If `dl` is non-empty, in-place changes (`push_back`, `mapNoCopy_1`, `mapFoldNoCopy`) show through the returned list. `push_front`, `pop_front` and `clear` do not. If `dl` is empty, the result is `nil` and stays `nil`.
- `for x in dl` and `collect(dl)`: iterate over the elements, front to back.

Adding elements (the element is converted to `T` with `convert`):

- `push_front(dl, elt)`: prepends `elt`, O(1). Returns `dl`.
- `push_back(dl, elt)`: appends `elt`, O(1). Returns `dl`.
- `push_list_front(dl, lst)`: prepends the elements of the ImmutableList `lst`, O(n). Returns `dl`.
- `push_list_back(dl, lst)`: appends the elements of the ImmutableList `lst`, O(n). Returns `dl`.

Removing elements:

- `pop_front(dl)`: removes and returns the first element. Throws `ArgumentError` if `dl` is empty.
- `clear(dl)`: removes all elements. Returns `dl`.
- `toListAndClear(dl; prependToList = nil)`: returns the elements as an ImmutableList, followed by `prependToList`, and clears `dl`. The splice is O(1).

In-place maps:

- `mapNoCopy_1(dl, f, arg)`: replaces each element `e` by `f(e, arg)`. Returns `dl`.
- `mapFoldNoCopy(dl, f, arg)`: replaces each element `e` by `newE` from `(newE, newAcc) = f(e, acc)`, starting with `acc = arg`. Returns the final `acc`.

`_iter` is an internal iteration helper. It is exported because of `@exportAll`, but it is not part of the API.

## Tests

Run from the package directory:

```
julia --project=. -e 'using Pkg; Pkg.test()'
```

The test environment needs the `Test` standard library only. CI runs the same
command on Julia 1.13 (`.github/workflows/CI.yml`). CI adds the General and
the OpenModelica registries first, if they are missing.

## License

The code is licensed under the GNU Affero General Public License v3 or the
OSMC Public License v1.8, at the recipient's choice (source file header). The
full texts are in `LICENSE.md`.
