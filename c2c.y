%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "print.h"
%}

%union {
	struct PROGRAM			*ptr_program;
	struct DECLARATION		*ptr_declaration;
	struct IDENTIFIER		*ptr_identifier;
	struct FUNCTION			*ptr_function;
	struct PARAMETER		*ptr_parameter;
	struct COMPOUNDSTMT		*ptr_compoundstmt;
	struct STMT				*ptr_stmt;
	struct ASSIGN			*ptr_assign;
	struct CALL				*ptr_call;
	struct ARG				*ptr_arg;
	struct WHILE_S			*ptr_while_s;
	struct FOR_S			*ptr_for_s;
	struct IF_S				*ptr_if_s;
	struct EXPR				*ptr_expr;
	struct UNOP				*ptr_unop;
	struct ADDIOP			*ptr_addiop;
	struct MULTOP			*ptr_multop;
	struct RELAOP			*ptr_relaop;
	struct EQLTOP			*ptr_eqltop;
	struct ID_S				*ptr_id_s;

	int						intnum;
	float					floatnum;
	char*					ident;
}

%token <intnum>INTNUM <floatnum>FLOATNUM <ident>IDENT
%left '*' '/'
%left '+' '-'

%start Go
%type <ptr_program> Program
%type <ptr_declaration> Declaration
%type <ptr_identifier> Identifier
%type <ptr_function> Function
%type <ptr_parameter> Parameter
%type <ptr_compoundstmt> Compoundstmt
%type <ptr_stmt> Stmt
%type <ptr_assign> Assign
%type <ptr_call> Call
%type <ptr_arg> Arg
%type <ptr_while_s> While_s
%type <ptr_for_s> For_s
%type <ptr_if_s> If_s
%type <ptr_expr> Expr
%type <ptr_unop> Unop
%type <ptr_addiop> Addiop
%type <ptr_multop> Multop
%type <ptr_relaop> Relaop
%type <ptr_eqltop> Eqltop
%type <ptr_id_s> Id_s

%%

Go :
	Program
;

Program :
	Declaration Function
	{
		struct PROGRAM *program = (struct PROGRAM*)malloc( sizeof(struct PROGRAM) );
		program->decl = $1;
		program->func = $2;
		head = program;
		$$ = program;
	}

	| Function
	{
		struct PROGRAM *program = (struct PROGRAM*)malloc( sizeof(struct PROGRAM) );
		program->func = $1;
		head = program;
		$$ = program;
	}
;

Declaration :
	Declaration 'int' Identifier ';'
	{
		struct DECLARATION *declaration = (struct DECLARATION*)malloc( sizeof(struct DECLARATION) );
		declaration->t = eInt;
		declaration->id = $3;
		declaration->prev = $1;
		$$ = declaration;
	}

	| Declaration 'float' Identifier ';'
	{
		struct DECLARATION *declaration = (struct DECLARATION*)malloc( sizeof(struct DECLARATION) );
		declaration->t = eFloat;
		declaration->id = $3;
		declaration->prev = $1;
		$$ = declaration;
	}

	| 'int' Identifier ';'
	{
		struct DECLARATION *declaration = (struct DECLARATION*)malloc( sizeof(struct DECLARATION) );
		declaration->t = eInt;
		declaration->id = $2;
		$$ = declaration;
	}

	| 'float' Identifier ';'
	{
		struct DECLARATION *declaration = (struct DECLARATION*)malloc( sizeof(struct DECLARATION) );
		declaration->t = eFloat;
		declaration->id = $2;
		$$ = declaration;
	}
;

