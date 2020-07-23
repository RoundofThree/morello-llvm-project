// RUN: mlir-opt %s -split-input-file -verify-diagnostics

func @load_number_of_indices(%v : memref<f32>) {
  // expected-error @+2 {{incorrect number of indices for load}}
  %c0 = constant 0 : index
  load %v[%c0] : memref<f32>
}

// -----

func @slice_number_of_indexings(%arg0: memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>) {
  // expected-error @+2 {{expected 2 indexings, got 1}}
  %c0 = constant 0: index
  %0 = linalg.slice %arg0[%c0] : memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>, index, memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>
}

// -----

func @slice_rank_vs_range_indices(%arg0: memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>) {
  // expected-error @+2 {{op expected rank of the view(1) to be the number of ranges(0)}}
  %c0 = constant 0: index
  %0 = linalg.slice %arg0[%c0, %c0] : memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>, index, index, memref<?xf32, affine_map<(i)[off]->(off + i)>>
}

// -----

func @store_number_of_indices(%v : memref<f32>) {
  // expected-error @+3 {{store index operand count not equal to memref rank}}
  %c0 = constant 0 : index
  %f0 = constant 0.0 : f32
  store %f0, %v[%c0] : memref<f32>
}

// -----

func @transpose_not_permutation(%v : memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>) {
  // expected-error @+1 {{expected a permutation map}}
  linalg.transpose %v (i, j) -> (i, i) : memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>
}

// -----

func @transpose_bad_rank(%v : memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>) {
  // expected-error @+1 {{expected a permutation map of same rank as the view}}
  linalg.transpose %v (i) -> (i) : memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>
}

// -----

func @yield_parent(%arg0: memref<?xf32, affine_map<(i)[off]->(off + i)>>) {
  // expected-error @+1 {{op expected parent op with LinalgOp interface}}
  linalg.yield %arg0: memref<?xf32, affine_map<(i)[off]->(off + i)>>
}

// -----

func @generic_no_region(%arg0: memref<f32>) {
  // expected-error @+6 {{expected '{' to begin a region}}
  linalg.generic {
    args_in = 1,
    args_out = 1,
    indexing_maps =  [ affine_map<() -> (0)> ],
    iterator_types = []
  } %arg0 : memref<f32>
}

// -----

func @generic_at_least_2_operands(%arg0: memref<f32>) {
  // expected-error @+1 {{op expected 2 or more operands}}
  linalg.generic {
    args_in = 1,
    args_out = 1,
    indexing_maps =  [ affine_map<() -> (0)> ],
    iterator_types = []
  } %arg0 {} : memref<f32>
}

// -----

func @generic_exactly_2_views(%arg0: memref<f32>) {
  // expected-error @+1 {{op expected exactly 2 inputs (tensor or buffer) and output buffer operands}}
  linalg.generic {
    args_in = 1,
    args_out = 1,
    indexing_maps =  [ affine_map<() -> (0)> ],
    iterator_types = []
  } %arg0, %arg0, %arg0 {}: memref<f32>, memref<f32>, memref<f32>
}

// -----

func @generic_mismatched_num_returns(%arg0: memref<f32>) {
  // expected-error @+8 {{op expected number of yield values (1) to match the number of operands of the enclosing LinalgOp (0)}}
  linalg.generic {
    args_in = 0,
    args_out = 1,
    indexing_maps =  [ affine_map<() -> ()> ],
    iterator_types = []
  } %arg0 {
    ^bb(%0: f32):
      linalg.yield
  }: memref<f32>
}

// -----

func @generic_symbol_in_map(%arg0: memref<i32>) {
  // expected-error @+1 {{expected the number of symbols in indexing_map #0 to match target rank}}
  linalg.generic {
    args_in = 0,
    args_out = 1,
    indexing_maps =  [ affine_map<()[N] -> (0)> ],
    iterator_types = ["parallel"]
  } %arg0 {
    ^bb(%i : i32):
    linalg.yield %i : i32
  }: memref<i32>
}

// -----

func @generic_symbol_source_out_of_range(%arg0: memref<i32>) {
  // expected-error @+1 {{symbol_source index out of range}}
  linalg.generic {
    args_in = 0,
    args_out = 1,
    indexing_maps =  [ affine_map<()[N] -> (0)> ],
    iterator_types = ["parallel"],
    symbol_source = 1
  } %arg0 {
    ^bb(%i : i32):
    linalg.yield %i : i32
  }: memref<i32>
}

// -----

