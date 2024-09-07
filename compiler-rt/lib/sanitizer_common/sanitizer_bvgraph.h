//===-- sanitizer_bvgraph.h -------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file is a part of Sanitizer runtime.
// BVGraph -- a directed graph.
//
//===----------------------------------------------------------------------===//

#ifndef SANITIZER_BVGRAPH_H
#define SANITIZER_BVGRAPH_H

#include "sanitizer_common.h"
#include "sanitizer_bitvector.h"

namespace __sanitizer {

// Directed graph of fixed size implemented as an array of bit vectors.
// Not thread-safe, all accesses should be protected by an external lock.
template<class BV>
class BVGraph {
 public:
  enum SizeEnum : usize { kSize = BV::kSize };
  usize size() const { return kSize; }
  // No CTOR.
  void clear() {
    for (usize i = 0; i < size(); i++)
      v[i].clear();
  }

  bool empty() const {
    for (usize i = 0; i < size(); i++)
      if (!v[i].empty())
        return false;
    return true;
  }

  // Returns true if a new edge was added.
  bool addEdge(usize from, usize to) {
    check(from, to);
    return v[from].setBit(to);
  }

  // Returns true if at least one new edge was added.
  usize addEdges(const BV &from, usize to, usize added_edges[],
                usize max_added_edges) {
    usize res = 0;
    t1.copyFrom(from);
    while (!t1.empty()) {
      usize node = t1.getAndClearFirstOne();
      if (v[node].setBit(to))
        if (res < max_added_edges)
          added_edges[res++] = node;
    }
    return res;
  }

  // *EXPERIMENTAL*
  // Returns true if an edge from=>to exist.
  // This function does not use any global state except for 'this' itself,
  // and thus can be called from different threads w/o locking.
  // This would be racy.
  // FIXME: investigate how much we can prove about this race being "benign".
  bool hasEdge(usize from, usize to) { return v[from].getBit(to); }

  // Returns true if the edge from=>to was removed.
  bool removeEdge(usize from, usize to) {
    return v[from].clearBit(to);
  }

  // Returns true if at least one edge *=>to was removed.
  bool removeEdgesTo(const BV &to) {
    bool res = 0;
    for (usize from = 0; from < size(); from++) {
      if (v[from].setDifference(to))
        res = true;
    }
    return res;
  }

  // Returns true if at least one edge from=>* was removed.
  bool removeEdgesFrom(const BV &from) {
    bool res = false;
    t1.copyFrom(from);
    while (!t1.empty()) {
      usize idx = t1.getAndClearFirstOne();
      if (!v[idx].empty()) {
        v[idx].clear();
        res = true;
      }
    }
    return res;
  }

  void removeEdgesFrom(usize from) {
    return v[from].clear();
  }

  bool hasEdge(usize from, usize to) const {
    check(from, to);
    return v[from].getBit(to);
  }

  // Returns true if there is a path from the node 'from'
  // to any of the nodes in 'targets'.
  bool isReachable(usize from, const BV &targets) {
    BV &to_visit = t1,
       &visited = t2;
    to_visit.copyFrom(v[from]);
    visited.clear();
    visited.setBit(from);
    while (!to_visit.empty()) {
      usize idx = to_visit.getAndClearFirstOne();
      if (visited.setBit(idx))
        to_visit.setUnion(v[idx]);
    }
    return targets.intersectsWith(visited);
  }

  // Finds a path from 'from' to one of the nodes in 'target',
  // stores up to 'path_size' items of the path into 'path',
  // returns the path length, or 0 if there is no path of size 'path_size'.
  usize findPath(usize from, const BV &targets, usize *path, usize path_size) {
    if (path_size == 0)
      return 0;
    path[0] = from;
    if (targets.getBit(from))
      return 1;
    // The function is recursive, so we don't want to create BV on stack.
    // Instead of a getAndClearFirstOne loop we use the slower iterator.
    for (typename BV::Iterator it(v[from]); it.hasNext(); ) {
      usize idx = it.next();
      if (usize res = findPath(idx, targets, path + 1, path_size - 1))
        return res + 1;
    }
    return 0;
  }

  // Same as findPath, but finds a shortest path.
  usize findShortestPath(usize from, const BV &targets, usize *path,
                        usize path_size) {
    for (usize p = 1; p <= path_size; p++)
      if (findPath(from, targets, path, p) == p)
        return p;
    return 0;
  }

 private:
  void check(usize idx1, usize idx2) const {
    CHECK_LT(idx1, size());
    CHECK_LT(idx2, size());
  }
  BV v[kSize];
  // Keep temporary vectors here since we can not create large objects on stack.
  BV t1, t2;
};

} // namespace __sanitizer

#endif // SANITIZER_BVGRAPH_H
