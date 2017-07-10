#include <stdio.h>
#include "ast.h"
#include "print.h"

FILE *tree;
FILE *table;

int indent_n;
void indent(int n);

int role;
int type;
int array;
int action;
int io;
int function_order[30];

void symbol_table(void)
{
	int i;
	int j;
	int aaa;
	int order;
	int count;
	int print;
	int stair;
	int while_num[30];
	int for_num[30];
	int if_num[30];
	int compound_num[30];
	int while_count;
	int for_count;
	int if_count;
	int compound_count;
	struct node* t;
	char *temp;

	print = 0;
	aaa = 0;
	count = 0;
	order = 0;
	stair = -1;
	while_count = 0;
	for_count = 0;
	if_count = 0;
	compound_count = 0;
	for(i=0;i<30;i++)
		while_num[i]=0;
	for(i=0;i<30;i++)
		for_num[i]=0;
	for(i=0;i<30;i++)
		if_num[i]=0;
	for(i=0;i<30;i++)
		compound_num[i]=0;
	t = h;

	while(1) {
		if( t == NULL )
			break;

		if( t->io == IN ) {
			count = 0;
			print = 0;
    		if( t->action == FUNC) {
				temp = strdup(t->name);
		    }

			if( t->action == WHILE ) {
				stair++;
				function_order[order] = WHILE;
				while_num[stair]++;
				order++;
			}

			if( t->action == FOR ) {
				stair++;
				function_order[order] = FOR;
				for_num[stair]++;
				order++;
			}

			if( t->action == IF ) {
				stair++;
				function_order[order] = IF;
				if_num[stair]++;
				order++;
			}

			if( t->action == COMP ) {
				stair++;
				function_order[order] = COMP;
				compound_num[stair]++;
				order++;
			}
		}

		if( t->role == VAR || t->role == PARAM ) {

			if( print == 0 ) {
				print = 1;

				if( aaa != 0 )
					fprintf(table, "\n");
				aaa = 1;

				fprintf(table, "Function name : %s",temp);

				for(i=0; function_order[i] != 0 ;i++) {

					if( function_order[i] == WHILE )
						fprintf(table, " - WHILE(%d)", while_num[i]);

					if( function_order[i] == FOR )
						fprintf(table, " - FOR(%d)", for_num[i]);

					if( function_order[i] == IF )
						fprintf(table, " - IF(%d)", if_num[i]);

					if( function_order[i] == COMP )
						fprintf(table, " - COMPOUND(%d)", compound_num[i]);
				}
				fprintf(table, "\n");
				
				fprintf(table, "%10s", "count");
				fprintf(table, "%10s", "type");
				fprintf(table, "%10s", "name");
				fprintf(table, "%10s", "array");
				fprintf(table, "%10s", "role");
				fprintf(table, "\n");
			}
			
			count++;
			fprintf(table, "%10d", count);

			if( t->type == INT )
				fprintf(table, "%10s", "int");

			if( t->type == FLOAT )
				fprintf(table, "%10s", "float");

			fprintf(table, "%10s", t->name);

			if( t->array == SCALAR )
				fprintf(table, "          ");
			
			if( t->array != SCALAR )
				fprintf(table, "%10d", t->array);

			if( t->role == VAR )
				fprintf(table, "%10s", "variable");

			if( t->role == PARAM )
				fprintf(table, "%10s", "parameter");

			fprintf(table, "\n");
		}

		if( t->io == OUT ) {
			count = 0;

			if( t->action == FUNC ) {
				for(i=0; i<30; i++)
					function_order[i] = 0;

				stair = -1;
				order = 0;
				while_count = 0;
				for_count = 0;
				if_count = 0;
				compound_count = 0;

				for(i=0; i<30; i++)
					while_num[i] = 0;
				for(i=0; i<30; i++)
					for_num[i] = 0;
				for(i=0; i<30; i++)
					if_num[i] = 0;
				for(i=0; i<30; i++)
					compound_num[i] = 0;
			}
			else {
				stair--;
				order--;
				function_order[order] = 0;
			}
		}

		t = t->next;
	}
}

int main(void)
{
	tree = fopen("tree.txt","w");
	table = fopen("table.txt","w");

	if(!yyparse())
		dfs();

	symbol_table();

	fprintf(tree, "\n");

	return 0;
}