func @generic_wrong_dim_in_map(%arg0: memref<1xi32>) {
  // expected-error @+1 {{op expected indexing_map #0 to have 1 dim(s) to match the number of loops}}
  linalg.generic {
    args_in = 0,
    args_out = 1,
    indexing_maps =  [ affine_map<() -> (0)> ],
    iterator_types = ["parallel"]
  } %arg0 {
    ^bb(%i : i32):
    linalg.yield %i : i32
  }: memref<1xi32>
}

// -----

func @generic_one_d_view(%arg0: memref<?xf32, affine_map<(i)[off]->(off + i)>>) {
  // expected-error @+1 {{op expected indexing_map #0 results to match view rank: 'memref<?xf32, affine_map<(d0)[s0] -> (d0 + s0)>>'}}
  linalg.generic {
    args_in = 0,
    args_out = 1,
    indexing_maps =  [ affine_map<() -> (0, 0)> ],
    iterator_types = []
  } %arg0 {
    ^bb(%f : f32):
      linalg.yield %f: f32
  }: memref<?xf32, affine_map<(i)[off]->(off + i)>>
}

// -----

func @generic_result_0_element_type(%arg0: memref<?xf32, affine_map<(i)[off]->(off + i)>>) {
  // expected-error @+9 {{'linalg.yield' op type of yield operand 1 ('i4') doesn't match the element type of the enclosing linalg.generic op ('f32')}}
  linalg.generic {
    args_in = 0,
    args_out = 1,
    indexing_maps =  [ affine_map<(i) -> (i)> ],
    iterator_types = ["parallel"]
  } %arg0 {
    ^bb(%0: f32):
      %1 = constant 1: i4
      linalg.yield %1: i4
  }: memref<?xf32, affine_map<(i)[off]->(off + i)>>
}

// -----

func @generic_singular_maps(%arg0: memref<?xf32, affine_map<(i)[off]->(off + i)>>, %arg1: memref<?xf32, affine_map<(i)[off]->(off + i)>>) {
  // expected-error @+1 {{op expected the concatenation of maps in indexing_map to be invertible}}
  linalg.generic {
    args_in = 1,
    args_out = 1,
    indexing_maps =  [
      affine_map<(i, j) -> (i + j)>,
      affine_map<(i, j) -> (i + j)>
    ],
    iterator_types = ["parallel","parallel"]
  } %arg0, %arg1 {
    ^bb(%0: f32, %1: f32):
      linalg.yield %1: f32
  }: memref<?xf32, affine_map<(i)[off]->(off + i)>>,
     memref<?xf32, affine_map<(i)[off]->(off + i)>>
}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////// Region tests /////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// -----

func @generic_empty_region(%arg0: memref<f32>) {
  %f0 = constant 0.0: f32
  // expected-error @+1 {{op expects region #0 to have 0 or 1 blocks}}
  linalg.generic {
    args_in = 1,
    args_out = 1,
    indexing_maps =  [ affine_map<() -> (0)> ],
    iterator_types = []
  } %arg0, %arg0 {
    ^bb1:
      linalg.yield %f0: f32
    ^bb2:
      linalg.yield %f0: f32
  }: memref<f32>, memref<f32>
}

// -----

func @generic_empty_region(%arg0: memref<f32>) {
  %f0 = constant 0.0: f32
  // expected-error @+1 {{linalg.generic' op expected region with 1 block}}
  linalg.generic {
    args_in = 1,
    args_out = 1,
    indexing_maps =  [ affine_map<() -> (0)> ],
    iterator_types = []
  } %arg0, %arg0 {
  }: memref<f32>, memref<f32>
}

// -----

func @generic_mismatched_num_arguments(%arg0: memref<f32>) {
  // expected-error @+1 {{op expected number of block arguments to match number of operands}}
  linalg.generic {
    args_in = 0,
    args_out = 1,
    indexing_maps =  [ affine_map<() -> (0)> ],
    iterator_types = []
  } %arg0 {
    ^bb(%f: f32, %g: f32):
      linalg.yield %f: f32
  }: memref<f32>
}

// -----

func @generic_block_arg_type(%arg0: memref<f32>) {
  // expected-error @+1 {{op expected block argument 1 of the same type as elemental type of output operand: 'memref<f32>'}}
  linalg.generic {
    args_in = 0,
    args_out = 1,
    indexing_maps =  [ affine_map<() -> (0)> ],
    iterator_types = []
  } %arg0 {
    ^bb(%i: i1):
    linalg.yield %i : i1
  }: memref<f32>
}

// -----

func @indexed_generic_block_arg_count(%arg0: memref<f32>) {
  // expected-error @+1 {{op expected number of block arguments to match number of operands + number of loops}}
  linalg.indexed_generic {
    args_in = 0,
    args_out = 1,
    indexing_maps =  [ affine_map<(d0) -> (d0)> ],
    iterator_types = ["parallel"]
  } %arg0 {
    ^bb(%f: f32):
      linalg.yield %f : f32
  }: memref<f32>
}