Identifier :
	Identifier IDENT 
	{
		struct IDENTIFIER *identifier = (struct IDENTIFIER*)malloc( sizeof(struct IDENTIFIER) );
		identifier->ID = $2;
		identifier->intnum = 0;
		identifier->prev = $1;
		$$ = identifier;
	}

	| Identifier IDENT '[' INTNUM ']'
	{
		struct IDENTIFIER *identifier = (struct IDENTIFIER*)malloc( sizeof(struct IDENTIFIER) );
		identifier->ID = $2;
		identifier->intnum = $4;
		identifier->prev = $1;
		$$ = identifier;

	}

	| IDENT
	{
		struct IDENTIFIER *identifier = (struct IDENTIFIER*)malloc( sizeof(struct IDENTIFIER) );
		identifier->ID = $1;
		identifier->intnum = 0;
		$$ = identifier;
	}

	| IDENT '[' INTNUM ']'
	{
		struct IDENTIFIER *identifier = (struct IDENTIFIER*)malloc( sizeof(struct IDENTIFIER) );
		identifier->ID = $1;
		identifier->intnum = $3;
		$$ = identifier;
	}
;

Function :
	Function 'int' IDENT '(' Parameter ')' '{' Compoundstmt '}'
	{
		struct FUNCTION *function = (struct FUNCTION*)malloc( sizeof(struct FUNCTION) );
		function->t = eInt;
		function->ID = $3;
		function->param = $5;
		function->cstmt = $8;
		function->prev = $1;
		$$ = function;
	}

	| Function 'float' IDENT '(' Parameter ')' '{' Compoundstmt '}'
	{
		struct FUNCTION *function = (struct FUNCTION*)malloc( sizeof(struct FUNCTION) );
		function->t = eFloat;
		function->ID = $3;
		function->param = $5;
		function->cstmt = $8;
		function->prev = $1;
		$$ = function;
	}

	| Function 'int' IDENT '(' ')' '{' Compoundstmt '}'
	{
		struct FUNCTION *function = (struct FUNCTION*)malloc( sizeof(struct FUNCTION) );
		function->t = eInt;
		function->ID = $3;
		function->cstmt = $7;
		function->prev = $1;
		$$ = function;
	}

	| Function 'float' IDENT '(' ')' '{' Compoundstmt '}'
	{
		struct FUNCTION *function = (struct FUNCTION*)malloc( sizeof(struct FUNCTION) );
		function->t = eFloat;
		function->ID = $3;
		function->cstmt = $7;
		function->prev = $1;
		$$ = function;
	}

	| 'int' IDENT '(' Parameter ')' '{' Compoundstmt '}'
	{
		struct FUNCTION *function = (struct FUNCTION*)malloc( sizeof(struct FUNCTION) );
		function->t = eInt;
		function->ID = $2;
		function->param = $4;
		function->cstmt = $7;
		$$ = function;
	}

	| 'int' IDENT '(' ')' '{' Compoundstmt '}'
	{
		struct FUNCTION *function = (struct FUNCTION*)malloc( sizeof(struct FUNCTION) );
		function->t = eInt;
		function->ID = $2;
		function->cstmt = $6;
		$$ = function;
	}

	| 'float' IDENT '(' ')' '{' Compoundstmt '}'
	{
		struct FUNCTION *function = (struct FUNCTION*)malloc( sizeof(struct FUNCTION) );
		function->t = eFloat;
		function->ID = $2;
		function->cstmt = $6;
		$$ = function;
	}


;

Parameter :
	Parameter 'int' Identifier
	{
		struct PARAMETER *parameter = (struct PARAMETER*)malloc( sizeof(struct PARAMETER) );
		parameter->t = eInt;
		parameter->id = $3;
		parameter->prev = $1;
		$$ = parameter;
	}

	| Parameter 'float' Identifier
	{
		struct PARAMETER *parameter = (struct PARAMETER*)malloc( sizeof(struct PARAMETER) );
		parameter->t = eFloat;
		parameter->id = $3;
		parameter->prev = $1;
		$$ = parameter;
	}

	| 'int' Identifier
	{
		struct PARAMETER *parameter = (struct PARAMETER*)malloc( sizeof(struct PARAMETER) );
		parameter->t = eInt;
		parameter->id = $2;
		$$ = parameter;
	}

	| 'float' Identifier
	{
		struct PARAMETER *parameter = (struct PARAMETER*)malloc( sizeof(struct PARAMETER) );
		parameter->t = eFloat;
		parameter->id = $2;
		$$ = parameter;
	}