void dfs(void)
{
	if( head == NULL ) {
		fprintf(stderr, "program does not exist.\n");
		return;
	}

	if( head->decl != NULL )
		Declaration( head->decl );

	if( head->func != NULL )
		Function( head->func );
}

void Declaration(struct DECLARATION* declaration)
{
	role = VAR;

	if( declaration->prev != NULL )
		Declaration( declaration->prev );

	if( declaration->t == eInt ) {
		type = INT;
		indent(indent_n);
		fprintf(tree, "int ");
	}
	
	if( declaration->t == eFloat ) {
		type = FLOAT;
		indent(indent_n);
		fprintf(tree, "float ");
	}

	if( declaration->id != NULL )
		Identifier( declaration->id );

	fprintf(tree, ";\n");
}

void Identifier(struct IDENTIFIER* identifier)
{
	if( identifier->prev != NULL ) {
		Identifier( identifier->prev );
		fprintf( tree, ", ");
	}

	if( identifier->ID != NULL )
		fprintf(tree, "%s", identifier->ID);

	array = SCALAR;

	if( identifier->intnum != 0 ) {
		array = identifier ->intnum;
		fprintf(tree, "[%d]", identifier->intnum);
	}

	action = -1;
	io = -1;
	add(identifier->ID, role, type, array, action, io);
}

void Function(struct FUNCTION* function)
{
	if( function->prev != NULL ) {
		Function( function->prev );
		fprintf(tree, "\n");
	}

	role = -1;
	type = -1;
	array = -1;
	action = FUNC;
	io = IN;
	add(function->ID, role, type, array, action, io);

	if( function->t == eInt )
		fprintf(tree, "int ");

	if( function->t == eFloat )
		fprintf(tree, "float ");

	if( function->ID != NULL )
		fprintf(tree, "%s", function->ID);

	fprintf(tree, " (");
	if( function->param != NULL ) {
		role = PARAM;
		Parameter( function->param );
	}
	fprintf(tree, ")\n");

	fprintf(tree, "{\n");
	indent_n++;
	if( function->cstmt != NULL ) {
		role = VAR;
		Compoundstmt( function->cstmt );
	}
	indent_n--;
	fprintf(tree, "}\n");

	role = -1;
	type = -1;
	array = -1;
	action = FUNC;
	io = OUT;
	add(function->ID, role, type, array, action, io);
}

void Parameter(struct PARAMETER* parameter)
{
	if( parameter->prev != NULL ) {
		Parameter( parameter->prev );
		fprintf(tree, ", ");
	}

	if( parameter->t == eInt ) {
		type = INT;
		fprintf(tree, "int ");
	}

	if( parameter->t == eFloat ) {
		type = FLOAT;
		fprintf(tree, "float ");
	}

	role = PARAM;

	if( parameter->id != NULL )
		Identifier( parameter->id );
}

void Compoundstmt(struct COMPOUNDSTMT* compoundstmt)
{
	if( compoundstmt->decl != NULL )
		Declaration( compoundstmt->decl );

	fprintf(tree,"\n");

	if( compoundstmt->stmt != NULL )
		Stmt( compoundstmt->stmt );
}

void Stmt(struct STMT* stmt)
{
	if( stmt->prev != NULL )
		Stmt( stmt->prev );

	if( stmt->s == eAssign && stmt->stmt.assign_ != NULL ) {
		indent(indent_n);
		Assign( stmt->stmt.assign_ );
		fprintf(tree,";\n");
	}

	if( stmt->s == eCall && stmt->stmt.call_ != NULL )
		Call( stmt->stmt.call_ );

	if( stmt->s == eRet && stmt->stmt.return_ != NULL ) {
		fprintf(tree,"\n");
		indent(indent_n);
		fprintf(tree,"return ");
		Expr( stmt->stmt.return_ );
		fprintf(tree,";\n");
	}

	if( stmt->s == eWhile && stmt->stmt.while_ != NULL )
		While_s( stmt->stmt.while_ );

	if( stmt->s == eFor && stmt->stmt.for_ != NULL )
		For_s( stmt->stmt.for_ );

	if( stmt->s == eIf && stmt->stmt.if_ != NULL )
		If_s( stmt->stmt.if_ );

	if( stmt->s == eCompound && stmt->stmt.cstmt_ != NULL ) {
		type = -1;
		array = -1;
		role = -1;
		io = IN;
		action = COMP;
		add("COMP", role, type, array, action, io);

		indent(indent_n);
		fprintf(tree, "{\n");
		indent_n++;
		Compoundstmt( stmt->stmt.cstmt_ );
		indent_n--;
		indent(indent_n);
		fprintf(tree, "}\n");

		type = -1;
		array = -1;
		role = -1;
		io = OUT;
		action = COMP;
		add("COMP", role, type, array, action, io);
	}

	if( stmt->s == eSemi && stmt->stmt.cstmt_ != NULL )
		Compoundstmt( stmt->stmt.cstmt_ );
}

