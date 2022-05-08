;;; Copyright (c) 2022 Mark Jenkins <mark@markjenkins.ca>
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a copy
;;; of this software and associated documentation files (the "Software"), to
;;; deal in the Software without restriction, including without limitation the
;;; rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
;;; sell copies of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in
;;; all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
;;; IN THE SOFTWARE.

;;; this file requires
;;;  - srfi1.scm
;;;  - readstdin.scm
;;;  - span_w_pair_state.scm
;;;  - charhandling.scm

(define OPCODE_SIZES
  '( ("OP_CONSTANT" . 2)
     ("OP_NIL" . 1)
     ("OP_TRUE" . 1)
     ("OP_FALSE" . 1)
     ("OP_POP" . 1)
     ("OP_GET_LOCAL" . 2)
     ("OP_SET_LOCAL" . 2)
     ("OP_GET_GLOBAL" . 2)
     ("OP_DEFINE_GLOBAL" . 2)
     ("OP_EQUAL" . 1)
     ("OP_GREATER" . 1)
     ("OP_LESS" . 1)
     ("OP_ADD" . 1)
     ("OP_SUBTRACT" . 1)
     ("OP_MULTIPLY" . 1)
     ("OP_DIVIDE" . 1)
     ("OP_NOT" . 1)
     ("OP_NEGATE" . 1)
     ("OP_PRINT" . 1)
     ("OP_JUMP" . 3)
     ("OP_JUMP_IF_FALSE" . 3)
     ("OP_LOOP" . 3)
     ("OP_RETURN" . 1)
     ))

(define (lookup_opcode_size opcode)
  (assoc-ref OPCODE_SIZES opcode))

(define (adjust_bytecode_offset bytecode_offset line)
  (let* ( (line_split (whitespace_split (string->list line)))
	  (opcode_lookup (lookup_opcode_size (car line_split))) )
    (if opcode_lookup
	(+ bytecode_offset opcode_lookup)
	(error "unknown opcode encounted" line_split
	       (car line_split) opcode_lookup) ) ) )

(define (find_jump_labels lines)
  (let loop ( (bytecode_offset 0)
	      (remain_lines lines)
	      (labels '()) )
    (cond ( (null? remain_lines)
	    labels ) ; base case
	  ( (endswithchar (car remain_lines) #\: )		       
	    (loop bytecode_offset
		  (cdr remain_lines)
		  (cons (cons (drop_trailing_char (car remain_lines))
			      bytecode_offset)
			labels ) ))
	  ( else
	    (loop (adjust_bytecode_offset bytecode_offset (car remain_lines))
		  (cdr remain_lines)
		  labels) ))))

(define (resolve_jump_symbol_operand operand labels)
  (let* ( (operand_chars (string->list operand))
	  (first_char (first operand_chars)) )
    (if (not (eqv? first_char #\@))
	(error "@ expected in jump label")
	(assoc-ref labels (list->string (cdr operand_chars)) ))))

(define (resolve_labels_in_line_parts
	 current_line opcode line_split labels bytecode_offset opcode_size)
  (cond ( (or (equal? opcode "OP_JUMP")
	      (equal? opcode "OP_JUMP_IF_FALSE"))
	  (let* ((dest_offset
		  (resolve_jump_symbol_operand (second line_split) labels))
		 ;; in calculating the relative offset for the jump
		 ;; subtract 3 to account for the size of the
		 ;; OP_JUMP instruction
		 (rel_offset (- dest_offset bytecode_offset 3)) )
	    (if (> rel_offset 0)
		(list opcode " " (number->string rel_offset) "\n")
		(error
		 "OP_JUMP should be forward at least 1, not 0 or back") )))
	( (equal? opcode "OP_LOOP")
	  (let* ((dest_offset
		  (resolve_jump_symbol_operand (second line_split) labels))
		 (rel_offset (- (+ 3 bytecode_offset) dest_offset)) )
	    (if (> rel_offset 3)
		(list opcode " " (number->string rel_offset) "\n")
		(error
		 "OP_LOOP should go back at least 4, not less or forward") )))
	( else (list current_line "\n") ) ) )

(define (resolve_jump_labels lines labels)
  (reverse
   (let loop ( (remaining_lines lines)
	       (accum '() )
	       (bytecode_offset 0) )
     (if (null? remaining_lines)
	 accum ; base case
	 (let* ((current_line (car remaining_lines))
		(line_split (whitespace_split (string->list current_line)))
		(opcode_or_label (car line_split)) )
	   (if (endswithchar opcode_or_label #\:)
	       ;; skip labels, don't add to output
	       (loop (cdr remaining_lines) accum bytecode_offset)
	       (let ((opcode_size (lookup_opcode_size opcode_or_label) ))
		 ;; everything else needs label resolution
		 (loop (cdr remaining_lines)
		       (cons (resolve_labels_in_line_parts
			      current_line
			      opcode_or_label
			      line_split
			      labels
			      bytecode_offset
			      opcode_size)
			     accum)
		       (+ bytecode_offset opcode_size)))))))))

(define lines_in_file (newline_split (read_all_stdin_chars)))
(define jump_labels_in_file (find_jump_labels lines_in_file))

(for-each display 
	  (flatten_nested_list (resolve_jump_labels lines_in_file jump_labels_in_file)))