;

Compoundstmt :
	Declaration Stmt
	{
		struct COMPOUNDSTMT *compoundstmt = (struct COMPOUNDSTMT*)malloc( sizeof(struct COMPOUNDSTMT) );
		compoundstmt->decl = $1;
		compoundstmt->stmt = $2;
		$$ = compoundstmt;
	}

	| Stmt
	{
		struct COMPOUNDSTMT *compoundstmt = (struct COMPOUNDSTMT*)malloc( sizeof(struct COMPOUNDSTMT) );
		compoundstmt->stmt = $1;
		$$ = compoundstmt;
	}
;

Stmt :
	Stmt Assign ';'
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eAssign;
		stmt->stmt.assign_ = $2;
		stmt->prev = $1;
		$$ = stmt;
	}

	| Stmt Call ';'
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eCall;
		stmt->stmt.call_ = $2;
		stmt->prev = $1;
		$$ = stmt;
	}

	| Stmt 'return' Expr ';'
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eRet;
		stmt->stmt.return_ = $3;
		stmt->prev = $1;
		$$ = stmt;
	}

	| Stmt While_s
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eWhile;
		stmt->stmt.while_ = $2;
		stmt->prev = $1;
		$$ = stmt;
	}

	| Stmt For_s
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eFor;
		stmt->stmt.for_ = $2;
		stmt->prev = $1;
		$$ = stmt;
	}

	| Stmt If_s
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eIf;
		stmt->stmt.if_ = $2;
		stmt->prev = $1;
		$$ = stmt;
	}

	| Stmt '{' Compoundstmt '}'
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eCompound;
		stmt->stmt.cstmt_ = $3;
		stmt->prev = $1;
		$$ = stmt;
	}

	| Stmt Compoundstmt
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eSemi;
		stmt->stmt.cstmt_ = $2;
		stmt->prev = $1;
		$$ = stmt;
	}

	| Assign ';'
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eAssign;
		stmt->stmt.assign_ = $1;
		$$ = stmt;
	}

	| Call ';'
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eCall;
		stmt->stmt.call_ = $1;
		$$ = stmt;
	}

	| 'return' Expr ';'
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eRet;
		stmt->stmt.return_ = $2;
		$$ = stmt;
	}

	| While_s
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eWhile;
		stmt->stmt.while_ = $1;
		$$ = stmt;
	}

	| For_s
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eFor;
		stmt->stmt.for_ = $1;
		$$ = stmt;
	}

	| If_s
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eIf;
		stmt->stmt.if_ = $1;
		$$ = stmt;
	}

	|  '{' Compoundstmt '}'
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eCompound;
		stmt->stmt.cstmt_ = $2;
		$$ = stmt;
	}

	| Compoundstmt
	{
		struct STMT *stmt = (struct STMT*)malloc( sizeof(struct STMT) );
		stmt->s = eSemi;
		stmt->stmt.cstmt_ = $1;
		$$ = stmt;
	}
;

Assign :
	IDENT '=' Expr
	{
		struct ASSIGN *assign = (struct ASSIGN*)malloc( sizeof(struct ASSIGN) );
		assign->ID = $1;
		assign->expr = $3;
		$$ = assign;
	}

	| IDENT '[' Expr ']' '=' Expr
	{
		struct ASSIGN *assign = (struct ASSIGN*)malloc( sizeof(struct ASSIGN) );
		assign->ID = $1;
		assign->index = $3;
		assign->expr = $6;
		$$ = assign;
	}
;

Call :
	IDENT '(' Arg ')'
	{
		struct CALL *call = (struct CALL*)malloc( sizeof(struct CALL) );
		call->ID = $1;
		call->arg = $3;
		$$ = call;
	}
;

