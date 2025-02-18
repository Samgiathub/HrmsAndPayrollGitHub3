using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class GetEmployeeForTraining
{
    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal BranchId { get; set; }
}
