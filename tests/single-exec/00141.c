#define CAT(x,y) x ## y
#define XCAT(x,y) CAT(x,y)
#define FOO foo
#define BAR bar

int
main(void)
{
	int foo = 0, bar = 0, foobar;

	CAT(foo,bar) = foo + bar;
	XCAT(FOO,BAR) = foo + bar;
	return 0;
}
