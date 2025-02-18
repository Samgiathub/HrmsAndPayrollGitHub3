using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100ProjectAllocation
{
    public string? PrjName { get; set; }

    public string? EmpFullName { get; set; }

    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal PrjId { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpActive { get; set; }

    public DateTime EffDate { get; set; }

    public string? BranchName { get; set; }

    public decimal? BranchId { get; set; }
}
