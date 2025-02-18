using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100RimbursementDetail
{
    public string? EmpFirstName { get; set; }

    public string? EmpFullName { get; set; }

    public string RimbName { get; set; } = null!;

    public decimal? RimbTranId { get; set; }

    public decimal? RimbId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? RimbAmount { get; set; }

    public string? EmpLeft { get; set; }

    public string? BranchName { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? EmpCode { get; set; }
}
