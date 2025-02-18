using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class Student
{
    public int Iid { get; set; }

    public string Name { get; set; } = null!;

    public int Age { get; set; }

    public int Class { get; set; }
}
