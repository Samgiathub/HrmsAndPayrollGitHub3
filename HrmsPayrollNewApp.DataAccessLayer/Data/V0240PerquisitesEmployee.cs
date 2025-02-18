using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0240PerquisitesEmployee
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal PerquisitesId { get; set; }

    public string FinancialYear { get; set; } = null!;

    public string? EmpName { get; set; }

    public string PerquisitesName { get; set; } = null!;

    public string? AlphaEmpCode { get; set; }

    public DateTime? ChangeDate { get; set; }
}
