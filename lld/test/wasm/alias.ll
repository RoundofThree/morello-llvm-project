; RUN: llc -mtriple=wasm32-unknown-unknown-wasm -filetype=obj -o %t.o %s
; RUN: lld -flavor wasm %t.o -o %t.wasm
; RUN: obj2yaml %t.wasm | FileCheck %s

@start_alias = alias i32 (), i32 ()* @_start

; Function Attrs: nounwind uwtable
define i32 @_start() local_unnamed_addr #1 {
entry:
  ret i32 0
}

; CHECK:      --- !WASM
; CHECK-NEXT: FileHeader:      
; CHECK-NEXT:   Version:         0x00000001
; CHECK-NEXT: Sections:        
; CHECK-NEXT:   - Type:            TYPE
; CHECK-NEXT:     Signatures:      
; CHECK-NEXT:       - Index:           0
; CHECK-NEXT:         ReturnType:      I32
; CHECK-NEXT:         ParamTypes:      
; CHECK-NEXT:      - Index:           1
; CHECK-NEXT:        ReturnType:      NORESULT
; CHECK-NEXT:        ParamTypes:
; CHECK-NEXT:   - Type:            FUNCTION
; CHECK-NEXT:     FunctionTypes:   [ 0, 1 ]
; CHECK-NEXT:   - Type:            TABLE
; CHECK-NEXT:     Tables:          
; CHECK-NEXT:       - ElemType:        ANYFUNC
; CHECK-NEXT:         Limits:          
; CHECK-NEXT:           Flags:           [ HAS_MAX ]
; CHECK-NEXT:           Initial:         0x00000001
; CHECK-NEXT:           Maximum:         0x00000001
; CHECK-NEXT:   - Type:            MEMORY
; CHECK-NEXT:     Memories:        
; CHECK-NEXT:       - Initial:         0x00000002
; CHECK-NEXT:   - Type:            GLOBAL
; CHECK-NEXT:     Globals:         
; CHECK-NEXT:       - Index:           0
; CHECK-NEXT:         Type:            I32
; CHECK-NEXT:         Mutable:         true
; CHECK-NEXT:         InitExpr:        
; CHECK-NEXT:           Opcode:          I32_CONST
; CHECK-NEXT:           Value:           66560
; CHECK-NEXT:       - Index:           1
; CHECK-NEXT:         Type:            I32
; CHECK-NEXT:         Mutable:         false
; CHECK-NEXT:         InitExpr:        
; CHECK-NEXT:           Opcode:          I32_CONST
; CHECK-NEXT:           Value:           66560
; CHECK-NEXT:   - Type:            EXPORT
; CHECK-NEXT:     Exports:         
; CHECK-NEXT:       - Name:            memory
; CHECK-NEXT:         Kind:            MEMORY
; CHECK-NEXT:         Index:           0
; CHECK-NEXT:       - Name:            _start
; CHECK-NEXT:         Kind:            FUNCTION
; CHECK-NEXT:         Index:           0
; CHECK-NEXT:       - Name:            start_alias
; CHECK-NEXT:         Kind:            FUNCTION
; CHECK-NEXT:         Index:           0
; CHECK-NEXT:       - Name:            __heap_base
; CHECK-NEXT:         Kind:            GLOBAL
; CHECK-NEXT:         Index:           1
; CHECK-NEXT:   - Type:            CODE
; CHECK-NEXT:     Functions:       
; CHECK-NEXT:       - Index:           0
; CHECK-NEXT:         Locals:          
; CHECK-NEXT:         Body:            41000B
; CHECK-NEXT:       - Index:           1
; CHECK-NEXT:         Locals:          
; CHECK-NEXT:         Body:            0B
; CHECK-NEXT:   - Type:            CUSTOM
; CHECK-NEXT:     Name:            linking
; CHECK-NEXT:     DataSize:        0
; CHECK-NEXT:   - Type:            CUSTOM
; CHECK-NEXT:     Name:            name
; CHECK-NEXT:     FunctionNames:   
; CHECK-NEXT:       - Index:           0
; CHECK-NEXT:         Name:            _start
; CHECK-NEXT:       - Index:           1
; CHECK-NEXT:         Name:            __wasm_call_ctors
; CHECK-NEXT: ...