Arg :
	Arg Expr
	{
		struct ARG *arg = (struct ARG*)malloc( sizeof(struct ARG) );
		arg->expr = $2;
		arg->prev = $1;
		$$ = arg;
	}

	| Expr
	{
		struct ARG *arg = (struct ARG*)malloc( sizeof(struct ARG) );
		arg->expr = $1;
		$$ = arg;
	}
;

While_s :
	'while' '(' Expr ')' '{' Stmt '}'
	{
		struct WHILE_S *while_s = (struct WHILE_S*)malloc( sizeof(struct WHILE_S) );
		while_s->do_while = 0;
		while_s->cond = $3;
		while_s->stmt = $6;
		$$ = while_s;
	}

	| 'do' '{' Stmt '}' 'while' '(' Expr ')'
	{
		struct WHILE_S *while_s = (struct WHILE_S*)malloc( sizeof(struct WHILE_S) );
		while_s->do_while = 1;
		while_s->cond = $7;
		while_s->stmt = $3;
		$$ = while_s;
	}
;

For_s :
	'for' '(' Assign ';' Expr ';' Assign ')' '{' Stmt '}'
	{
		struct FOR_S *for_s = (struct FOR_S*)malloc( sizeof(struct FOR_S) );
		for_s->init = $3;
		for_s->cond = $5;
		for_s->inc = $7;
		for_s->stmt = $10;
		$$ = for_s;
	}
;

If_s :
	'if' '(' Expr ')' '{' Stmt '}'
	{
		struct IF_S *if_s = (struct IF_S*)malloc( sizeof(struct IF_S) );
		if_s->cond = $3;
		if_s->if_ = $6;
		$$ = if_s;
	}

	| 'if' '(' Expr ')' '{' Stmt '}' 'else' '{' Stmt '}'
	{
		struct IF_S *if_s = (struct IF_S*)malloc( sizeof(struct IF_S) );
		if_s->cond = $3;
		if_s->if_ = $6;
		if_s->else_ = $10;
		$$ = if_s;
	}
;

Expr :
	Unop
	{
		struct EXPR* expr = (struct EXPR*)malloc( sizeof(struct EXPR) );
		expr->e = eUnop;
		expr->expression.unop_ = $1;
		$$ = expr;
	}

	| Addiop
	{
		struct EXPR* expr = (struct EXPR*)malloc( sizeof(struct EXPR) );
		expr->e = eAddi;
		expr->expression.addiop_ = $1;
		$$ = expr;
	}

	| Multop
	{
		struct EXPR* expr = (struct EXPR*)malloc( sizeof(struct EXPR) );
		expr->e = eMulti;
		expr->expression.multop_ = $1;
		$$ = expr;
	}

	| Relaop
	{
		struct EXPR* expr = (struct EXPR*)malloc( sizeof(struct EXPR) );
		expr->e = eRela;
		expr->expression.relaop_ = $1;
		$$ = expr;
	}

	| Eqltop
	{
		struct EXPR* expr = (struct EXPR*)malloc( sizeof(struct EXPR) );
		expr->e = eEqlt;
		expr->expression.eqltop_ = $1;
		$$ = expr;
	}

	| Call
	{
		struct EXPR* expr = (struct EXPR*)malloc( sizeof(struct EXPR) );
		expr->e = eCallExpr;
		expr->expression.call_ = $1;
		$$ = expr;
	}

	| Id_s
	{
		struct EXPR* expr = (struct EXPR*)malloc( sizeof(struct EXPR) );
		expr->e = eId;
		expr->expression.ID_ = $1;
		$$ = expr;
	}

	| '(' Expr ')'
	{
		struct EXPR* expr = (struct EXPR*)malloc( sizeof(struct EXPR) );
		expr->e = eExpr;
		expr->expression.bracket = $2;
		$$ = expr;
	}

	| INTNUM
	{
		struct EXPR* expr = (struct EXPR*)malloc( sizeof(struct EXPR) );
		expr->e = eIntnum;
		expr->expression.intnum = $1;
		$$ = expr;
	}

	| FLOATNUM
	{
		struct EXPR* expr = (struct EXPR*)malloc( sizeof(struct EXPR) );
		expr->e = eFloatnum;
		expr->expression.floatnum = $1;
		$$ = expr;
	}
