// -*- C++ -*-
//===-- numeric_impl.h ----------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef __PSTL_numeric_impl_H
#define __PSTL_numeric_impl_H

#include <iterator>
#include <type_traits>
#include <numeric>

#include "pstl_config.h"
#include "execution_impl.h"
#include "unseq_backend_simd.h"

#if __PSTL_USE_PAR_POLICIES
#include "parallel_backend.h"
#endif

namespace __pstl
{
namespace internal
{

//------------------------------------------------------------------------
// transform_reduce (version with two binary functions, according to draft N4659)
//------------------------------------------------------------------------

template <class _ForwardIterator1, class _ForwardIterator2, class _Tp, class _BinaryOperation1, class _BinaryOperation2>
_Tp
brick_transform_reduce(_ForwardIterator1 __first1, _ForwardIterator1 __last1, _ForwardIterator2 __first2, _Tp __init,
                       _BinaryOperation1 __binary_op1, _BinaryOperation2 __binary_op2,
                       /*is_vector=*/std::false_type) noexcept
{
    return std::inner_product(__first1, __last1, __first2, __init, __binary_op1, __binary_op2);
}

template <class _ForwardIterator1, class _ForwardIterator2, class _Tp, class _BinaryOperation1, class _BinaryOperation2>
_Tp
brick_transform_reduce(_ForwardIterator1 __first1, _ForwardIterator1 __last1, _ForwardIterator2 __first2, _Tp __init,
                       _BinaryOperation1 __binary_op1, _BinaryOperation2 __binary_op2,
                       /*is_vector=*/std::true_type) noexcept
{
    typedef typename std::iterator_traits<_ForwardIterator1>::difference_type _DifferenceType;
    return unseq_backend::simd_transform_reduce(
        __last1 - __first1, __init, __binary_op1,
        [=, &__binary_op2](_DifferenceType __i) { return __binary_op2(__first1[__i], __first2[__i]); });
}

template <class _ExecutionPolicy, class _ForwardIterator1, class _ForwardIterator2, class _Tp, class _BinaryOperation1,
          class _BinaryOperation2, class _IsVector>
_Tp
pattern_transform_reduce(_ExecutionPolicy&&, _ForwardIterator1 __first1, _ForwardIterator1 __last1,
                         _ForwardIterator2 __first2, _Tp __init, _BinaryOperation1 __binary_op1,
                         _BinaryOperation2 __binary_op2, _IsVector __is_vector,
                         /*is_parallel=*/std::false_type) noexcept
{
    return brick_transform_reduce(__first1, __last1, __first2, __init, __binary_op1, __binary_op2, __is_vector);
}

#if __PSTL_USE_PAR_POLICIES
template <class _ExecutionPolicy, class _RandomAccessIterator1, class _RandomAccessIterator2, class _Tp,
          class _BinaryOperation1, class _BinaryOperation2, class _IsVector>
_Tp
pattern_transform_reduce(_ExecutionPolicy&& __exec, _RandomAccessIterator1 __first1, _RandomAccessIterator1 __last1,
                         _RandomAccessIterator2 __first2, _Tp __init, _BinaryOperation1 __binary_op1,
                         _BinaryOperation2 __binary_op2, _IsVector __is_vector, /*is_parallel=*/std::true_type)
{
    return internal::except_handler([&]() {
        return par_backend::parallel_transform_reduce(
            std::forward<_ExecutionPolicy>(__exec), __first1, __last1,
            [__first1, __first2, __binary_op2](_RandomAccessIterator1 __i) mutable {
                return __binary_op2(*__i, *(__first2 + (__i - __first1)));
            },
            __init,
            __binary_op1, // Combine
            [__first1, __first2, __binary_op1, __binary_op2,
             __is_vector](_RandomAccessIterator1 __i, _RandomAccessIterator1 __j, _Tp __init) -> _Tp {
                return internal::brick_transform_reduce(__i, __j, __first2 + (__i - __first1), __init, __binary_op1,
                                                        __binary_op2, __is_vector);
            });
    });
}
#endif

//------------------------------------------------------------------------
// transform_reduce (version with unary and binary functions)
//------------------------------------------------------------------------

template <class _ForwardIterator, class _Tp, class _BinaryOperation, class _UnaryOperation>
_Tp
brick_transform_reduce(_ForwardIterator __first, _ForwardIterator __last, _Tp __init, _BinaryOperation __binary_op,
                       _UnaryOperation __unary_op, /*is_vector=*/std::false_type) noexcept
{
    for (; __first != __last; ++__first)
    {
        __init = __binary_op(__init, __unary_op(*__first));
    }
    return __init;
}

template <class _ForwardIterator, class _Tp, class _UnaryOperation, class _BinaryOperation>
_Tp
brick_transform_reduce(_ForwardIterator __first, _ForwardIterator __last, _Tp __init, _BinaryOperation __binary_op,
                       _UnaryOperation __unary_op, /*is_vector=*/std::true_type) noexcept
{
    typedef typename std::iterator_traits<_ForwardIterator>::difference_type _DifferenceType;
    return unseq_backend::simd_transform_reduce(
        __last - __first, __init, __binary_op,
        [=, &__unary_op](_DifferenceType __i) { return __unary_op(__first[__i]); });
}

template <class _ExecutionPolicy, class _ForwardIterator, class _Tp, class _BinaryOperation, class _UnaryOperation,
          class _IsVector>
_Tp
pattern_transform_reduce(_ExecutionPolicy&&, _ForwardIterator __first, _ForwardIterator __last, _Tp __init,
                         _BinaryOperation __binary_op, _UnaryOperation __unary_op, _IsVector __is_vector,
                         /*is_parallel=*/std::false_type) noexcept
{
    return brick_transform_reduce(__first, __last, __init, __binary_op, __unary_op, __is_vector);
}

#if __PSTL_USE_PAR_POLICIES
template <class _ExecutionPolicy, class _ForwardIterator, class _Tp, class _BinaryOperation, class _UnaryOperation,
          class _IsVector>
_Tp
pattern_transform_reduce(_ExecutionPolicy&& __exec, _ForwardIterator __first, _ForwardIterator __last, _Tp __init,
                         _BinaryOperation __binary_op, _UnaryOperation __unary_op, _IsVector __is_vector,
                         /*is_parallel=*/std::true_type)
{
    return except_handler([&]() {
        return par_backend::parallel_transform_reduce(
            std::forward<_ExecutionPolicy>(__exec), __first, __last,
            [__unary_op](_ForwardIterator __i) mutable { return __unary_op(*__i); }, __init, __binary_op,
            [__unary_op, __binary_op, __is_vector](_ForwardIterator __i, _ForwardIterator __j, _Tp __init) {
                return brick_transform_reduce(__i, __j, __init, __binary_op, __unary_op, __is_vector);
            });
    });
}
#endif

//------------------------------------------------------------------------
// transform_exclusive_scan
//
// walk3 evaluates f(x,y,z) for (x,y,z) drawn from [first1,last1), [first2,...), [first3,...)
//------------------------------------------------------------------------

// Exclusive form
template <class _ForwardIterator, class _OutputIterator, class _UnaryOperation, class _Tp, class _BinaryOperation>
std::pair<_OutputIterator, _Tp>
brick_transform_scan(_ForwardIterator __first, _ForwardIterator __last, _OutputIterator __result,
                     _UnaryOperation __unary_op, _Tp __init, _BinaryOperation __binary_op,
                     /*Inclusive*/ std::false_type, /*is_vector=*/std::false_type) noexcept
{
    for (; __first != __last; ++__first, ++__result)
    {
        *__result = __init;
        __PSTL_PRAGMA_FORCEINLINE
        __init = __binary_op(__init, __unary_op(*__first));
    }
    return std::make_pair(__result, __init);
}

// Inclusive form
template <class _ForwardIterator, class _OutputIterator, class _UnaryOperation, class _Tp, class _BinaryOperation>
std::pair<_OutputIterator, _Tp>
brick_transform_scan(_ForwardIterator __first, _ForwardIterator __last, _OutputIterator __result,
                     _UnaryOperation __unary_op, _Tp __init, _BinaryOperation __binary_op,
                     /*Inclusive*/ std::true_type, /*is_vector=*/std::false_type) noexcept
{
    for (; __first != __last; ++__first, ++__result)
    {
        __PSTL_PRAGMA_FORCEINLINE
        __init = __binary_op(__init, __unary_op(*__first));
        *__result = __init;
    }
    return std::make_pair(__result, __init);
}

// type is arithmetic and binary operation is a user defined operation.
template <typename _Tp, typename _BinaryOperation>
using is_arithmetic_udop = std::integral_constant<bool, std::is_arithmetic<_Tp>::value &&
                                                            !std::is_same<_BinaryOperation, std::plus<_Tp>>::value>;

// [restriction] - T shall be DefaultConstructible.
// [violation] - default ctor of T shall set the identity value for binary_op.
template <class _ForwardIterator, class _OutputIterator, class _UnaryOperation, class _Tp, class _BinaryOperation,
          class _Inclusive>
typename std::enable_if<!is_arithmetic_udop<_Tp, _BinaryOperation>::value, std::pair<_OutputIterator, _Tp>>::type
brick_transform_scan(_ForwardIterator __first, _ForwardIterator __last, _OutputIterator __result,
                     _UnaryOperation __unary_op, _Tp __init, _BinaryOperation __binary_op, _Inclusive,
                     /*is_vector=*/std::true_type) noexcept
{
#if (__PSTL_UDS_PRESENT)
    return unseq_backend::simd_scan(__first, __last - __first, __result, __unary_op, __init, __binary_op, _Inclusive());
#else
    // We need to call serial brick here to call function for inclusive and exclusive scan that depends on _Inclusive() value
    return brick_transform_scan(__first, __last, __result, __unary_op, __init, __binary_op, _Inclusive(),
                                /*is_vector=*/std::false_type());
#endif
}

template <class _ForwardIterator, class _OutputIterator, class _UnaryOperation, class _Tp, class _BinaryOperation,
          class _Inclusive>
typename std::enable_if<is_arithmetic_udop<_Tp, _BinaryOperation>::value, std::pair<_OutputIterator, _Tp>>::type
brick_transform_scan(_ForwardIterator __first, _ForwardIterator __last, _OutputIterator __result,
                     _UnaryOperation __unary_op, _Tp __init, _BinaryOperation __binary_op, _Inclusive,
                     /*is_vector=*/std::true_type) noexcept
{
    return brick_transform_scan(__first, __last, __result, __unary_op, __init, __binary_op, _Inclusive(),
                                /*is_vector=*/std::false_type());
}

template <class _ExecutionPolicy, class _ForwardIterator, class _OutputIterator, class _UnaryOperation, class _Tp,
          class _BinaryOperation, class _Inclusive, class _IsVector>
_OutputIterator
pattern_transform_scan(_ExecutionPolicy&&, _ForwardIterator __first, _ForwardIterator __last, _OutputIterator __result,
                       _UnaryOperation __unary_op, _Tp __init, _BinaryOperation __binary_op, _Inclusive,
                       _IsVector __is_vector, /*is_parallel=*/std::false_type) noexcept
{
    return internal::brick_transform_scan(__first, __last, __result, __unary_op, __init, __binary_op, _Inclusive(),
                                          __is_vector)
        .first;
}

#if __PSTL_USE_PAR_POLICIES
template <class _ExecutionPolicy, class _RandomAccessIterator, class _OutputIterator, class _UnaryOperation, class _Tp,
          class _BinaryOperation, class _Inclusive, class _IsVector>
typename std::enable_if<!std::is_floating_point<_Tp>::value, _OutputIterator>::type
pattern_transform_scan(_ExecutionPolicy&& __exec, _RandomAccessIterator __first, _RandomAccessIterator __last,
                       _OutputIterator __result, _UnaryOperation __unary_op, _Tp __init, _BinaryOperation __binary_op,
                       _Inclusive, _IsVector __is_vector, /*is_parallel=*/std::true_type)
{
    typedef typename std::iterator_traits<_RandomAccessIterator>::difference_type _DifferenceType;

    return internal::except_handler([&]() {
        par_backend::parallel_transform_scan(
            std::forward<_ExecutionPolicy>(__exec), __last - __first,
            [__first, __unary_op](_DifferenceType __i) mutable { return __unary_op(__first[__i]); }, __init,
            __binary_op,
            [__first, __unary_op, __binary_op, __is_vector](_DifferenceType __i, _DifferenceType __j, _Tp __init) {
                // Execute serial brick_transform_reduce, due to the explicit SIMD vectorization (reduction) requires a commutative operation for the guarantee of correct scan.
                return internal::brick_transform_reduce(__first + __i, __first + __j, __init, __binary_op, __unary_op,
                                                        /*__is_vector*/ std::false_type());
            },
            [__first, __unary_op, __binary_op, __result, __is_vector](_DifferenceType __i, _DifferenceType __j,
                                                                      _Tp __init) {
                return internal::brick_transform_scan(__first + __i, __first + __j, __result + __i, __unary_op, __init,
                                                      __binary_op, _Inclusive(), __is_vector)
                    .second;
            });
        return __result + (__last - __first);
    });
}
#endif

#if __PSTL_USE_PAR_POLICIES
template <class _ExecutionPolicy, class _RandomAccessIterator, class _OutputIterator, class _UnaryOperation, class _Tp,
          class _BinaryOperation, class _Inclusive, class _IsVector>
typename std::enable_if<std::is_floating_point<_Tp>::value, _OutputIterator>::type
pattern_transform_scan(_ExecutionPolicy&& __exec, _RandomAccessIterator __first, _RandomAccessIterator __last,
                       _OutputIterator __result, _UnaryOperation __unary_op, _Tp __init, _BinaryOperation __binary_op,
                       _Inclusive, _IsVector __is_vector, /*is_parallel=*/std::true_type)
{
    typedef typename std::iterator_traits<_RandomAccessIterator>::difference_type _DifferenceType;
    _DifferenceType __n = __last - __first;

    if (__n <= 0)
    {
        return __result;
    }
    return except_handler([&]() {
        par_backend::parallel_strict_scan(
            std::forward<_ExecutionPolicy>(__exec), __n, __init,
            [__first, __unary_op, __binary_op, __result, __is_vector](_DifferenceType __i, _DifferenceType __len) {
                return brick_transform_scan(__first + __i, __first + (__i + __len), __result + __i, __unary_op, _Tp{},
                                            __binary_op, _Inclusive(), __is_vector)
                    .second;
            },
            __binary_op,
            [__result, &__binary_op](_DifferenceType __i, _DifferenceType __len, _Tp __initial) {
                return *(std::transform(__result + __i, __result + __i + __len, __result + __i,
                                        [&__initial, &__binary_op](const _Tp& __x) {
                                            __PSTL_PRAGMA_FORCEINLINE
                                            return __binary_op(__initial, __x);
                                        }) -
                         1);
            },
            [](_Tp __res) {});
        return __result + (__last - __first);
    });
}
#endif

//------------------------------------------------------------------------
// adjacent_difference
//------------------------------------------------------------------------

template <class _ForwardIterator, class _OutputIterator, class _BinaryOperation>
_OutputIterator
brick_adjacent_difference(_ForwardIterator __first, _ForwardIterator __last, _OutputIterator __d_first,
                          _BinaryOperation __op, /*is_vector*/ std::false_type) noexcept
{
    return std::adjacent_difference(__first, __last, __d_first, __op);
}

template <class _ForwardIterator1, class _ForwardIterator2, class BinaryOperation>
_ForwardIterator2
brick_adjacent_difference(_ForwardIterator1 __first, _ForwardIterator1 __last, _ForwardIterator2 __d_first,
                          BinaryOperation __op, /*is_vector=*/std::true_type) noexcept
{
    assert(__first != __last);

    typedef typename std::iterator_traits<_ForwardIterator1>::reference _ReferenceType1;
    typedef typename std::iterator_traits<_ForwardIterator2>::reference _ReferenceType2;

    auto __n = __last - __first;
    *__d_first = *__first;
    return unseq_backend::simd_walk_3(
        __first + 1, __n - 1, __first, __d_first + 1,
        [&__op](_ReferenceType1 __x, _ReferenceType1 __y, _ReferenceType2 __z) { __z = __op(__x, __y); });
}

template <class _ExecutionPolicy, class _ForwardIterator, class _OutputIterator, class _BinaryOperation,
          class _IsVector>
_OutputIterator
pattern_adjacent_difference(_ExecutionPolicy&&, _ForwardIterator __first, _ForwardIterator __last,
                            _OutputIterator __d_first, _BinaryOperation __op, _IsVector __is_vector,
                            /*is_parallel*/ std::false_type) noexcept
{
    return internal::brick_adjacent_difference(__first, __last, __d_first, __op, __is_vector);
}

#if __PSTL_USE_PAR_POLICIES
template <class _ExecutionPolicy, class _ForwardIterator1, class _ForwardIterator2, class _BinaryOperation,
          class _IsVector>
_ForwardIterator2
pattern_adjacent_difference(_ExecutionPolicy&& __exec, _ForwardIterator1 __first, _ForwardIterator1 __last,
                            _ForwardIterator2 __d_first, _BinaryOperation __op, _IsVector __is_vector,
                            /*is_parallel=*/std::true_type)
{
    assert(__first != __last);
    typedef typename std::iterator_traits<_ForwardIterator1>::reference _ReferenceType1;
    typedef typename std::iterator_traits<_ForwardIterator2>::reference _ReferenceType2;

    *__d_first = *__first;
    par_backend::parallel_for(std::forward<_ExecutionPolicy>(__exec), __first, __last - 1,
                              [&__op, __is_vector, __d_first, __first](_ForwardIterator1 __b, _ForwardIterator1 __e) {
                                  _ForwardIterator2 __d_b = __d_first + (__b - __first);
                                  brick_walk3(__b, __e, __b + 1, __d_b + 1,
                                              [&__op](_ReferenceType1 __x, _ReferenceType1 __y, _ReferenceType2 __z) {
                                                  __z = __op(__y, __x);
                                              },
                                              __is_vector);
                              });
    return __d_first + (__last - __first);
}
#endif

} // namespace internal
} // namespace __pstl

#endif /* __PSTL_numeric_impl_H */
