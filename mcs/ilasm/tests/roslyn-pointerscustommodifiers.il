.class public C
{
  .field public static class MyTask modopt(class MyTask) *[] F0
  .method public hidebysig specialname rtspecialname instance void .ctor() cil managed { ret }
}
.class public MyTask
{
  .custom instance void System.Runtime.CompilerServices.AsyncMethodBuilderAttribute::.ctor(class [mscorlib]System.Type) = { type(MyTaskMethodBuilder) }
  .method public hidebysig specialname rtspecialname instance void .ctor() cil managed { ret }
}
.class public MyTaskMethodBuilder
{
  .method public hidebysig specialname rtspecialname instance void .ctor() cil managed { ret }
}
.namespace System.Runtime.CompilerServices
{
  .class public AsyncMethodBuilderAttribute extends [mscorlib]System.Attribute
  {
    .method public hidebysig specialname rtspecialname instance void .ctor(class [mscorlib]System.Type t) cil managed { ret }
  }
}