using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class GetEmployeeTask
{
    public decimal EmpId { get; set; }

    public string EmployeeName { get; set; } = null!;

    public string DesigName { get; set; } = null!;

    public string? BranchName { get; set; }

    public decimal CmpId { get; set; }
}
