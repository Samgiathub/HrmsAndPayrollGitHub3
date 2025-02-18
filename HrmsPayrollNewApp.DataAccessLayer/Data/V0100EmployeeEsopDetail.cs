using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100EmployeeEsopDetail
{
    public decimal EsopId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string? BranchName { get; set; }

    public string DeptName { get; set; } = null!;

    public string DesigName { get; set; } = null!;

    public int? NoOfShare { get; set; }

    public decimal? PerquisiteValue { get; set; }

    public decimal? TaxablePerqValue { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? MarketPrice { get; set; }

    public decimal? EmpPrice { get; set; }
}
