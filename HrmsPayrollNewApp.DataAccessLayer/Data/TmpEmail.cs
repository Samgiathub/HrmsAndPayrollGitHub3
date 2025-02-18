using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TmpEmail
{
    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal LoginId { get; set; }

    public string? EmailId { get; set; }

    public string Designation { get; set; } = null!;

    public string? EmpLeft { get; set; }

    public string? BranchIdMulti { get; set; }

    public string? BranchNameMulti { get; set; }
}