void Assign(struct ASSIGN* assign)
{
	fprintf(tree, "%s", assign->ID);

	if( assign->index != NULL ) {
		fprintf(tree, "[");
		Expr( assign->index );
		fprintf(tree, "]");
	}

	fprintf(tree, " = ");

	if( assign->expr != NULL )
		Expr( assign->expr );
}

void Call(struct CALL* call)
{
	indent(indent_n);
	fprintf(tree, "%s ", call->ID);

	if( call->arg != NULL ) {
		fprintf(tree, "(");
		Arg( call->arg );
		fprintf(tree, ")");
	}

	fprintf(tree,";\n");
}

void Arg(struct ARG* arg)
{
	if( arg->prev != NULL ) {
		Arg( arg->prev );
		fprintf(tree, ", ");
	}

	if( arg->expr != NULL )
		Expr( arg->expr );
}

void While_s(struct WHILE_S* while_s)
{
	type = -1;
	array = -1;
	role = -1;
	action = WHILE;
	io = IN;
	add("while", role, type, array, action, io);

	if( while_s->do_while == 0 ) {
		indent(indent_n);
		fprintf(tree, "while (");

		if( while_s->cond != NULL )
			Expr( while_s->cond );

		fprintf(tree, ")\n");
		indent(indent_n);
		fprintf(tree, "{\n");

		indent_n++;

		if( while_s->stmt != NULL )
			Stmt( while_s->stmt );

		indent_n--;
		indent(indent_n);
		fprintf(tree, "}\n");

	}
	
	if( while_s->do_while == 1 ) {
		indent(indent_n);
		fprintf(tree, "do {\n");
		indent_n++;

		if( while_s->stmt != NULL )
			Stmt( while_s->stmt );

		indent_n--;
		indent(indent_n);
		fprintf(tree, "} while (");

		if( while_s->cond != NULL )
			Expr( while_s->cond );

		fprintf(tree, ")\n");
	}

	type = -1;
	array = -1;
	role = -1;
	action = WHILE;
	io = OUT;
	add("while", role, type, array, action, io);
}

void For_s(struct FOR_S* for_s)
{
	array = -1;
	type = -1;
	role = -1;
	action = FOR;
	io = IN;
	add("for", role, type, array, action, io);

	indent(indent_n);
	fprintf(tree, "for (");

	if( for_s->init != NULL )
		Assign( for_s->init );

	fprintf(tree, "; ");

	if( for_s->cond != NULL )
		Expr( for_s->cond );

	fprintf(tree, "; ");

	if( for_s->inc != NULL )
		Assign( for_s->inc );

	fprintf(tree, ")\n");
	indent(indent_n);
	fprintf(tree, "{\n");

	indent_n++;

	if( for_s->stmt != NULL )
		Stmt( for_s->stmt );

	indent_n--;
	indent(indent_n);
	fprintf(tree,"}\n");

	type = -1;
	array = -1;
	role = -1;
	action = FOR;
	io = OUT;
	add("for", role, type, array, action, io);
}

void If_s(struct IF_S* if_s)
{
	type = -1;
	role = -1;
	array = -1;
	action = IF;
	io = IN;
	add("if", role, type, array, action, io);

	indent(indent_n);
	fprintf(tree, "if (");

	if( if_s->cond != NULL )
		Expr( if_s->cond );

	fprintf(tree, ")\n");
	indent(indent_n);
	fprintf(tree, "{\n");

	indent_n++;

	if( if_s->if_ != NULL )
		Stmt( if_s->if_ );

	indent_n--;
	indent(indent_n);
	fprintf(tree,"}\n");

	if( if_s->else_ != NULL ) {
		indent(indent_n);
		fprintf(tree, "else\n");
		indent(indent_n);
		fprintf(tree,"{\n");
		indent_n++;
		Stmt( if_s->else_ );
		indent_n--;
		indent(indent_n);
		fprintf(tree,"}\n");
	}

	type = -1;
	array = -1;
	role = -1;
	action = IF;
	io = OUT;
	add("if", role, type, array, action, io);
}

