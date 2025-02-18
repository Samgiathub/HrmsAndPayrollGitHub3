using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100WeekoffAdjRpt
{
    public decimal WTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public string WeekoffDay { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? EmpLeft { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpLastName { get; set; }

    public DateTime? EmpLeftDate { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public string CmpName { get; set; } = null!;

    public string CmpAddress { get; set; } = null!;

    public string? BranchName { get; set; }

    public decimal? BranchId { get; set; }

    public decimal Expr1 { get; set; }
}
