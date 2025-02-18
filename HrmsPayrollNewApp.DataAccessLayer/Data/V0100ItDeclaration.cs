using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100ItDeclaration
{
    public string? ItName { get; set; }

    public decimal ItTranId { get; set; }

    public decimal ItId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal Amount { get; set; }

    public string DocName { get; set; } = null!;

    public string EmpFirstName { get; set; } = null!;

    public byte RepeatYearly { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal EmpCode { get; set; }

    public string? EmpFullName { get; set; }
}
