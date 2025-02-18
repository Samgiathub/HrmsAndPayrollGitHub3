using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TableEmployeeSample
{
    public int EmpId { get; set; }

    public int? CmpId { get; set; }

    public string? EmpFullName { get; set; }

    public double? Salary { get; set; }

    public int? Age { get; set; }

    public string? Designation { get; set; }

    public string? Department { get; set; }
}
