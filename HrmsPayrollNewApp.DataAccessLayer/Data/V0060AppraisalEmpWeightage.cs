using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0060AppraisalEmpWeightage
{
    public decimal? EmpWeightageId { get; set; }

    public decimal? EkpaWeightage { get; set; }

    public decimal BranchId { get; set; }

    public decimal? SaWeightage { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpName { get; set; }

    public decimal CmpId { get; set; }

    public string? DesigName { get; set; }

    public string? DeptName { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal PaWeightage { get; set; }

    public DateTime? Expr1 { get; set; }

    public decimal PoAWeightage { get; set; }

    public bool EkpaRestrictWeightage { get; set; }

    public bool SaRestrictWeightage { get; set; }
}