// -----

func @indexed_generic_block_induction_var_arg_type(%arg0: memref<f32>) {
  // expected-error @+1 {{op expected block argument 1 to be an index}}
  linalg.indexed_generic {
    args_in = 0,
    args_out = 1,
    indexing_maps =  [ affine_map<(d0) -> (d0)> ],
    iterator_types = ["parallel"]
  } %arg0 {
    ^bb(%i: f64, %f: f32):
    linalg.yield %f: f32
  }: memref<f32>
}

// -----

func @indexed_generic_block_arg_type(%arg0: memref<f32>) {
  // expected-error @+1 {{op expected block argument 2 of the same type as elemental type of output operand: 'memref<f32>'}}
  linalg.indexed_generic {
    args_in = 0,
    args_out = 1,
    indexing_maps =  [ affine_map<(d0) -> (d0)> ],
    iterator_types = ["parallel"]
  } %arg0 {
    ^bb(%i: index, %f: i1):
    linalg.yield %i: index
  }: memref<f32>
}

// -----

func @indexed_generic_arg_count(%arg0: memref<f32>) {
  // expected-error @+1 {{op expected number of block arguments to match number of operands + number of loops}}
  linalg.indexed_generic {
    args_in = 0,
    args_out = 1,
    indexing_maps =  [ affine_map<()[] -> ()> ],
    iterator_types = []
  } %arg0 {
    ^bb(%0: index, %1: f32):
      linalg.yield %1: f32
  } :  memref<f32>
  return
}

// -----

func @indexed_generic_induction_var_arg_type(%arg0: memref<f32>) {
  // expected-error @+1 {{op expected block argument 1 to be an index}}
  linalg.indexed_generic {
    args_in = 0,
    args_out = 1,
    iterator_types = ["parallel"],
    indexing_maps = [ affine_map<(i) -> (i)> ]
  } %arg0 {
    ^bb(%0: i32, %1: f32):
      linalg.yield %1: f32
  } : memref<f32>
}

// -----

func @indexed_generic_result_count(%arg0: memref<?xf32>) {
  // expected-error @+8 {{op expected number of yield values (1) to match the number of operands of the enclosing LinalgOp (2)}}
  linalg.indexed_generic {
    args_in = 0,
    args_out = 1,
    indexing_maps =  [ affine_map<(d0) -> (d0)> ],
    iterator_types = ["parallel"]
  } %arg0 {
    ^bb(%i: index, %val: f32):
      linalg.yield %val, %val: f32, f32
  }: memref<?xf32>
}

// -----

func @generic_result_0_element_type(%arg0: memref<?xf32, affine_map<(i)[off]->(off + i)>>) {
  // expected-error @+9 {{type of yield operand 1 ('i1') doesn't match the element type of the enclosing linalg.generic op ('f32')}}
  linalg.generic {
    args_in = 0,
    args_out = 1,
    indexing_maps = [ affine_map<(i) -> (i)> ],
    iterator_types = ["parallel"]
  } %arg0 {
    ^bb(%i: f32):
      %0 = constant 0: i1
      linalg.yield %0: i1
  }: memref<?xf32, affine_map<(i)[off]->(off + i)>>
}

// -----

func @generic_result_tensor_type(%arg0: memref<?xf32, affine_map<(i)[off]->(off + i)>>) {
  // expected-error @+1 {{op result #0 must be ranked tensor of any type values, but got 'f32'}}
  %0 = linalg.generic {
    args_in = 0,
    args_out = 1,
    indexing_maps = [ affine_map<(i) -> (i)> ],
    iterator_types = ["parallel"]
  } %arg0 {
    ^bb(%i: f32):
      linalg.yield %i: f32
  }: memref<?xf32, affine_map<(i)[off]->(off + i)>> -> f32
}

// -----

func @generic_result_tensor_type(%arg0: memref<?xf32, affine_map<(i)[off]->(off + i)>>) {
  // expected-error @+1 {{op result #0 must be ranked tensor of any type values, but got 'f32'}}
  %0 = linalg.generic {
    args_in = 0,
    args_out = 1,
    indexing_maps = [ affine_map<(i) -> (i)> ],
    iterator_types = ["parallel"]
  } %arg0 {
    ^bb(%i: f32):
      linalg.yield %i: f32
  }: memref<?xf32, affine_map<(i)[off]->(off + i)>> -> f32
}

// -----

