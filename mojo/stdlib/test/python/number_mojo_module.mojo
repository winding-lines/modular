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

# ===----------------------------------------------------------------------=== #
# Test for NumberProtocolBuilder unary/bool/conversion slots.
#
# Exposes a Number type (wrapping Int) to Python that supports:
#   - -n, abs(n), +n, ~n                   via nb_negative/absolute/positive/invert
#   - bool(n)                              via nb_bool
#   - int(n), float(n), operator.index(n)  via nb_int/float/index
# ===----------------------------------------------------------------------=== #

from std.os import abort
from std.memory import UnsafePointer
from std.python import PythonObject
from std.python.bindings import PythonModuleBuilder

from std.python.builders import NumberProtocolBuilder
from std.python.utils import PySlotError


def _alloc[
    T: Movable & ImplicitlyDestructible
](var value: T) raises PySlotError -> PythonObject:
    """Translate `PythonObject(alloc=...)`'s plain `Error` into `PySlotError`.
    """
    try:
        return PythonObject(alloc=value^)
    except e:
        raise PySlotError.runtime_error(String(e))


struct Number(Defaultable, Movable, Writable):
    var value: Int

    def __init__(out self):
        self.value = 0

    def __init__(out self, value: Int):
        self.value = value

    @staticmethod
    def _get_self_ptr(
        py_self: PythonObject,
    ) -> UnsafePointer[Self, MutAnyOrigin]:
        try:
            return py_self.downcast_value_ptr[Self]()
        except e:
            abort(String("downcast failed: ", e))

    @staticmethod
    def new(value: PythonObject) raises -> PythonObject:
        return PythonObject(alloc=Number(Int(py=value)))

    @staticmethod
    def get_value(py_self: PythonObject) raises -> PythonObject:
        return PythonObject(Self._get_self_ptr(py_self)[].value)

    # ------------------------------------------------------------------
    # Unary slots
    # ------------------------------------------------------------------

    @staticmethod
    def py__neg__(
        self_ptr: UnsafePointer[Self, MutAnyOrigin]
    ) raises PySlotError -> PythonObject:
        return _alloc(Number(-self_ptr[].value))

    @staticmethod
    def py__abs__(
        self_ptr: UnsafePointer[Self, MutAnyOrigin]
    ) raises PySlotError -> PythonObject:
        return _alloc(Number(abs(self_ptr[].value)))

    @staticmethod
    def py__pos__(
        self_ptr: UnsafePointer[Self, MutAnyOrigin]
    ) raises PySlotError -> PythonObject:
        return _alloc(Number(self_ptr[].value))

    @staticmethod
    def py__invert__(
        self_ptr: UnsafePointer[Self, MutAnyOrigin]
    ) raises PySlotError -> PythonObject:
        return _alloc(Number(~self_ptr[].value))

    # ------------------------------------------------------------------
    # Bool slot
    # ------------------------------------------------------------------

    @staticmethod
    def py__bool__(
        self_ptr: UnsafePointer[Self, MutAnyOrigin]
    ) raises PySlotError -> Bool:
        return self_ptr[].value != 0

    # ------------------------------------------------------------------
    # Conversion slots
    # ------------------------------------------------------------------

    @staticmethod
    def py__int__(
        self_ptr: UnsafePointer[Self, MutAnyOrigin]
    ) raises PySlotError -> PythonObject:
        return PythonObject(self_ptr[].value)

    @staticmethod
    def py__float__(
        self_ptr: UnsafePointer[Self, MutAnyOrigin]
    ) raises PySlotError -> PythonObject:
        return PythonObject(Float64(self_ptr[].value))

    @staticmethod
    def py__index__(
        self_ptr: UnsafePointer[Self, MutAnyOrigin]
    ) raises PySlotError -> PythonObject:
        return PythonObject(self_ptr[].value)

    def write_to(self, mut writer: Some[Writer]):
        writer.write("Number(", self.value, ")")


# NumberV uses value-receiver handlers.  Unary/bool/conversion slots are
# non-raising for the bool slot and raising for the rest.
struct NumberV(Defaultable, Movable, Writable):
    var value: Int

    def __init__(out self):
        self.value = 0

    def __init__(out self, value: Int):
        self.value = value

    @staticmethod
    def _get_self_ptr(
        py_self: PythonObject,
    ) -> UnsafePointer[Self, MutAnyOrigin]:
        try:
            return py_self.downcast_value_ptr[Self]()
        except e:
            abort(String("downcast failed: ", e))

    @staticmethod
    def new(value: PythonObject) raises -> PythonObject:
        return PythonObject(alloc=NumberV(Int(py=value)))

    @staticmethod
    def get_value(py_self: PythonObject) raises -> PythonObject:
        return PythonObject(Self._get_self_ptr(py_self)[].value)

    # Value-receiver handlers — unary slots return a new Python-boxed NumberV
    def py__neg__(self) raises PySlotError -> PythonObject:
        return _alloc(NumberV(-self.value))

    def py__abs__(self) raises PySlotError -> PythonObject:
        return _alloc(NumberV(abs(self.value)))

    def py__pos__(self) raises PySlotError -> PythonObject:
        return _alloc(NumberV(self.value))

    def py__invert__(self) raises PySlotError -> PythonObject:
        return _alloc(NumberV(~self.value))

    def py__bool__(self) -> Bool:
        return self.value != 0

    def py__int__(self) raises PySlotError -> PythonObject:
        return PythonObject(self.value)

    def py__float__(self) raises PySlotError -> PythonObject:
        return PythonObject(Float64(self.value))

    def py__index__(self) raises PySlotError -> PythonObject:
        return PythonObject(self.value)

    def write_to(self, mut writer: Some[Writer]):
        writer.write("NumberV(", self.value, ")")


@export
def PyInit_number_mojo_module() -> PythonObject:
    try:
        var b = PythonModuleBuilder("number_mojo_module")
        ref tb = (
            b.add_type[Number]("Number")
            .def_init_defaultable[Number]()
            .def_staticmethod[Number.new]("new")
            .def_method[Number.get_value]("get_value")
        )
        var npb = NumberProtocolBuilder[Number](tb)
        _ = (
            npb.def_neg[Number.py__neg__]()
            .def_abs[Number.py__abs__]()
            .def_pos[Number.py__pos__]()
            .def_invert[Number.py__invert__]()
            .def_bool[Number.py__bool__]()
            .def_int[Number.py__int__]()
            .def_float[Number.py__float__]()
            .def_index[Number.py__index__]()
        )
        ref tbv = (
            b.add_type[NumberV]("NumberV")
            .def_init_defaultable[NumberV]()
            .def_staticmethod[NumberV.new]("new")
            .def_method[NumberV.get_value]("get_value")
        )
        var npbv = NumberProtocolBuilder[NumberV](tbv)
        _ = (
            npbv.def_neg[NumberV.py__neg__]()
            .def_abs[NumberV.py__abs__]()
            .def_pos[NumberV.py__pos__]()
            .def_invert[NumberV.py__invert__]()
            .def_bool[NumberV.py__bool__]()
            .def_int[NumberV.py__int__]()
            .def_float[NumberV.py__float__]()
            .def_index[NumberV.py__index__]()
        )
        return b.finalize()
    except e:
        abort(String("failed to create Python module: ", e))