void Expr(struct EXPR* expr)
{
	if( expr->e == eUnop && expr->expression.unop_ != NULL )
		Unop( expr->expression.unop_ );

	if( expr->e == eAddi  && expr->expression.addiop_ != NULL )
		Addiop( expr->expression.addiop_ );

	if( expr->e == eMulti && expr->expression.multop_ != NULL )
		Multop( expr->expression.multop_ );

	if( expr->e == eRela && expr->expression.relaop_ != NULL )
		Relaop( expr->expression.relaop_ );

	if( expr->e == eEqlt && expr->expression.eqltop_ != NULL )
		Eqltop( expr->expression.eqltop_ );

	if( expr->e == eCallExpr && expr->expression.call_ != NULL ) 
		Call( expr->expression.call_);

	if( expr->e == eId && expr->expression.ID_ != NULL )
		Id_s( expr->expression.ID_ );

	if( expr->e == eExpr && expr->expression.bracket != NULL ) {
		fprintf(tree, "(");
		Expr( expr->expression.bracket );
		fprintf(tree, ")");
	}

	if( expr->e == eIntnum )
		fprintf(tree, "%d", expr->expression.intnum);

	if( expr->e == eFloatnum )
		fprintf(tree, "%.1f", expr->expression.floatnum);
}

void Unop(struct UNOP* unop)
{
	if( unop->u == eNegative )
		fprintf(tree, "-" );

	if( unop->expr != NULL )
		Expr( unop->expr );

}

void Addiop(struct ADDIOP* addiop)
{
	if( addiop->lhs != NULL )
		Expr( addiop->lhs );

	if( addiop->a == ePlus )
		fprintf(tree, " + ");

	if( addiop->a == eMinus )
		fprintf(tree, " - ");

	if( addiop->rhs != NULL )
		Expr( addiop->rhs );
}

void Multop(struct MULTOP* multop)
{
	if( multop->lhs != NULL )
		Expr( multop->lhs );

	if( multop->m == eMult )
		fprintf(tree, " * ");

	if( multop->m == eDiv )
		fprintf(tree, " / ");

	if( multop->rhs != NULL )
		Expr( multop->rhs );
}

void Relaop(struct RELAOP* relaop)
{
	if( relaop->lhs != NULL )
		Expr( relaop->lhs );

	if( relaop->r == eLT )
		fprintf(tree, " < ");

	if( relaop->r == eGT )
		fprintf(tree, " > ");

	if( relaop->r == eLE )
		fprintf(tree, " <= ");

	if( relaop->r == eGE )
		fprintf(tree, " >= ");

	if( relaop->rhs != NULL )
		Expr( relaop->rhs );
}

void Eqltop(struct EQLTOP* eqltop)
{
	if( eqltop->lhs != NULL )
		Expr( eqltop->lhs );

	if( eqltop->e == eEQ )
		fprintf(tree, " == ");

	if( eqltop->e == eNE )
		fprintf(tree, " != ");

	if( eqltop->rhs != NULL )
		Expr( eqltop->rhs );
}

void Id_s(struct ID_S* id_s)
{
	fprintf(tree, "%s", id_s->ID);

	if( id_s->expr != NULL ) {
		fprintf(tree, "[");
		Expr( id_s->expr );
		fprintf(tree, "]");
	}
}

void indent(int n)
{
	int i;

	for( i=0; i<n; i++ )
		fprintf(tree, "\t");
}

void add(char* name, int role, int type, int array, int action, int io)
{
	struct node* temp;
	struct node* new = (struct node*)malloc(sizeof( struct node ));
	new->name = strdup(name);
	new->role = role;
	new->type = type;
	new->array = array;
	new->action = action;
	new->io = io;

	if( h == NULL ) {
		h = new;
		return;
	}

	temp = h;
	while(1) {
		if( temp->next == NULL ) {
			temp->next = new;
			break;
		}

		temp = temp->next;
	}
}