func @generic(%arg0: memref<?x?xi4>) {
  // expected-error @+2 {{op expects regions to end with 'linalg.yield', found 'std.addf'}}
  // expected-note @+1 {{in custom textual format, the absence of terminator implies 'linalg.yield'}}
  linalg.generic  {
    args_in = 0,
    args_out = 1,
    indexing_maps = [ affine_map<(i) -> (i)> ],
    iterator_types = ["parallel"]
  } %arg0 {
    ^bb(%0: i4) :
      %1 = std.addf %0, %0: i4
  } : memref<?x?xi4>
  return
}

// -----

func @generic_result_0_element_type(%arg0: memref<?xf32>) {
  // expected-error @+1 {{'linalg.dot' op expected 3 operands, but found 2}}
  linalg.dot(%arg0, %arg0): memref<?xf32>, memref<?xf32>
}

// -----

func @conv_rank_limit(%arg0: memref<?xf32>, %arg1: memref<?xf32>, %arg2: memref<?xf32>) {
  // expected-error @+1 {{expects memref ranks to be greater than 2}}
  linalg.conv(%arg0, %arg1, %arg2) : memref<?xf32>, memref<?xf32>, memref<?xf32>
}

// -----

// expected-error @+1 {{unknown Linalg type}}
!invalid_type = type !linalg.unknown

// -----

// expected-error @+1 {{expected valid keyword}}
!invalid_type = type !linalg<"?">

// -----

func @reshape(%arg0: memref<f32>) {
  // expected-error @+1 {{expected non-zero memref ranks}}
  %0 = linalg.reshape %arg0 [affine_map<()->(0)>] : memref<f32> into memref<f32>
}

// -----

func @reshape(%arg0: memref<?xf32>) {
  // expected-error @+1 {{expected to collapse or expand dims}}
  %0 = linalg.reshape %arg0 [affine_map<(i)->(i)>] : memref<?xf32> into memref<?xf32>
}

// -----

func @reshape(%arg0: memref<?x?x?xf32>) {
  // expected-error @+1 {{expected rank of the collapsed type(2) to be the number of reassociation maps(1)}}
  %0 = linalg.reshape %arg0 [affine_map<(i, j, k) -> (i, j)>] :
    memref<?x?x?xf32> into memref<?x?xf32, offset: 0, strides: [?, 1]>
}

// -----

func @reshape(%arg0: memref<?x?x?xf32>) {
  // expected-error @+1 {{expected reassociation map #0 of same rank as expanded memref(3), but got 1}}
  %0 = linalg.reshape %arg0 [affine_map<(i) -> (i)>, affine_map<(i, j, k) -> (k)>] :
    memref<?x?x?xf32> into memref<?x?xf32, offset: 0, strides: [?, 1]>
}

// -----

func @reshape(%arg0: memref<?x?x?xf32>) {
  // expected-error @+1 {{expected reassociation map #1 to be valid and contiguous}}
  %0 = linalg.reshape %arg0 [affine_map<(i, j, k) -> (i, j)>, affine_map<(i, j, k) -> (k, j)>] :
    memref<?x?x?xf32> into memref<?x?xf32, offset: 0, strides: [?, 1]>
}

// -----

func @reshape(%arg0: memref<?x?x?xf32>) {
  // expected-error @+1 {{expected collapsed type to be 'memref<?x?xf32>', but got 'memref<?x?xf32, affine_map<(d0, d1)[s0] -> (d0 * s0 + d1)>>'}}
  %0 = linalg.reshape %arg0 [affine_map<(i, j, k) -> (i, j)>, affine_map<(i, j, k) -> (k)>] :
    memref<?x?x?xf32> into memref<?x?xf32, affine_map<(d0, d1)[s0] -> (d0 * s0 + d1)>>
}

// -----

func @pooling_rank_mismatch(%arg0: memref<?x?x?xf32>,
                            %arg1: memref<2x3xf32>,
                            %arg2: memref<?x?x?xf32>) {
  // expected-error @+1 {{expects memref ranks to match}}
  linalg.pooling_max(%arg0, %arg1, %arg2) {strides = [2, 1, 2]}:
    memref<?x?x?xf32>, memref<2x3xf32>, memref<?x?x?xf32>
  return
}

// -----

func @named_ops(%a3: memref<?x?x?xf32>, %b3: memref<?x?xf32>, %c3: memref<?x?x?xf32>) {
  // expected-error @+1 {{op expected indexing_map #1 results to match view rank: 'memref<?x?xf32>'}}
  linalg.batch_matmul %a3, %b3, %c3 : (memref<?x?x?xf32>, memref<?x?xf32>, memref<?x?x?xf32>) -> ()
  return
}
