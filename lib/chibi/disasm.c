/*  disasm.c -- optional debugging utilities                  */
/*  Copyright (c) 2009-2010 Alex Shinn.  All rights reserved. */
/*  BSD-style license: http://synthcode.com/license.txt       */

#include "chibi/eval.h"
#include "../../opt/opcode_names.h"

#define SEXP_DISASM_MAX_DEPTH 8
#define SEXP_DISASM_PAD_WIDTH 4

static sexp disasm (sexp ctx, sexp self, sexp bc, sexp out, int depth) {
  sexp tmp;
  unsigned char *ip, opcode, i;

  if (sexp_procedurep(bc)) {
    bc = sexp_procedure_code(bc);
  } else if (sexp_opcodep(bc)) {
    sexp_printf(ctx, out, "%s is a primitive\n", sexp_opcode_name(bc));
    return SEXP_VOID;
  } else if (! sexp_bytecodep(bc)) {
    return sexp_type_exception(ctx, self, SEXP_BYTECODE, bc);
  }
  if (! sexp_oportp(out)) {
    return sexp_type_exception(ctx, self, SEXP_OPORT, out);
  }

  for (i=0; i<(depth*SEXP_DISASM_PAD_WIDTH); i++)
    sexp_write_char(ctx, ' ', out);
  sexp_write_string(ctx, "-------------- ", out);
  if (sexp_truep(sexp_bytecode_name(bc))) {
    sexp_write(ctx, sexp_bytecode_name(bc), out);
    sexp_write_char(ctx, ' ', out);
  }
  sexp_printf(ctx, out, "%p\n", bc);

  ip = sexp_bytecode_data(bc);

 loop:
  for (i=0; i<(depth*SEXP_DISASM_PAD_WIDTH); i++)
    sexp_write_char(ctx, ' ', out);
  opcode = *ip++;
  if (opcode*sizeof(char*) < sizeof(reverse_opcode_names)) {
    sexp_printf(ctx, out, "  %s ", reverse_opcode_names[opcode]);
  } else {
    sexp_printf(ctx, out, "  <unknown> %d ", opcode);
  }
  switch (opcode) {
  case SEXP_OP_STACK_REF:
  case SEXP_OP_LOCAL_REF:
  case SEXP_OP_LOCAL_SET:
  case SEXP_OP_CLOSURE_REF:
  case SEXP_OP_JUMP:
  case SEXP_OP_JUMP_UNLESS:
  case SEXP_OP_TYPEP:
  case SEXP_OP_FCALL0:
  case SEXP_OP_FCALL1:
  case SEXP_OP_FCALL2:
  case SEXP_OP_FCALL3:
  case SEXP_OP_FCALL4:
    sexp_printf(ctx, out, "%ld", (long) ((sexp*)ip)[0]);
    ip += sizeof(sexp);
    break;
  case SEXP_OP_SLOT_REF:
  case SEXP_OP_SLOT_SET:
  case SEXP_OP_MAKE:
    ip += sizeof(sexp)*2;
    break;
  case SEXP_OP_GLOBAL_REF:
  case SEXP_OP_GLOBAL_KNOWN_REF:
  case SEXP_OP_TAIL_CALL:
  case SEXP_OP_CALL:
  case SEXP_OP_PUSH:
    tmp = ((sexp*)ip)[0];
    if (((opcode == SEXP_OP_GLOBAL_REF) || (opcode == SEXP_OP_GLOBAL_KNOWN_REF))
        && sexp_pairp(tmp))
      tmp = sexp_car(tmp);
    else if ((opcode == SEXP_OP_PUSH) && (sexp_pairp(tmp) || sexp_idp(tmp)))
      sexp_write_char(ctx, '\'', out);
    sexp_write(ctx, tmp, out);
    ip += sizeof(sexp);
    break;
  }
  sexp_write_char(ctx, '\n', out);
  if ((opcode == SEXP_OP_PUSH) && (depth < SEXP_DISASM_MAX_DEPTH)
      && (sexp_bytecodep(tmp) || sexp_procedurep(tmp)))
    disasm(ctx, self, tmp, out, depth+1);
  if (ip - sexp_bytecode_data(bc) < sexp_bytecode_length(bc))
    goto loop;
  return SEXP_VOID;
}

static sexp sexp_disasm (sexp ctx sexp_api_params(self, n), sexp bc, sexp out) {
  return disasm(ctx, self, bc, out, 0);
}

sexp sexp_init_library (sexp ctx sexp_api_params(self, n), sexp env) {
  sexp_define_foreign_param(ctx, env, "disasm", 2, (sexp_proc1)sexp_disasm, "*current-output-port*");
  return SEXP_VOID;
}
