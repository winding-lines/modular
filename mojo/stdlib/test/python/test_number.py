# ===----------------------------------------------------------------------=== #
# Copyright (c) 2026, Modular Inc. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ===----------------------------------------------------------------------=== #

"""Integration test for NumberProtocolBuilder (unary, bool, conversion slots)."""

import operator
from collections.abc import Callable
from typing import Any

import number_mojo_module as mojo_module  # type: ignore[import-not-found]


def _run_number_assertions(
    new_fn: Callable[..., Any], val_fn: Callable[..., Any]
) -> None:
    n = new_fn

    # __neg__ (nb_negative)
    assert val_fn(-n(7)) == -7
    assert val_fn(-n(-3)) == 3

    # __abs__ (nb_absolute)
    assert val_fn(abs(n(-5))) == 5
    assert val_fn(abs(n(5))) == 5

    # __pos__ (nb_positive)
    assert val_fn(+n(4)) == 4

    # __invert__ (nb_invert)
    assert val_fn(~n(0)) == -1
    assert val_fn(~n(6)) == -7

    # __bool__ (nb_bool)
    assert bool(n(1))
    assert bool(n(-1))
    assert not bool(n(0))

    # __int__ (nb_int)
    assert int(n(42)) == 42

    # __float__ (nb_float)
    assert float(n(3)) == 3.0

    # __index__ (nb_index)
    assert operator.index(n(10)) == 10
    lst = [0, 1, 2, 3]
    assert lst[n(2)] == 2


def test_number_protocol() -> None:
    print("Testing number protocol...")
    _run_number_assertions(mojo_module.Number.new, lambda x: x.get_value())
    print("  ptr-receiver: ok")
    _run_number_assertions(mojo_module.NumberV.new, lambda x: x.get_value())
    print("  value-receiver: ok")
    print("Number protocol tests passed!")


if __name__ == "__main__":
    test_number_protocol()
