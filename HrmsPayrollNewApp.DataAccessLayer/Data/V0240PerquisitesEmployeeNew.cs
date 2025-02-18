using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0240PerquisitesEmployeeNew
{
    public decimal? EmpId { get; set; }

    public string? FinancialYear { get; set; }

    public string? EmpName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }
}
