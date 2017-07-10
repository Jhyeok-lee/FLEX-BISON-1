#ifndef PRINT_H
#define PRINT_H

#include "ast.h"

#define PARAM			0
#define VAR				1

#define INT				2
#define FLOAT			3

#define SCALAR			-1
#define ARRAY			5

#define FUNC			6
#define WHILE			7
#define FOR				8
#define IF				9
#define COMP			10

#define IN				11
#define OUT				12

struct PROGRAM *head;

struct node {
	char*	name;

	int		role;
	int		type;
	int		array;
	int		action;
	int		io;

	struct node* next;
};

struct node* h;

void dfs(void);
void Declaration(struct DECLARATION*);
void Identifier(struct IDENTIFIER*);
void Function(struct FUNCTION*);
void Parameter(struct PARAMETER*);
void Compoundstmt(struct COMPOUNDSTMT*);
void Stmt(struct STMT*);
void Assign(struct ASSIGN*);
void Call(struct CALL*);
void Arg(struct ARG*);
void While_s(struct WHILE_S*);
void For_s(struct FOR_S*);
void If_s(struct IF_S*);
void Expr(struct EXPR*);
void Unop(struct UNOP*);
void Addiop(struct ADDIOP*);
void Multop(struct MULTOP*);
void Relaop(struct RELAOP*);
void Eqltop(struct EQLTOP*);
void Id_s(struct ID_S*);

void add(char*,int,int,int,int,int);
struct node* find(char*);
#endif