;

Unop :
	'-' Expr
	{
		struct UNOP* unop = (struct UNOP*)malloc( sizeof(struct UNOP) );
		unop->u = eNegative;
		unop->expr = $2;
		$$ = unop;
	}
;

Addiop :
	Expr '+' Expr
	{
		struct ADDIOP* addiop = (struct ADDIOP*)malloc( sizeof(struct ADDIOP) );
		addiop->a = ePlus;
		addiop->lhs = $1;
		addiop->rhs = $3;
		$$ = addiop;
	}

	| Expr '-' Expr
	{
		struct ADDIOP* addiop = (struct ADDIOP*)malloc( sizeof(struct ADDIOP) );
		addiop->a = eMinus;
		addiop->lhs = $1;
		addiop->rhs = $3;
		$$ = addiop;
	}
;

Multop :
	Expr '*' Expr
	{
		struct MULTOP* multop = (struct MULTOP*)malloc( sizeof(struct MULTOP) );
		multop->m = eMult;
		multop->lhs = $1;
		multop->rhs = $3;
		$$ = multop;
	}

	| Expr '/' Expr
	{
		struct MULTOP* multop = (struct MULTOP*)malloc( sizeof(struct MULTOP) );
		multop->m = eDiv;
		multop->lhs = $1;
		multop->rhs = $3;
		$$ = multop;
	}
;

Relaop :
	Expr '<' Expr
	{
		struct RELAOP* relaop = (struct RELAOP*)malloc( sizeof(struct RELAOP) );
		relaop->r = eLT;
		relaop->lhs = $1;
		relaop->rhs = $3;
		$$ = relaop;
	}

	| Expr '>' Expr
	{
		struct RELAOP* relaop = (struct RELAOP*)malloc( sizeof(struct RELAOP) );
		relaop->r = eGT;
		relaop->lhs = $1;
		relaop->rhs = $3;
		$$ = relaop;
	}

	| Expr '<=' Expr
	{
		struct RELAOP* relaop = (struct RELAOP*)malloc( sizeof(struct RELAOP) );
		relaop->r = eLE;
		relaop->lhs = $1;
		relaop->rhs = $3;
		$$ = relaop;
	}

	| Expr '>=' Expr
	{
		struct RELAOP* relaop = (struct RELAOP*)malloc( sizeof(struct RELAOP) );
		relaop->r = eGE;
		relaop->lhs = $1;
		relaop->rhs = $3;
		$$ = relaop;
	}
;

Eqltop :
	Expr '==' Expr
	{
		struct EQLTOP* eqltop = (struct EQLTOP*)malloc( sizeof(struct EQLTOP) );
		eqltop->e = eEQ;
		eqltop->lhs = $1;
		eqltop->rhs = $3;
		$$ = eqltop;
	}

	| Expr '!=' Expr
	{
		struct EQLTOP* eqltop = (struct EQLTOP*)malloc( sizeof(struct EQLTOP) );
		eqltop->e = eNE;
		eqltop->lhs = $1;
		eqltop->rhs = $3;
		$$ = eqltop;
	}

Id_s :
	IDENT
	{
		struct ID_S* id_s = (struct ID_S*)malloc( sizeof(struct ID_S) );
		id_s->ID = $1;
		$$ = id_s;
	}

	| IDENT '[' Expr ']'
	{
		struct ID_S* id_s = (struct ID_S*)malloc( sizeof(struct ID_S) );
		id_s->ID = $1;
		id_s->expr = $3;
		$$ = id_s;
	}
;

%%

int yyerror (char* s) {
	return fprintf(stderr, "%s\n", s);
}
