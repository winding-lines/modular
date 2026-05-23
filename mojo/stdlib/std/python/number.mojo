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

"""Implements the CPython number-protocol builder.

Provides `NumberProtocolBuilder`, which installs the `nb_*` slots (unary,
binary, and ternary) on a `PythonTypeBuilder` so a Mojo struct can
implement Python's numeric dunders (`__neg__`, `__add__`, `__pow__`,
etc.).
"""

from std.memory import UnsafePointer
from std.python import PythonObject
from std.python.bindings import PythonTypeBuilder

from .utils import PySlotError

from std.python._cpython import PySlotIndex

from .adapters import _SlotInstaller


struct NumberProtocolBuilder[self_type: ImplicitlyDestructible]:
    """Installs CPython number protocol slots on a `PythonTypeBuilder`.

    Construct directly from a `PythonTypeBuilder`.  Each method is named after the
    corresponding Python dunder and accepts only the matching function signature.
    Handler functions receive `UnsafePointer[T, MutAnyOrigin]` as their first
    argument instead of a raw `PythonObject`.

    Binary methods (`def_add`, `def_mul`, etc.) and ternary methods (`def_pow`,
    `def_ipow`) support `NotImplementedError`: raise it from your handler to
    return `Py_NotImplemented` to Python, triggering the reflected operation.

    Usage:
        ```mojo
        var npb = NumberProtocolBuilder[MyStruct](tb)
        npb.def_neg[MyStruct.py__neg__]()
           .def_bool[MyStruct.py__bool__]()
           .def_add[MyStruct.py__add__]()
           .def_pow[MyStruct.py__pow__]()
        ```

    Parameters:
        self_type: The Mojo struct type whose instances back the Python object.
    """

    var _ptr: UnsafePointer[mut=True, PythonTypeBuilder, MutAnyOrigin]

    def __init__(out self, mut inner: PythonTypeBuilder):
        """Initialize from a `PythonTypeBuilder` reference.

        Args:
            inner: The `PythonTypeBuilder` to wrap.
        """
        self._ptr = UnsafePointer(to=inner)

    def __init__(
        out self,
        ptr: UnsafePointer[mut=True, PythonTypeBuilder, MutAnyOrigin],
    ):
        """Initialize from a raw pointer to a `PythonTypeBuilder`.

        Args:
            ptr: Pointer to the `PythonTypeBuilder` to wrap.
        """
        self._ptr = ptr

    # ------------------------------------------------------------------
    # Unary slots — C type: unaryfunc  def(PyObject *) -> PyObject *
    # ------------------------------------------------------------------

    def def_abs[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__abs__` via the `nb_absolute` slot.

        Called by `abs(obj)`.
        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_absolute

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary[Self.self_type, method, PySlotIndex.nb_absolute](
            self._ptr
        )
        return self

    def def_float[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__float__` via the `nb_float` slot.

        Called by `float(obj)`.
        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_float

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary[Self.self_type, method, PySlotIndex.nb_float](
            self._ptr
        )
        return self

    def def_index[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__index__` via the `nb_index` slot.

        Called by `operator.index(obj)`.
        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_index

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary[Self.self_type, method, PySlotIndex.nb_index](
            self._ptr
        )
        return self

    def def_int[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__int__` via the `nb_int` slot.

        Called by `int(obj)`.
        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_int

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary[Self.self_type, method, PySlotIndex.nb_int](
            self._ptr
        )
        return self

    def def_invert[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__invert__` via the `nb_invert` slot.

        Called by `~obj`.
        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_invert

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary[Self.self_type, method, PySlotIndex.nb_invert](
            self._ptr
        )
        return self

    def def_neg[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__neg__` via the `nb_negative` slot.

        Called by `-obj`.
        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_negative

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary[Self.self_type, method, PySlotIndex.nb_negative](
            self._ptr
        )
        return self

    def def_pos[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__pos__` via the `nb_positive` slot.

        Called by `+obj`.
        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_positive

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary[Self.self_type, method, PySlotIndex.nb_positive](
            self._ptr
        )
        return self

    # Non-raising unary overloads

    def def_abs[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__abs__` via the `nb_absolute` slot (non-raising overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_absolute

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary_nr[
            Self.self_type, method, PySlotIndex.nb_absolute
        ](self._ptr)
        return self

    def def_float[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__float__` via the `nb_float` slot (non-raising overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_float

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary_nr[Self.self_type, method, PySlotIndex.nb_float](
            self._ptr
        )
        return self

    def def_index[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__index__` via the `nb_index` slot (non-raising overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_index

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary_nr[Self.self_type, method, PySlotIndex.nb_index](
            self._ptr
        )
        return self

    def def_int[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__int__` via the `nb_int` slot (non-raising overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_int

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary_nr[Self.self_type, method, PySlotIndex.nb_int](
            self._ptr
        )
        return self

    def def_invert[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__invert__` via the `nb_invert` slot (non-raising overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_invert

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary_nr[Self.self_type, method, PySlotIndex.nb_invert](
            self._ptr
        )
        return self

    def def_neg[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__neg__` via the `nb_negative` slot (non-raising overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_negative

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary_nr[
            Self.self_type, method, PySlotIndex.nb_negative
        ](self._ptr)
        return self

    def def_pos[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__pos__` via the `nb_positive` slot (non-raising overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_positive

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary_nr[
            Self.self_type, method, PySlotIndex.nb_positive
        ](self._ptr)
        return self

    # Value-receiver unary overloads

    def def_abs[
        method: def(Self.self_type) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__abs__` via the `nb_absolute` slot (value-receiver overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_absolute

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary_val[
            Self.self_type, method, PySlotIndex.nb_absolute
        ](self._ptr)
        return self

    def def_float[
        method: def(Self.self_type) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__float__` via the `nb_float` slot (value-receiver overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_float

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """

        _SlotInstaller.unary_val[Self.self_type, method, PySlotIndex.nb_float](
            self._ptr
        )
        return self

    def def_index[
        method: def(Self.self_type) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__index__` via the `nb_index` slot (value-receiver overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_index

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary_val[Self.self_type, method, PySlotIndex.nb_index](
            self._ptr
        )
        return self

    def def_int[
        method: def(Self.self_type) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__int__` via the `nb_int` slot (value-receiver overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_int

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary_val[Self.self_type, method, PySlotIndex.nb_int](
            self._ptr
        )
        return self

    def def_invert[
        method: def(Self.self_type) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__invert__` via the `nb_invert` slot (value-receiver overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_invert

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary_val[Self.self_type, method, PySlotIndex.nb_invert](
            self._ptr
        )
        return self

    def def_neg[
        method: def(Self.self_type) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__neg__` via the `nb_negative` slot (value-receiver overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_negative

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary_val[
            Self.self_type, method, PySlotIndex.nb_negative
        ](self._ptr)
        return self

    def def_pos[
        method: def(Self.self_type) thin raises PySlotError -> PythonObject
    ](mut self) -> ref[self] Self:
        """Install `__pos__` via the `nb_positive` slot (value-receiver overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_positive

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.unary_val[
            Self.self_type, method, PySlotIndex.nb_positive
        ](self._ptr)
        return self

    # ------------------------------------------------------------------
    # Bool slot — C type: inquiry  int(*)(PyObject *)
    # ------------------------------------------------------------------

    def def_bool[
        method: def(
            UnsafePointer[Self.self_type, MutAnyOrigin]
        ) thin raises PySlotError -> Bool
    ](mut self) -> ref[self] Self:
        """Install `__bool__` via the `nb_bool` slot.

        Called by `bool(obj)`.
        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_bool

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.inquiry[Self.self_type, method, PySlotIndex.nb_bool](
            self._ptr
        )
        return self

    def def_bool[
        method: def(UnsafePointer[Self.self_type, MutAnyOrigin]) thin -> Bool
    ](mut self) -> ref[self] Self:
        """Install `__bool__` via the `nb_bool` slot (non-raising overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_bool

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.inquiry_nr[Self.self_type, method, PySlotIndex.nb_bool](
            self._ptr
        )
        return self

    def def_bool[
        method: def(Self.self_type) thin raises PySlotError -> Bool
    ](mut self) -> ref[self] Self:
        """Install `__bool__` via the `nb_bool` slot (value-receiver overload).

        See: https://docs.python.org/3/c-api/typeobj.html#c.PyNumberMethods.nb_bool

        Parameters:
            method: The user-supplied handler installed into the slot.

        Returns:
            A reference to `self` for chaining.
        """
        _SlotInstaller.inquiry_val[Self.self_type, method, PySlotIndex.nb_bool](
            self._ptr
        )
        return self

