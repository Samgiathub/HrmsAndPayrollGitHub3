using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100EmpLtaMedicalDetail
{
    public decimal LmId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string Mode { get; set; } = null!;

    public decimal? Amount { get; set; }

    public int TypeId { get; set; }

    public int? CarryFwAmount { get; set; }

    public int? NoItClaims { get; set; }

    public string? BranchName { get; set; }

    public decimal? EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? TypeName { get; set; }

    public string? EmpFirstName { get; set; }

    public decimal? BranchId { get; set; }
}
