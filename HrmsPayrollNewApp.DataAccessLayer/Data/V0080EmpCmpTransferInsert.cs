using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080EmpCmpTransferInsert
{
    public decimal TranId { get; set; }

    public decimal OldCmpId { get; set; }

    public decimal OldEmpId { get; set; }

    public decimal NewCmpId { get; set; }

    public decimal NewEmpId { get; set; }

    public decimal OldBranchId { get; set; }

    public decimal? EmpCode { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? CmpName { get; set; }

    public DateTime EffectiveDate { get; set; }

    public string NewCmpName { get; set; } = null!;

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }
}
