using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0190TaxOnNesImport
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdId { get; set; }

    public decimal Month { get; set; }

    public decimal Year { get; set; }

    public string AdSortName { get; set; } = null!;

    public string AdCalculateOn { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal Amount { get; set; }

    public string? EmpFullName { get; set; }

    public decimal BranchId { get; set; }

    public decimal EmpCode { get; set; }

    public int IncrementId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public byte IsRepeat { get; set; }

    public string? Comments { get; set; }

    public byte HideInReports { get; set; }

    public string? EmpLeft { get; set; }
}
