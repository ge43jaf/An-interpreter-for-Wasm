(module
  (import "console" "log" (func $log (param i32)))

  ;; Imperative function 1: Sum first N natural numbers using loop
  (func $sum_n (param $n i32) (result i32)
    (local $i i32)
    (local $sum i32)
    i32.const 0
    local.set $i
    i32.const 0
    local.set $sum

    block $break
    loop $loop
      local.get $i
      local.get $n
      i32.ge_u
      br_if $break

      local.get $sum
      local.get $i
      i32.add
      local.set $sum

      local.get $i
      i32.const 1
      i32.add
      local.set $i

      br $loop
    end
  end

    local.get $sum
  )

  ;; Imperative function 2: Find max of two numbers
  (func $max (param $a i32) (param $b i32) (result i32)
    local.get $a
    local.get $b
    i32.gt_s
    if (result i32)
      local.get $a
    else
      local.get $b
    end
  )

  ;; Functional function 1: Identity function
  (func $identity (param $x i32) (result i32)
    local.get $x
  )

  ;; Functional function 2: Increment
  (func $increment (param $x i32) (result i32)
    local.get $x
    i32.const 1
    i32.add
  )

  ;; Combined sort function: imperative (loop) + functional (compare function)
  (memory $mem 1)
  (export "memory" (memory $mem))

  ;; Swap two values in memory
  (func $swap (param $a i32) (param $b i32)
    (local $tmp1 i32)
    (local $tmp2 i32)
    local.get $a
    i32.load
    local.set $tmp1

    local.get $b
    i32.load
    local.set $tmp2

    local.get $a
    local.get $tmp2
    i32.store

    local.get $b
    local.get $tmp1
    i32.store
  )

  ;; Compare two values (functional part)
  (func $greater_than (param $a i32) (param $b i32) (result i32)
    local.get $a
    local.get $b
    i32.gt_s
  )

  ;; Imperative sorting function (Bubble Sort) that takes array length as parameter
  (func $sort_array_imperative(export "sort_array_imperative") (param $len i32)
    (local $i i32)
    (local $j i32)
    (local $addr1 i32)
    (local $addr2 i32)
    (local $cmp i32)

    i32.const 0
    local.set $i
    block $outer_break
    loop $outer
      local.get $i
      local.get $len
      i32.const 1
      i32.sub
      i32.ge_u
      br_if $outer_break

      i32.const 0
      local.set $j
      block $inner_break
      loop $inner
        local.get $j
        local.get $len
        i32.const 1
        i32.sub
        i32.ge_u
        br_if $inner_break

        ;; compute addresses
        local.get $j
        i32.const 4
        i32.mul
        local.set $addr1

        local.get $j
        i32.const 1
        i32.add
        i32.const 4
        i32.mul
        local.set $addr2

        ;; load elements
        local.get $addr1
        i32.load

        local.get $addr2
        i32.load

        call $greater_than
        local.set $cmp

        local.get $cmp
        if
          local.get $addr1
          local.get $addr2
          call $swap
        end

        local.get $j
        i32.const 1
        i32.add
        local.set $j
        br $inner
      end
      end ;; end inner loop

      local.get $i
      i32.const 1
      i32.add
      local.set $i
      br $outer
    end
    end ;; end outer loop
  )

  
  ;; Functional sorting function (using recursion)
(func $sort_array_functional (export "sort_array_functional") (param $len i32)
  ;; Start the sorting process
  (if
    (i32.gt_u (local.get $len) (i32.const 1))
    (then
      (call $sort_outer (local.get $len) (i32.const 0) (i32.const 1))
    )
  )
)

;; Helper function for recursive sorting - one bubble pass
(func $bubble_pass (param $len i32) (param $j i32) (param $swapped i32) (result i32)
  (local $addr1 i32)
  (local $addr2 i32)
  (local $val1 i32)
  (local $val2 i32)
  
  ;; Base case: end of pass
  (if (result i32)
    (i32.ge_u (local.get $j) (i32.sub (local.get $len) (i32.const 1)))
    (then
      (local.get $swapped)  ;; return whether any swaps occurred
    )
    (else
      ;; compute addresses
      (local.set $addr1 (i32.mul (local.get $j) (i32.const 4)))
      (local.set $addr2 (i32.mul (i32.add (local.get $j) (i32.const 1)) (i32.const 4)))
      
      ;; load elements
      (local.set $val1 (i32.load (local.get $addr1)))
      (local.set $val2 (i32.load (local.get $addr2)))
      
      ;; compare and swap if needed
      (if (result i32)
        (call $greater_than (local.get $val1) (local.get $val2))
        (then
          (call $swap (local.get $addr1) (local.get $addr2))
          ;; recurse with swapped flag set
          (call $bubble_pass 
            (local.get $len)
            (i32.add (local.get $j) (i32.const 1))
            (i32.const 1))
        )
        (else
          ;; recurse without swapping
          (call $bubble_pass 
            (local.get $len)
            (i32.add (local.get $j) (i32.const 1))
            (local.get $swapped))
        )
      )
    )
  )
)

;; Outer loop replacement - recursive function
(func $sort_outer (param $len i32) (param $i i32) (param $swapped i32)
  (local $new_swapped i32)
  
  ;; Base case: if no swaps occurred or we've done enough passes
  (if
    (i32.or
      (i32.eqz (local.get $swapped))
      (i32.ge_u (local.get $i) (i32.sub (local.get $len) (i32.const 1)))
    )
    (then)  ;; done sorting
    (else
      ;; Do a bubble pass and recurse
      (local.set $new_swapped 
        (call $bubble_pass 
          (local.get $len)
          (i32.const 0)
          (i32.const 0)))
      
      (call $sort_outer 
        (local.get $len)
        (i32.add (local.get $i) (i32.const 1))
        (local.get $new_swapped))
    )
  )
)
  
  
  
  ;; Call all the functions (optional entry)
  (func $init
    ;; fill memory[0..3] with values 23, 5, 17, 8
    i32.const 0
    i32.const 23
    i32.store
    i32.const 4
    i32.const 5
    i32.store
    i32.const 8
    i32.const 17
    i32.store
    i32.const 12
    i32.const 8
    i32.store

    ;; sort 4 elements
    i32.const 4
    call $sort_array_imperative

    ;; log sorted values
    i32.const 0
    i32.load
    call $log
    i32.const 4
    i32.load
    call $log
    i32.const 8
    i32.load
    call $log
    i32.const 12
    i32.load
    call $log

    
    
    ;; fill memory[0..3] with values 23, 5, 17, 8
    i32.const 0
    i32.const 23
    i32.store
    i32.const 4
    i32.const 5
    i32.store
    i32.const 8
    i32.const 17
    i32.store
    i32.const 12
    i32.const 8
    i32.store

    ;; sort 4 elements
    i32.const 4
    call $sort_array_functional

    ;; log sorted values
    i32.const 0
    i32.load
    call $log
    i32.const 4
    i32.load
    call $log
    i32.const 8
    i32.load
    call $log
    i32.const 12
    i32.load
    call $log
    
    
    ;; run other tests
    i32.const 5
    call $sum_n
    call $log

    i32.const 9
    i32.const 7
    call $max
    call $log

    i32.const 123
    call $identity
    call $log

    i32.const 41
    call $increment
    call $log
  )

  (start $init)
  (export "init" (func $init))
  (export "sum_n" (func $sum_n))
  (export "max" (func $max))
  (export "identity" (func $identity))
  (export "increment" (func $increment))
  (export "swap" (func $swap))
  (export "greater_than" (func $greater_than))
)
